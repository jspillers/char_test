# Transcoding can be hard.

Dealing with an arbitrary text file encoded in an unknown way and trying to 
normalize to UTF-8 (with minimal data loss) is a tricky thing.

This is a little test bed for trying out various detection and transcoding strategies. The problem
I was solving had to do with user uploaded CSV or TXT files for importing data into an app. Due to 
the way excel handles CSVs, I fully expected to deal with UTF-16LE files with a BOM
(byte order marker) and/or various flavors of ISO-8859. In a perfect world you would just specify 
that all files must be valid UTF-8, but most **developers** don't really understand what UTF-8 is let
alone your average user! You can't expect a user to do anything more than hit export on excel and dump 
the resulting mess into your uploader.

I started my exercise by laying a baseline with 1.9's built in string encoding methods. 
Explicitly transcoding the files works flawlessly (in MRI and jRuby) as long as the source encoding was 
set to exactly match the file's actual encoding. One trick here is setting the `File.open` directive
as `rb:bom|utf-8`. This scraps a BOM (Byte Order Marker) if one is present and sets the 
encoding to UTF-8 even if that's not the actual string encoding. Once you have this BOM stripped
string you can do the explicit transcode and everything comes out nice. This is great and all, but
if you don't know the precise source encoding of the file you are dealing with then the results 
of the encode might not be so pretty.

In the quest to detect the source encoding I tried several gems. [rchardet19](https://github.com/oleander/rchardet) comes very close to 
getting things right: it nails the unicode files (UTF-8 and UTF-16LE), and at least returns a flavor of ISO-8859 for 
the windows-1252 and iso-8859-1 files (ISO_8859_8). Unfortunately trying to transcode to UTF-8 and setting 
the source encoding as 8859-8 yields not so great results. Close but no cigar.

[charlock_holmes](https://github.com/brianmario/charlock_holmes) is the next gem I tried. I expected this one to be the winner as it is built on 
top of the icu4c which is *supposedly* the most badass character encoding detector to ever walk these
lands. It did not even come close to guessing the encodings correctly. As you can see below it guessed
correctly for valid UTF-8 (congrats), binary of all things for UTF-16LE (helpful!), and EUC-JP for the ISO flavored
files (WAT?).

[Ensure-encoding](https://github.com/Manfred/Ensure-encoding) won the day. One of the strategies this gem employs is very similar to similar to what 
I was planning on writing by hand: using an educated guess, use a small subset of encodings and test 
the unknown string against them one by one until we get a valid encoding and then transcode off that. If all
your anticipated encodings fail to get a valid match, then you can fall back to an encode without an explicit
source set and just pass in the options so that unknown or invalid characters get tossed out or replaced rather
than raising an encoding error.
```ruby
  some_string.encode(Encoding::UTF_8, invalid: :replace, undef: replace)
```
[String#encode docs](http://www.ruby-doc.org/core-1.9.3/String.html#method-i-encode)

As the output below shows, Ensure-encoding yields the same results as my contrived explicit transcode 
test.

Output:

```text
$>ruby char_test.rb 

explicit transcode
------------------------------

test_files/utf8.txt: UTF-8 Unicode text
transcoding from UTF-8 to UTF-8
abcdefghijklmnopqrstuvwxyz
Σὲ γνωρίζω ἀπὸ τὴν κόψη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!
Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖοι,
გთხოვთ ახლავე გაიაროთ რეგისტრაცია Unicode-ის მეათე საერთაშორისო
Зарегистрируйтесь сейчас на Десятую Международную Конференцию по
  ๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่
ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ
valid encoding: true


test_files/utf16le.txt: Little-endian UTF-16 Unicode text
transcoding from UTF-16LE to UTF-8

abcdefghijklmnopqrstuvwxyz
Σὲ γνωρίζω ἀπὸ τὴν κόψη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!
Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖοι,
გთხოვთ ახლავე გაიაროთ რეგისტრაცია Unicode-ის მეათე საერთაშორისო
Зарегистрируйтесь сейчас на Десятую Международную Конференцию по
  ๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่
ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ
valid encoding: true


test_files/iso88591.txt: ISO-8859 text
transcoding from ISO-8859-1 to UTF-8
abcdefghijklmnopqrstuvwxyz
¡¢£¤¥¦§¨©ª«¬&®¯°±²³´µ¶·¸¹º
»¼½¾¿×÷ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒ
ÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìí
îïðñòóôõöøùúûüýþÿ
valid encoding: true


test_files/windows1252.txt: ISO-8859 text
transcoding from Windows-1252 to UTF-8
abcdefghijklmnopqrstuvwxyz
¡¢£¤¥¦§¨©ª«¬&®¯°±²³´µ¶·¸¹º
»¼½¾¿×÷ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒ
ÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìí
îïðñòóôõöøùúûüýþÿ
valid encoding: true

charlock detection
------------------------------

test_files/utf8.txt: UTF-8 Unicode text
charlock:
{:type=>:text, :encoding=>"UTF-8", :confidence=>100}


test_files/utf16le.txt: Little-endian UTF-16 Unicode text
charlock:
{:type=>:binary, :confidence=>100}


test_files/iso88591.txt: ISO-8859 text
charlock:
{:type=>:text, :encoding=>"EUC-JP", :confidence=>50, :language=>"ja"}


test_files/windows1252.txt: ISO-8859 text
charlock:
{:type=>:text, :encoding=>"EUC-JP", :confidence=>50, :language=>"ja"}

rchardet19 detection
------------------------------

test_files/utf8.txt: UTF-8 Unicode text
CharDet:
#<struct #<Class:0x9c7eb33> encoding="utf-8", confidence=0.99>


test_files/utf16le.txt: Little-endian UTF-16 Unicode text
CharDet:
#<struct #<Class:0x263534c1> encoding="windows-1252", confidence=0.5>


test_files/iso88591.txt: ISO-8859 text
CharDet:
#<struct #<Class:0x159576c3> encoding="ISO-8859-8", confidence=0.23461713319342622>


test_files/windows1252.txt: ISO-8859 text
CharDet:
#<struct #<Class:0x3e2dce4e> encoding="ISO-8859-8", confidence=0.23461713319342622>

ensure-encoding transcode
------------------------------

test_files/utf8.txt: UTF-8 Unicode text
valid encoding: true
abcdefghijklmnopqrstuvwxyz
Σὲ γνωρίζω ἀπὸ τὴν κόψη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!
Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖοι,
გთხოვთ ახლავე გაიაროთ რეგისტრაცია Unicode-ის მეათე საერთაშორისო
Зарегистрируйтесь сейчас на Десятую Международную Конференцию по
  ๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่
ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ


test_files/utf16le.txt: Little-endian UTF-16 Unicode text
valid encoding: true

abcdefghijklmnopqrstuvwxyz
Σὲ γνωρίζω ἀπὸ τὴν κόψη χαῖρε, ὦ χαῖρε, ᾿Ελευθεριά!
Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖοι,
გთხოვთ ახლავე გაიაროთ რეგისტრაცია Unicode-ის მეათე საერთაშორისო
Зарегистрируйтесь сейчас на Десятую Международную Конференцию по
  ๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่
ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ


test_files/iso88591.txt: ISO-8859 text
valid encoding: true
abcdefghijklmnopqrstuvwxyz
¡¢£¤¥¦§¨©ª«¬&®¯°±²³´µ¶·¸¹º
»¼½¾¿×÷ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒ
ÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìí
îïðñòóôõöøùúûüýþÿ


test_files/windows1252.txt: ISO-8859 text
valid encoding: true
abcdefghijklmnopqrstuvwxyz
¡¢£¤¥¦§¨©ª«¬&®¯°±²³´µ¶·¸¹º
»¼½¾¿×÷ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒ
ÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìí
îïðñòóôõöøùúûüýþÿ

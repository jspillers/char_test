# Transcoding is hard.

Dealing with text files that can be encoded any number of different ways and trying to normalize them all to UTF-8 with minimal data loss is a tricky thing.

This is a little test bed for trying out various detection and transcoding strategies. Due to the way excel handles CSVs, one can expect to have to handle UTF-16LE with a BOM, or windows-1252/iso-8859-1. After trying several different ways of tackling the different encoded files, the Ensure-encoding gem seems to offer the most solid transcoding. 

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

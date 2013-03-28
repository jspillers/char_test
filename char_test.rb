# Test various strategies for dealing with uploaded files of unknown encoding
# and transcoding to UTF-8

require 'rubygems'
require 'charlock_holmes' # https://github.com/brianmario/charlock_holmes
require 'rchardet19'      # https://github.com/oleander/rchardet
require 'ensure/encoding' # https://github.com/Manfred/Ensure-encoding

def read_file(filename)
  file_str = nil
  File.open("test_files/#{filename}", 'rb:bom|utf-8') do |f|
    file_str = f.read
  end
  file_str
end

# create utf-16le from utf-8
#file_str = read_file('utf8.txt')
#File.open('test_files/windows1252.txt', 'w', encoding: Encoding::UTF_16LE) do |f|
#  f.puts "\xFF\xFE".force_encoding(Encoding::UTF_16LE).encode(Encoding::UTF_16LE)
#  f.puts file_str.force_encoding(Encoding::UTF_16LE).encode(Encoding::UTF_16LE, Encoding::UTF_8)
#end
#
# create windows 1252 from iso-8859-1
#iso_file_str = read_file('iso88591.txt')
#File.open('test_files/windows1252.txt', 'w', encoding: Encoding::WINDOWS_1252) do |f|
#  f.puts iso_file_str.force_encoding(Encoding::ISO_8859_1).encode(Encoding::WINDOWS_1252, Encoding::ISO_8859_1)
#end

def explicit_transcode(filename, from_encoding, to_encoding)
  puts ''
  puts `file test_files/#{filename}`
  puts "transcoding from #{from_encoding.name} to #{to_encoding.name}"

  file_str = read_file(filename)
  encoded_str = file_str.force_encoding(from_encoding).encode!(Encoding::UTF_8, from_encoding)

  puts encoded_str
  puts 'valid encoding: ' + encoded_str.valid_encoding?.to_s
  puts ''
end

def charlock_detect(filename)
  puts ''
  puts `file test_files/#{filename}`
  str = read_file(filename)
  puts 'charlock:'
  puts CharlockHolmes::EncodingDetector.detect(str).inspect
  puts ''
end

def rchardet19_detect(filename)
  puts ''
  puts `file test_files/#{filename}`
  str = read_file(filename)
  puts 'CharDet:'
  puts CharDet.detect(str).inspect
  puts ''
end

def ensure_encoding(filename)
  puts ''
  puts `file test_files/#{filename}`
  str = read_file(filename)
  encoded_str = str.ensure_encoding('UTF-8',
    :external_encoding  => [Encoding::UTF_16LE, Encoding::UTF_8, Encoding::ISO_8859_1, Encoding::WINDOWS_1252],
    :invalid_characters => :transcode
  )
  puts 'valid encoding: ' + encoded_str.valid_encoding?.to_s
  puts encoded_str
  puts ''
end

puts 'explicit transcode'
puts '-' * 30
explicit_transcode('utf8.txt', Encoding::UTF_8, Encoding::UTF_8)
explicit_transcode('utf16le.txt', Encoding::UTF_16LE, Encoding::UTF_8)
explicit_transcode('iso88591.txt', Encoding::ISO_8859_1, Encoding::UTF_8)
explicit_transcode('windows1252.txt', Encoding::WINDOWS_1252, Encoding::UTF_8)

puts 'charlock detection'
puts '-' * 30
charlock_detect('utf8.txt')
charlock_detect('utf16le.txt')
charlock_detect('iso88591.txt')
charlock_detect('windows1252.txt')

puts 'rchardet19 detection'
puts '-' * 30
rchardet19_detect('utf8.txt')
rchardet19_detect('utf16le.txt')
rchardet19_detect('iso88591.txt')
rchardet19_detect('windows1252.txt')

puts 'ensure-encoding transcode'
puts '-' * 30
ensure_encoding('utf8.txt')
ensure_encoding('utf16le.txt')
ensure_encoding('iso88591.txt')
ensure_encoding('windows1252.txt')


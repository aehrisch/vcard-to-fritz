Gem::Specification.new do |s|
  s.name                = 'vcardtofritz'
  s.version             = '0.2.0'
  s.licenses            = ['BSD-2-Clause']
  s.summary             = 'Converts a VCard file to a FritzBox Phonebook format'
  s.description         = 'Reads a VCard file (as exported by the OS X addressbook) into an XML format suitable for import FritzBox phonebook import'
  s.authors             = ['Eric Knauel']
  s.email               = 'eknauel@posteo.de'
  s.files               = 'lib/vcard-to-fritz.rb'
  s.bindir              = 'bin'
  s.executables         << 'vcard-to-fritz'
  s.add_runtime_dependency 'nokogiri', '~>1.6', '>= 1.6.7'
  s.add_runtime_dependency 'vcard_parser', '~> 1.0'
end

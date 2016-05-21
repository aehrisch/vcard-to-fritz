
require 'logger'
require 'nokogiri'
require 'vcard_parser'

# Convert OS X Addressbook exports in VCF format to the XML format
# used by AVM FritzBox. Tested with OS X 10.11, FritzOS 6.06, ruby
# 2.3.0.
class VCardToFritz
  
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::INFO

  attr_reader :infile, :outfile

  def initialize(infile, outfile)
    @infile, @outfile = infile, outfile 
  end

  def convert()
    contacts = self.read_vcf()
    builder = build_xml(contacts)
    LOG.info("writing Fritz phonebook to file #{out_name}")
    outfile = File.new(out_name, 'w+', encoding: Encoding::ISO_8859_1)
    outfile.puts(builder.to_xml)
    outfile.close()
  end
  
  # read VCF file and return an array of contacts 
  def read_vcf()
    
    infile = File.read(@infile, encoding: Encoding::UTF_8)
    cards = VCardParser::VCard.parse(infile)
    
    LOG.info("read #{cards.size} vcard records")
    
    contacts = []
    
    for i in (0...cards.size) do
      
      contact = { 'realName' => nil, 'work' => [], 'mobile' => [], 'home' => [] }
      fields = cards[i].fields
      
      with_phone_number = false
      fields.each do |f|
        case f.name
        when 'FN'
          contact['realName'] = f.value
        when 'TEL'
          case
          when f.params.values[0].nil?
            LOG.warn("ignoring nil phone record")
          when f.params.values[0].include?('WORK')
            contact['work'] += [f.value]
            with_phone_number = true
          when (f.params.values[0].include?('CELL') or f.params.values[0].include?('IPHONE'))
            contact['mobile'] += [f.value]
            with_phone_number = true
          when f.params.values[0].include?('HOME')
            contact['home'] += [f.value]
            with_phone_number = true
          end
        end
      end

      # skip records without phone numbers
      if with_phone_number then
        contacts << contact
      else
        LOG.warn("ignoring record '#{contact['realName']}': no phone numbers")
      end
    end
    
    return contacts
  end

  # build and return XML from CONTACTS array.
  def build_xml(contacts)
    builder = Nokogiri::XML::Builder.new(:encoding => 'ISO-8859-1') do |xml|
      xml.phonebooks {
        xml.phonebook('name' => 'Telefonbuch') {
          contacts.each do |c|
            xml.contact {
              xml.category { xml.text('0') }
              xml.services
              xml.setup
              xml.person {
                xml.realName { xml.text(c['realName']) }
                xml.imageURL
              }
              xml.telephony('nid' => '1') {
                i = 0
                ['home', 'mobile', 'work'].each do |k|
                  c[k].each do |p|
                    xml.number('type' => k, 'quickdial' => '', 'vanity' => '',
                               'prio' => i.to_s, 'id' => i.to_s) {
                      xml.text(p)
                    }
                    i = i + 1
                  end
                end
              }
            }
          end
        }
      }
    end

    return builder
  end
  
end

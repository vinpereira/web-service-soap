Dir['lib/**/*.rb'].sort.each { |file| require(File.dirname(__FILE__) + '/'+ file) }

require 'time_difference'
require 'elasticsearch'
require 'yaml'

# Get start time
start_time = Time.now

# Get arguments from config file
config = YAML::load_file('config/config.yml')

# Total of documents created
count_documents = 0

# Set an Elasticsearch client and connect to an URL
es_client = Elasticsearch::Client.new url: 'http://192.168.0.5:9200', log: true

# Delete an ES index
es_client.indices.delete index: 'wsanatel'

# (Re)Create an ES index
es_client.indices.create index: 'wsanatel'

# Declare a WS Anatel variable
ws_soap = WebServiceSOAP.new provider: config['provider'],
                             username: config['username'],
                             password: config['password'],
                             from_date: config['from_date'],
                             to_date: config['to_date']

# Set WS properties
ws_soap.set_web_service

begin
  # Get a XML with every IDs that are open in a given range
  xml_with_ids = ws_soap.get_all_requests

  # Get every <idtSolicitacao> tag's value (ID)
  # Split them all (IDs) into slices of 50 IDs each
  # And for each slice
  xml_with_ids.xpath('//idtSolicitacao/text()').each_slice(50).to_a.each do |slice|
    # Set a array of threads
    threads = []

    # For each ID inside the slice
    slice.each do |id|
      # Add a thread to Threads array
      threads << Thread.new(id) do

        # Declare a WS Anatel variable
        ws_soap_details = WebServiceSOAP.new provider: config['provider'],
                                             username: config['username'],
                                             password: config['password'],
                                             from_date: config['from_date'],
                                             to_date: config['to_date']

        # Set WS properties
        ws_soap_details.set_web_service

        # Get details and write them at Elasticsearch
        ws_soap_details.write_details_at_elasticsearch request_id: id

        # Add 1 document created
        count_documents += 1
      end   # end-Thread
    end   # end-slice

    # Wait all threads to finish
    threads.each do |thr|
      thr.join
    end

  end   # end-xml_with_ids.xpath("//idtSolicitacao/text()").each_slice(50).to_a.each

  # Write files (IDs + error messages) with the problems found
  ws_soap.files_with_problems

rescue Exception => msg
  puts 'Web Service problem at: ' + msg.to_s
end

# Get end time
end_time = Time.now

puts
puts 'Start at ' + start_time.inspect
puts 'Total of ' + count_documents.to_s + ' documents'
puts 'Finish at ' + end_time.inspect
puts 'Time elapsed: ' + TimeDifference.between(start_time, end_time).in_seconds.round(2).to_s + ' seconds'
puts 'Or: ' + TimeDifference.between(start_time, end_time).in_minutes.round(2).to_s + ' minutes'

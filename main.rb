Dir['lib/**/*.rb'].sort.each { |file| require(File.dirname(__FILE__) + '/'+ file) }

require 'time_difference'
require 'elasticsearch'

# Get start time
start_time = Time.now

# Set arguments
cod_provider = ARGV[0].to_s
username = ARGV[1].to_s
password = ARGV[2].to_s
from_date = ARGV[3].to_s
to_date = ARGV[4].to_s

# Total of documents created
count_documents = 0

# Set an Elasticsearch client and connect to an URL
es_client = Elasticsearch::Client.new url: 'http://localhost:9200', log: true

# Delete an ES index
es_client.indices.delete index: 'index_name'

# (Re)Create an ES index
es_client.indices.create index: 'index_name'

# Declare a WS Anatel variable
ws_soap = WebServiceSOAP.new provider: cod_provider,
                             username: username,
                             password: password,
                             from_date: from_date,
                             to_date: to_date

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
      threads << Thread.new do
        # Get a JSON with request's details
        hash_body_with_details = ws_soap.get_request_details request_id: id

        # puts hash_body_with_details

        # Insert a document with the JSON content into ES
        es_client.index index: 'index_name',
                       type: 'type_name',
                       id: id.to_s,
                       body: hash_body_with_details

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

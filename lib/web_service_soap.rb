require 'net/http'
require 'uri'
require 'nokogiri'
require 'json'

class WebServiceSOAP
  def initialize(provider:, username:, password:, from_date:, to_date:)
    # Set arguments
    @provider = provider
    @username = username
    @password = password
    @from_date = from_date
    @to_date = to_date

    # IDs with problems array
    @ids_with_problems = []

    # Error messages array
    @messages = []
  end

  # Set WS properties
  def set_web_service
    @uri = URI.parse('HTTP without WSDL')
    @request = Net::HTTP::Post.new(@uri)
    @request.content_type = 'text/xml'
  end

  def get_all_requests
    # Set 'consultarSolicitacao' action
    @request['Soapaction'] = 'SOAP Action'

    # Set 'consultarSolicitacao' body
    @request.body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:act="HTTP for the action">
                       <soapenv:Header/>
                       <soapenv:Body>
                          <act:consultarSolicitacao>
                             <requisicao_consulta>
                                <cod_prestadora>' + @provider + '</cod_prestadora>
                                <hash>' + @password + '</hash>
                                <login_sis>' + @username + '</login_sis>
                                <Data_Inicial>' + @from_date + ' 00:00:00</Data_Inicial>
                                <Data_Final>' + @to_date + ' 23:59:59</Data_Final>
                             </requisicao_consulta>
                          </act:consultarSolicitacao>
                       </soapenv:Body>
                    </soapenv:Envelope>
    '

    # try/catch block
    begin
      # Run 'consultarSolicitacao' at Anatel Web Service
      response_with_all_ids = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        http.request(@request)
      end

      # Parse response_with_all_ids.body using Nokogiri
      xml_with_all_ids = Nokogiri::XML(response_with_all_ids.body)

      # Raise an error if <idtSolicitacao> tag is empty
      if xml_with_all_ids.xpath('//idtSolicitacao/text()').to_s == ''
        raise 'Empty <idtSolicitacao> tag'
      end

      # Return a XML with all IDs
      xml_with_all_ids

    # Catch
    rescue Exception => msg
      puts 'WebService Exception at first request (Get IDs): ' + msg.to_s

    end   # end-try/catch block

  end # end-get_all_requests

  def get_request_details(request_id:)
    # Set 'consultarDetalheSolicitacao' action
    @request['Soapaction'] = 'SOAP Action'

    # Set a new request body for 'consultarDetalheSolicitacao'
    @request.body = ''
    @request.body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:act="HTTP for the action">
                       <soapenv:Header/>
                       <soapenv:Body>
                          <act:consultarDetalheSolicitacao>
                             <requisicao_detalhe_consulta>
                                <cod_prestadora>' + @provider + '</cod_prestadora>
                                <hash>' + @password + '</hash>
                                <login_sis>' + @username + '</login_sis>
                                <idtSolicitacao>' + request_id.to_s + '</idtSolicitacao>
                             </requisicao_detalhe_consulta>
                          </act:consultarDetalheSolicitacao>
                       </soapenv:Body>
                    </soapenv:Envelope>
    '

    # try/catch block
    begin
      # Run 'consultarDetalheSolicitacao' at Anatel Web Service
      response_with_details = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
        http.request(@request)
      end

      # Raise an error if response body is empty
      if response_with_details.body.to_s == ''
        raise 'Request details body is blank'
      end

      # Parse response_with_details.body using Nokogiri
      xml_with_details = Nokogiri::XML(response_with_details.body)

      # Create a hash where Key is node.name and Value is node.content
      hash_body = {}
      xml_with_details.xpath('//resposta_detalhe_consulta/*').each do |node|
        hash_body[node.name] = node.content.gsub(/\s+/, ' ').strip
      end

      # Return a JSON with request's details
      hash_body.to_json

    # catch
    rescue Exception => msg
      puts 'WebService Exception at details request: ' + msg.to_s

      # Error message (could be from XML or ES)
      @messages << msg.to_s.force_encoding('utf-8')

      # ID with problem (could be from XML or ES)
      @ids_with_problems << id.to_s
    end

  end

  def files_with_problems
    # Write a file with every ID with problem
    File.open('output/ids_with_problems.txt', 'w') do |f|
      @ids_with_problems.each do |id|
        f.write id.to_s + "\n"
      end

      f.write '\n' + 'Start time: ' + Time.now.inspect
    end

    # Write a file with every error message
    File.open('output/error_messages.txt', 'w') do |f|
      @messages.each do |message|
        f.write message.to_s + "\n"
      end

      f.write '\n' + 'Start time: ' + Time.now.inspect
    end
  end
end

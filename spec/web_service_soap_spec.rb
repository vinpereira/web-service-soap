require 'web_service_soap'
require 'yaml'

RSpec.describe "Web Service SOAP functions:" do
  before(:each) do
    @config = YAML::load(File.read("config/config.yml"))

    @web_service_soap = WebServiceSOAP.new provider: @config['provider'],
                                           username: @config['username'],
                                           password: @config['password'],
                                           from_date: @config['from_date'],
                                           to_date: @config['to_date']

    @web_service_soap.set_web_service
  end

  context "Initialize" do
    it "should set variables correctly" do
      expect(@web_service_soap.provider).to eq @config['provider']
      expect(@web_service_soap.username).to eq @config['username']
      expect(@web_service_soap.from_date).to eq @config['from_date']
      expect(@web_service_soap.to_date).to eq @config['to_date']
    end
  end

  context "getAllRequestsIds" do
    it "should return something" do
      expect(@web_service_soap.get_all_requests.to_s).not_to be_empty
    end
  end

  context "getRequestDetails" do
    it "should return something" do
      xml_with_ids = @web_service_soap.get_all_requests
      id = xml_with_ids.xpath('//idtSolicitacao[1]/text()')
      expect(@web_service_soap.get_request_details(request_id: id).to_s).not_to be_empty
    end
  end
end

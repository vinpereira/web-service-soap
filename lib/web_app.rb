require 'sinatra/base'
require 'sinatra/config_file'

class WebApp < Sinatra::Base
  register Sinatra::ConfigFile

  config_file '../config/config.yml'

  before do
    @web_service_soap = WebServiceSOAP.new provider: settings.provider,
                                           username: settings.username,
                                           password: settings.password,
                                           from_date: settings.from_date,
                                           to_date: settings.to_date
    @web_service_soap.set_web_service
  end

  get '/getAllRequestsIds' do
    @web_service_soap.get_all_requests.to_s
  end

  get '/getRequestDetails/:id' do
    @web_service_soap.get_request_details(request_id: params['id']).to_s
  end
end

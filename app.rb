require 'rubygems'
require 'active_support'
require 'sinatra'
require 'sinatra/respond_to'
require 'json'
require 'open-uri'

Sinatra::Application.register Sinatra::RespondTo

def buyabrick
  data = JSON.parse(open('http://buyabrick.childsifoundation.org/wall.json').read)
  data['details']['total_money']
end

get('/') do
  redirect 'http://www.childsifoundation.org'
end

get('/total') do
  total = buyabrick
  details = { :total => total }

  headers['Cache-Control'] = 'public, max-age=300'
  respond_to do |wants|
    wants.html { total.to_s }
    wants.txt { total.to_s }
    wants.xml { details.to_xml }
    wants.json { details.to_json }
    wants.yaml { details.to_yaml }
  end
end

require 'rubygems'
require 'active_support'
require 'sinatra'
require 'sinatra/respond_to'
require 'json'
require 'scruffy'
require 'open-uri'

mime_type :png, 'image/png'

Sinatra::Application.register Sinatra::RespondTo

def buyabrick
  data = JSON.parse(open('http://buyabrick.childsifoundation.org/wall.json').read)
  data['details']['total_money']
end

def google_doc
  key = 'tilwvsGv-HTvaBD29cvaGXw'
  url = "http://spreadsheets.google.com/pub?key=#{key}&single=true&gid=1&output=csv"
  data = open(url).read
  data.to_i
end

def totaliser_image(total)
  graph = Scruffy::Graph.new
  graph.renderer = Scruffy::Renderers::Standard.new
  graph.add :line, [total, 20_000]
  filename = "tmp/#{Time.now.to_i}.png"
  graph.render :to => filename, :as => 'png'
  open(filename).read  
end

get('/') do
  redirect 'http://www.childsifoundation.org'
end

get('/total') do
  total = buyabrick + google_doc
  details = { :total => total }

  headers['Cache-Control'] = 'public, max-age=300'
  respond_to do |wants|
    wants.html { total.to_s }
    wants.txt { total.to_s }
    wants.xml { details.to_xml }
    wants.json { details.to_json }
    wants.yaml { details.to_yaml }
    wants.png { totaliser_image(total) }
  end
end

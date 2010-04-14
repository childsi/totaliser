require 'rubygems'
require 'active_support'
require 'sinatra'
require 'sinatra/respond_to'
require 'json'
require 'RMagick'
require 'open-uri'

Sinatra::Application.register Sinatra::RespondTo
mime_type :png, 'image/png'

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

def totaliser_image(total, format='png')
  filename = "tmp/#{Time.now.to_i}.#{format}"
  
  canvas = Magick::Image.new(240, 30, Magick::HatchFill.new('white','lightcyan2'))
  gc = Magick::Draw.new

  # Draw ellipse
  gc.rectangle(0, 0, (total/30_000 * 240), 30)
  
  gc.draw(canvas)
  canvas.write(filename)
  
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
    wants.png { totaliser_image(total, 'png') }
  end
end

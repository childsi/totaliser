require 'rubygems'
require 'active_support'
require 'sinatra'
require 'sinatra/respond_to'
require 'json'
require 'RMagick'
require 'open-uri'

TARGET_SUM = 50_000.0

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

def totaliser_image(total, target=50_000, format='png')
  filename = "tmp/#{Time.now.to_i}.#{format}"
  
  canvas = Magick::Image.new(100, 300) #, Magick::HatchFill.new('white','lightcyan2'))
  gc = Magick::Draw.new
  
  # shadow
  gc.fill('lightgrey')
  gc.arc(15,215, 95,295, 305, 235)
  gc.arc(30,15, 80,70, 150, 30)
  gc.rectangle(35,50, 80,220)
  
  # edges
  gc.fill('black')
  gc.arc(10,210, 90,290, 305, 235)
  gc.arc(25,10, 75,60, 150, 30)
  gc.rectangle(25,40, 75,220)
  
  # background
  gc.fill('darkgrey')
  gc.arc(35,22, 65,60, 150, 30)
  gc.rectangle(35,40, 65,230)
  
  gc.fill('red')
  gc.arc(20,220, 80,280, 305, 235)
  gc.rectangle(35,40+(190-((total/target) * 190)), 65,230)

  # glint
  gc.fill('white')
  gc.rectangle(42,30, 48,225)
  
  # marker lines
  gc.fill('black')
  (0..9).each do |i|
    h = 40+(i*20)
    gc.rectangle(55,h, 75,h+2)
  end
  
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
    wants.png { totaliser_image(total, TARGET_SUM, 'png') }
  end
end
    
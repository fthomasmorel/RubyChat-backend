require 'sinatra/cross_origin'
require 'sinatra'
require 'JSON'
require 'mongo'

class Message
  attr_reader :content, :username, :date
  @@messages = []

  def initialize(username, content)
    @username = username
    @content = content
    @date = Time.now
  end

  def save
    db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'rubychat')
    db[:messages].insert_one(self.to_json)
  end

  def to_json
    return {:username => self.username, :content => self.content, :date => self.date}
  end

  def self.all
    db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'rubychat')
    p db[:messages].find
    db[:messages].find.to_a.to_json
  end
end

set :port, 8080
set :environment, :production
register Sinatra::CrossOrigin

configure do
  enable :cross_origin
end

before do
  content_type 'application/json'
end

get '/messages' do
  Message.all
end

post '/messages' do
  params = JSON.parse request.body.read
  message = Message.new(params['username'], params['content'])
  message.save
  200
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end

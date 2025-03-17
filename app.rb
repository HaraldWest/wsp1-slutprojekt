require 'sinatra'
require 'sinatra/activerecord'
require 'json'

# Konfiguration för att använda SQLite och skapa databasen automatiskt om den inte finns

class App < Sinatra::Base

  def db
    return @db if @db
    
    @db = SQLite3::Database.new("db/scores.sqlite")
    @db.result_as_hash = true
  
    return @db
  end

  get '/' do
    erb :"index"
  end

  post '/save_result' do
    result_data = JSON.parse(request.body.read)
    Result.create(score: result_data["score"])
    content_type :json
    { status: 'success' }.to_json
  end

  get '/view_results' do
    @results = Result.all
    erb :"results"
  end
end

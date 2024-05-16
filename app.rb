# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  title = 'NoTitle' if title.nil? || title.strip.empty?
  content = params[:content]
  memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  id = (memos.keys.map(&:to_i).max || 0) + 1
  memos[id] = { 'title' => title, 'content' => content }
  File.open('json/memos.json', 'w') { |file| JSON.dump(memos, file) }

  redirect '/'
end

get '/memos/:id' do
  memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']

  erb :show_memo
end

get '/memos/:id/edit' do
  memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']

  erb :edit
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]
  memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  memos[params[:id]] = { 'title' => title, 'content' => content }
  File.open('json/memos.json', 'w') { |file| JSON.dump(memos, file) }

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = File.open('json/memos.json') { |file| JSON.parse(file.read) }
  memos.delete(params[:id])
  File.open('json/memos.json', 'w') { |file| JSON.dump(memos, file) }

  redirect '/'
end

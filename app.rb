# frozen_string_literal: true

require 'erb'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

def connect
  @connect ||= PG.connect(dbname: 'memo')
end

configure do
  result = connect.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
  connect.exec('CREATE TABLE memos (id serial, title varchar(255), content text)') if result.values.empty?
end

def read_memos
  connect.exec('SELECT * FROM memos')
end

def read_memo(id)
  connect.exec_params('SELECT id, title, content FROM memos WHERE id = $1', [id]).first.transform_keys(&:to_sym)
end

def create_memo(title, content)
  connect.exec('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
end

def edit_memo(title, content, id)
  connect.exec('UPDATE memos SET title = $1, content = $2 WHERE id = $3;', [title, content, id])
end

def delete_memo(id)
  connect.exec('DELETE FROM memos WHERE id = $1;', [id])
end

get '/' do
  @memos = read_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  create_memo(title, content)

  redirect '/'
end

get '/memos/:id' do
  memo = read_memo(params[:id])
  @title = memo[:title]
  @content = memo[:content]
  erb :show_memo
end

get '/memos/:id/edit' do
  memo = read_memo(params[:id])
  @title = memo[:title]
  @content = memo[:content]

  erb :edit
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]
  edit_memo(title, content, params[:id])

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  delete_memo(params[:id])

  redirect '/'
end

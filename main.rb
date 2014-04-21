require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'pry'

set :sessions, true

# routing processes here, get/posts

get '/' do
  if session[:user_name]
  redirect '/game'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  session[:user_name] = params[:user_name]
  redirect '/set_bet'
end

get '/set_bet' do
  erb :set_bet
end

post '/set_bet' do
  session[:bet] = params[:bet].to_i
  redirect '/game'
end

get '/game' do
  session[:money] = 500
  session[:deck] = init_deck
  deck = session[:deck]
  test_card = deck[8]
  session[:img_path] = set_img_path(test_card)
  puts session[:img_path]
  erb :game
end

def init_deck
  deck = []
  suits = ['Spades', 'Clubs', 'Diamonds', 'Hearts']
  values = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
  suits.each do |suit|
    values.each do |value|
      deck << [suit, value]
    end
  end
  deck.shuffle!
end

def set_img_path(card)
  suit = card[0].downcase
  value = card[1].downcase
  img_path = "/public/images/cards/#{suit}_#{value}.jpg"
end





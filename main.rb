require 'rubygems'
require 'sinatra'
require 'shotgun'

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

# set up other session cookie hash values for game

get '/game' do
  session[:money] = 500
  session[:deck] = []
  erb :game
end

# methods etc needed by game

class Deck
  attr_accessor :cards
  
  def initialize(n)
    suits = ['Spades', 'Clubs', 'Diamonds', 'Hearts']
    values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    @cards = []
    n.times do
      suits.each do |s|
        values.each do |v|
          @cards << Card.new(s, v)
        end
      end
    end
    @cards.shuffle!
  end

  def first_deal(dealer, players)
    2.times do
      players.each do |p| 
        p.hand << deal_card
      end 
      dealer.hand << deal_card
    end
  end

  def deal_card
    cards.pop
  end
end





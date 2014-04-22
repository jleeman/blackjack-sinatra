require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'pry'

set :sessions, true

# define helper methods, can also use modules for this

helpers do

  def init_deck
    suits = ['Spades', 'Clubs', 'Diamonds', 'Hearts']
    values = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
    suits.product(values).shuffle!
  end

  def first_deal(player_cards, dealer_cards, deck)
    2.times do
      player_cards << deck.pop
      dealer_cards << deck.pop 
    end
  end

  def total(h)
    values = h.map{|card| card[1]}

    h_total = 0
    values.each do |value|
      if value == "Ace"
        h_total += 11
      else
        h_total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    values.select{|value| value == "Ace"}.count.times do
      break if h_total <= 21
      h_total -= 10
    end
    h_total
  end

  def image_paths(hand)
    paths = []
    hand.each do |card|
      suit = card[0].downcase.to_s
      value = card[1].downcase.to_s
      paths << "/images/cards/#{suit}_#{value}.jpg"
    end
    paths
  end

  def display_card(card)
    suit = card[0]
    value = card[1]
    "<img src='/images/cards/#{suit}_#{value}.jpg' />"
  end

end

before do
  @show_buttons = true
end

# routing processes here, get/posts

get '/' do
  if session[:user_name]
  redirect '/game'
  else
    redirect '/player/set_name'
  end
end

get '/player/set_name' do
  erb :'/player/set_name'
end

post '/player/set_name' do
  session[:user_name] = params[:user_name]
  redirect '/player/set_bet'
end

get '/player/set_bet' do
  erb :'/player/set_bet'
end

post '/player/set_bet' do
  session[:bet] = params[:bet].to_i
  redirect '/game'
end

get '/game' do
  session[:money] = 500
  session[:deck] = init_deck
  session[:player_cards] = []
  session[:dealer_cards] = []
  first_deal(session[:player_cards], session[:dealer_cards], session[:deck])
  session[:player_total] = total(session[:player_cards])
  session[:dealer_total] = total(session[:dealer_cards])
  session[:player_image_paths] = image_paths(session[:player_cards])
  session[:dealer_image_paths] = image_paths(session[:dealer_cards])

  erb :game
end

post '/player/hit' do
  session[:player_cards] << session[:deck].pop
  if total(session[:player_cards]) > 21
    @bust = "Sorry, you went bust!"
    @show_buttons = false
  end
  erb :'/game'
end

post '/player/stay' do
  @stay = "You have chosen to stay."
  @show_buttons = false
  erb :'/game'
end







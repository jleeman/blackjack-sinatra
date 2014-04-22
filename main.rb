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
    h_value = 0
    h.each do |card|
      value = card[1]
      case value
        when /[2-9]|[1][0]/ 
          h_value += value.to_i 
        when "Jack" || "Queen" || "King"
          h_value += 10
        when "A"
          h_value += 11
          if h_value > 21
            h_value -= 10 
          end 
      end
    end
    h_value
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

end

# routing processes here, get/posts

get '/' do
  if session[:user_name]
  redirect '/game'
  else
    redirect 'player/set_name'
  end
end

get '/player/set_name' do
  erb :set_name
end

post '/player/set_name' do
  session[:user_name] = params[:user_name]
  redirect 'player/set_bet'
end

get '/player/set_bet' do
  erb :set_bet
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

post '/game' do
  if params[:Hit]
    redirect '/player/hit'
  elsif params[:Stay]
    redirect '/player/stay'
  end
end

get '/player/hit' do
  erb :hit
end

get '/player/stay' do
  erb :stay
end







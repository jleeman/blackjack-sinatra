require 'rubygems'
require 'sinatra'
# require 'shotgun'
require 'pry'

set :sessions, true

# constants

BLACKJACK_VALUE = 21
DEALER_HIT_VALUE = 17

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
      break if h_total <= BLACKJACK_VALUE
      h_total -= 10
    end
    h_total
  end

  def display_card(card)
    suit = card[0]
    value = card[1]
    "<img src='/images/cards/#{suit.downcase}_#{value.downcase}.jpg' style='margin-right:10px' />"
  end

  def win!(message)
    @show_hit_stay = false
    @show_dealer_option = false
    @play_again = true
    # update player money
    session[:money] += session[:bet]
    @success = "<strong>#{session[:player_name]} wins!!!</strong> #{message}<br  />#{session[:player_name]} now has $#{session[:money]}."
  end

  def lose!(message)
    @show_hit_stay = false
    @show_dealer_option = false
    @play_again = true
    # update player money
    session[:money] -= session[:bet]
    @error = "<strong>#{session[:player_name]} loses, sorry!</strong> #{message}<br  />#{session[:player_name]} now has $#{session[:money]}."
  end

  def tie!(message)
    @show_hit_stay = false
    @show_dealer_option = false
    @play_again = true
    @success = "<strong>It's a push!</strong> #{message}<br  />#{session[:player_name]} still has $#{session[:money]}."
  end

end

before do
  @show_hit_stay = true
  @show_dealer_option = false
  @show_dealer_card = false
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
  session[:money] = 500
  erb :'/player/set_name'
end

post '/player/set_name' do
  session[:player_name] = params[:player_name]
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
  session[:deck] = init_deck
  session[:player_cards] = []
  session[:dealer_cards] = []
  first_deal(session[:player_cards], session[:dealer_cards], session[:deck])
  session[:player_total] = total(session[:player_cards])
  session[:dealer_total] = total(session[:dealer_cards])
  if total(session[:player_cards]) == BLACKJACK_VALUE
    win!("#{session[:player_name]} hit blackjack!")
  end
  erb :game
end

post '/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = total(session[:player_cards])

  if player_total == BLACKJACK_VALUE
    win!("#{session[:player_name]} hit blackjack!")
  elsif player_total > BLACKJACK_VALUE
    lose!("#{session[:player_name]} went bust at #{player_total}!")  
  end
  erb :'/game'
end

post '/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_stay = false
  redirect '/dealer'
end

get '/dealer' do
  @show_hit_stay = false
  @show_dealer_card = true
  dealer_total = total(session[:dealer_cards])
  
  if dealer_total == BLACKJACK_VALUE
    lose!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_VALUE
    win!("Dealer busted at #{dealer_total}!")
  elsif dealer_total >= DEALER_HIT_VALUE
    redirect '/compare'
  else
    @show_dealer_option = true
  end

  erb :'/game'
end

post '/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/dealer'
end

get '/compare' do
  @show_hit_stay = false
  @show_dealer_card = true
  @show_dealer_option = false
  player_total = total(session[:player_cards])
  dealer_total = total(session[:dealer_cards])

  if player_total < dealer_total
    lose!("#{session[:player_name]} stayed at #{player_total} and dealer stayed at #{dealer_total}.")
  elsif player_total > dealer_total
    win!("#{session[:player_name]} stayed at #{player_total} and dealer stayed at #{dealer_total}.")
  else 
    tie!("#{session[:player_name]} stayed at #{player_total} and dealer stayed at #{dealer_total}.")
  end

  erb :'/game'
end

get '/game_over' do
  erb :'game_over'
end







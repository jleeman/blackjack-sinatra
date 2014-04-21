def init_deck
  deck = []
  suits = ['Spades', 'Clubs', 'Diamonds', 'Hearts']
  values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
  suits.each do |suit|
    values.each do |value|
      deck << [suit, value]
      img_path = "/images/cards/#{suit.downcase}_#{value.downcase}.jpg"
      deck << img_path
    end
  end
  deck.shuffle!
end 
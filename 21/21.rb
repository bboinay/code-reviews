# GAME NEEDS TO START WITH A TEXT FILE CALLED '21_bank.txt' CONTAINING THE 
# NUMBER '100'
  
class Twenty_One
  CARD_VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  CARD_SUITS = %w(Diamonds Hearts Clubs Spades)
  SCREEN_WIDTH = 80
  START_CASH_AMOUNT = 100
  
  SAVE_FILE = '21/21_bank.txt'
  
  WELCOME_MESSAGE = "
  +------------------------------------------------------------------------------+
  |                            welcome to black jack!                            |
  |            hit or stay to beat the dealer without going over 21.             |
  +------------------------------------------------------------------------------+
  "
  
  def cash_out!(file_location, money)
    File.truncate(file_location, 0)
    File.write(file_location, money[:player], mode: 'a')
  end
  
  def cash_in!(file_location, money)
    if File.read(file_location).empty?
      money[:player] = START_CASH_AMOUNT
    else
      money[:player] = File.read(file_location).to_i
    end
    
    if money[:player] <= 0
      give_emergency_funds(money)
    end
  end
  
  def give_emergency_funds(money)
    money[:player] = 10
    money[:bet_amount] = 2
  end
  
  def print_big_cards(card_strings)
    card_strings.each { |line| puts line.center(SCREEN_WIDTH) }
  end
  
  def size_description(deck)
    if deck.nil?
      'N/A'
    elsif (0..14).cover? deck.size
      'ALMOST EMPTY'
    elsif (15..26).cover? deck.size
      'THIN'
    elsif (27..43).cover? deck.size
      'MEDIUM'
    elsif (44..52).cover? deck.size
      'FULL'
    end
  end
  
  def hi_lo_card_value(card)
    value = card[0]
    if ('2'..'6').cover?(value)
      1
    elsif ('7'..'9').cover?(value)
      0
    else
      -1
    end
  end
  
  def hi_lo_count(hands, deck)
    dealer_hidden_card = hands[:dealer][0]
    hand_to_count = new_deck - (deck + [dealer_hidden_card])
    hand_to_count.sum { |card| hi_lo_card_value(card) }
  end
  
  def display_deck_info(hands, deck)
    print "Deck size: #{size_description(deck)} (#{deck.size})"
    print " " * 40
    print "Hi-Lo value: #{hi_lo_count(hands, deck)}\n"
  end
  
  def display_welcome_banner
    puts WELCOME_MESSAGE
  end
  
  def display_dealer_side(hands, show_dealer_card)
    dealer_value = (show_dealer_card ? calculate_points(hands[:dealer]) : "??")
    puts "DEALER: #{dealer_value}".center(SCREEN_WIDTH)
    if show_dealer_card
      display_whole_hand(hands[:dealer])
    else
      display_hidden_hand(hands[:dealer])
    end
  end
  
  def display_bet_amount(money)
    puts "Bet amount: #{money[:bet_amount]}".center(SCREEN_WIDTH)
  end
  
  def display_player_cash(money)
    puts "Player cash: #{money[:player]}".center(SCREEN_WIDTH)
  end
  
  def display_upside_down_deck
    card_stack = big_top_card
    copy_left_edge_of_big_card!(card_stack, 3)
    print_big_cards(card_stack)
  end
  
  def display_whole_hand(hand_of_cards)
    return "" if hand_of_cards.empty?
    print_big_cards(make_big_hand(hand_of_cards))
  end
  
  def display_hidden_hand(hand_of_cards)
    return "" if hand_of_cards.empty?
    hand = hand_of_cards.dup
    hand.shift
    big_dealer_hand = make_big_hand(hand)
    copy_left_edge_of_big_card!(big_dealer_hand)
    print_big_cards(big_dealer_hand)
  end
  
  def display_results(result)
    case result
    when 'b'
      print "you busted! "
    when 'p'
      print "you win! "
    when 't'
      print "push! bets returned. "
    else
      print "dealer wins... "
    end
  end
  
  def display_screen(hands, deck, money, show_dealer_card=false)
    display_welcome_banner
    puts "\n"
    display_dealer_side(hands, show_dealer_card)
    puts "\n"
    display_bet_amount(money)
    display_deck_info(hands, deck)
    display_player_cash(money)
    puts "\n"
    puts "PLAYER: #{calculate_points(hands[:player])}".center(SCREEN_WIDTH)
    display_whole_hand(hands[:player])
    puts "\n"
  end
  
  def end_game_money_message(money)
    if money[:player] <= 0
      "OUT OF FUNDS".center(SCREEN_WIDTH)
    else
      "Don't spend it all in one place!".center(SCREEN_WIDTH)
    end
  end
  
  def display_end_game_screen(money)
    display_welcome_banner
    puts "\n"
    display_upside_down_deck
    puts "\n" * 3
    display_player_cash(money)
    puts "\n" * 6
    puts end_game_money_message(money)
    puts "Thanks for playing!".center(SCREEN_WIDTH)
    puts "\n" * 5
    wait_for_exit
  end
  
  def wait_for_exit
    print "Press enter to exit.".center(SCREEN_WIDTH)
    puts "\n" * 2
    gets
  end
  
  def copy_left_edge_of_big_card!(big_hand, num_times=1)
    num_times.times do
      big_hand.map! { |line| line[0..1] + line }
    end
  end
  
  def make_big_hand(hand_of_cards, overlap=9)
    hand = hand_of_cards.dup
    big_hand = make_big(hand.shift)
    hand.each_with_index do |card, card_num|
      big_card_to_add = make_big(card)
      big_hand.map!.with_index do |current_big_hand_line, row_num|
        line_to_keep = current_big_hand_line[0...(overlap * (1 + card_num))]
        line_to_add = big_card_to_add[row_num]
        line_to_keep + line_to_add
      end
    end
    big_hand
  end
  
  def big_top_card
    [
      "//```````````\\\\",
      "||  + + + +  ||",
      '|| + + + + + ||',
      '||  + + + +  ||',
      '|| + + + + + ||',
      '||  + + + +  ||',
      '|| + + + + + ||',
      '||  + + + +  ||',
      '|| + + + + + ||',
      '\\\\___________//',
      ' ````````````` '
    ]
  end
  
  def big_heart(card)
    value = card[0].center(2)
    [
      "/`````````````\\",
      "| #{value}          |",
      '|     _ _     |',
      '|    / V \    |',
      '|    \   /    |',
      '|     \ /     |',
      '|      `      |',
      '|             |',
      "|          #{value} |",
      '\             /',
      ' ````````````` '
    ]
  end
  
  def big_diamond(card)
    value = card[0].center(2)
    [
      "/`````````````\\",
      "| #{value}          |",
      '|             |',
      '|      /\\     |',
      '|     /  \\    |',
      '|     \\  /    |',
      '|      \\/     |',
      '|             |',
      "|          #{value} |",
      '\             /',
      ' ````````````` '
    ]
  end
  
  def big_club(card)
    value = card[0].center(2)
    [
      "/`````````````\\",
      "| #{value}          |",
      '|             |',
      '|    ˰{`}˰    |',
      '|   { `˰΄ }   |',
      '|    ˘`|`˘    |',
      '|     ΄⎺`     |',
      '|             |',
      "|          #{value} |",
      '\             /',
      ' ````````````` '
    ]
  end
  
  def big_spade(card)
    value = card[0].center(2)
    [
      "/`````````````\\",
      "| #{value}          |",
      '|      ˰      |',
      '|     / \\     |',
      '|    /   \\    |',
      '|    ⋱~˰~⋰    |',
      '|      ┴      |',
      '|             |',
      "|          #{value} |",
      '\             /',
      ' ````````````` '
    ]
  end
  
  def make_big(card)
    suit = card[1]
    case suit
    when 'Hearts'
      big_heart(card)
    when 'Diamonds'
      big_diamond(card)
    when 'Clubs'
      big_club(card)
    when 'Spades'
      big_spade(card)
    end
  end
  
  # temporarily considers aces to be 1 point
  def individual_point_value(card)
    card_value = card[0]
    if integer?(card_value)
      card_value.to_i
    elsif card_value == 'A'
      1
    else
      10
    end
  end
  
  def calculate_points_helper(hand)
    hand.sum { |card| individual_point_value(card) }
  end
  
  def count_aces(hand)
    hand.count { |card| card[0] == 'A' }
  end
  
  def calculate_points(hand)
    points = calculate_points_helper(hand)
    num_aces = count_aces(hand)
    loop do
      break if num_aces == 0 || points + 10 > 21
      num_aces -= 1
      points += 10
    end
    points
  end
  
  def integer?(string)
    string.to_i.to_s == string
  end
  
  def print_loading_dots
    3.times do
      sleep(0.7)
      print '.'
    end
    puts ''
  end
  
  def dealer_turn(hands, deck, money)
    display_screen(hands, deck, money)
    print "let's see how the dealer does"
    print_loading_dots
    loop do
      display_screen(hands, deck, money, true)
      sleep(1)
      break if calculate_points(hands[:dealer]) >= 17
      hands[:dealer] += draw_card!(hands, deck, 1)
    end
  end
  
  def anyone_busted?(hands)
    player_value = calculate_points(hands[:player])
    dealer_value = calculate_points(hands[:dealer])
    player_value > 21 || dealer_value > 21
  end
  
  def new_deck
    CARD_VALUES.product(CARD_SUITS)
  end
  
  def draw_card!(hands, deck, cards=1)
    drawn_cards = []
    cards.times do
      refill_deck!(deck, hands) if deck.empty?
      drawn_cards << deck.pop
    end
    drawn_cards
  end
  
  def refill_deck!(deck, hands)
    deck.clear
    cards_in_play = []
    hands.keys.each { |k| cards_in_play += hands[k] }
    new_deck.shuffle!.each do |new_card|
      deck << new_card if !cards_in_play.include?(new_card)
    end
    deck
  end
  
  def clear_cards(hands)
    hands.keys.each { |k| hands[k] = [] }
  end
  
  def clear(hands)
    hands.keys.each do |keys|
      hands[keys] = []
    end
  end
  
  def alternate_deal(hands, deck, num_cards_each=1)
    num_cards_each.times do
      hands.keys.each do |key|
        hands[key] += draw_card!(hands, deck)
      end
    end
  end
  
  def deal_new_game(hands, deck)
    clear_cards(hands)
    alternate_deal(hands, deck, 2)
  end
  
  def valid_bet(bet, money)
    pos_num = (integer?(bet) && bet.to_i > 0)
    enough_money = (money[:player] >= bet.to_i)
    pos_num && enough_money
  end
  
  def offer_new_bet_amount(hands, deck, money, show_dealer_card)
    print "type [b]et to change bet amount or press enter to continue: "
    choice = gets.chomp.downcase[0]
    if choice == 'b'
      loop do
        break if money[:player] <= 0
        display_screen(hands, deck, money, show_dealer_card)
        print "new bet amount: "
        new_bet = gets.chomp
        if valid_bet(new_bet, money)
          money[:bet_amount] = new_bet.to_i
          display_screen(hands, deck, money, show_dealer_card)
          break
        end
      end
    end
  end
  
  def settle_bets(result, money)
    case result
    when 'p'
      money[:player] += money[:bet_amount]
    when 'd', 'b'
      money[:player] -= money[:bet_amount]
    end
  end
  
  def adjust_bet_amount_if_high!(money)
    if money[:bet_amount] > money[:player]
      money[:bet_amount] = money[:player]
    end
  end
  
  def end_of_round_sequence(hands, deck, money)
    result = get_results(hands)
    settle_bets(result, money)
    show_dealer_card = true unless result == 'b'
    display_screen(hands, deck, money, show_dealer_card)
    display_results(result)
    offer_new_bet_amount(hands, deck, money, show_dealer_card)
    adjust_bet_amount_if_high!(money)
  end
  
  def get_results(hands)
    player_value = calculate_points(hands[:player])
    dealer_value = calculate_points(hands[:dealer])
    if player_value > 21
      "b"
    elsif dealer_value > 21 || player_value > dealer_value
      "p"
    elsif dealer_value == player_value
      "t"
    else
      "d"
    end
  end
  
  def play
    hands = { player: [], dealer: [] }
    deck = new_deck.shuffle!
    money = { player: 100, bet_amount: 10 }
    cash_in!(SAVE_FILE, money)
    choice = ''
    
    loop do
      deal_new_game(hands, deck)
      loop do
        sleep(0.25)
        display_screen(hands, deck, money)
        print "type your selection: [c]ash out, [h]it, or [s]tay: "
        choice = gets.chomp.downcase[0]
        case choice
        when 'h', '1'
          hands[:player] += draw_card!(hands, deck, 1)
        when 's', '2'
          dealer_turn(hands, deck, money)
          end_of_round_sequence(hands, deck, money)
          break
        when 'c'
          break
        end
        if anyone_busted?(hands)
          end_of_round_sequence(hands, deck, money)
          break
        end
      end
      if money[:player] <= 0 || choice == 'c'
        cash_out!(SAVE_FILE, money)
        display_end_game_screen(money)
        break
      end
      refill_deck!(deck, hands) if deck.empty?
      choice = ''
    end
  end
end

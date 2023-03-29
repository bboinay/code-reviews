require "./21/21.rb"
# require "./21/21_bank.txt"

require "./RPS/rps.rb"
require "./RPS/display.rb"
require "./RPS/images.rb"

require "./tic_tac_toe.rb"

def print_with_border(text, lines=1)
  lines.times do  
    puts "|#{text.center(80)}|"
  end
end

def print_option(option)
  print_with_border "=> #{option}"
end

def print_menu
  puts "+#{'-' * 80}+"
  print_with_border("", 13)
  print_with_border "pick a game!"
  print_with_border ""
  print_option "[t] for Tic-Tac-Toe"
  print_option "[2] for 21"
  print_option "[r] for RPS(LS)"
  print_with_border ""
  print_option "[q] to quit"
  print_with_border("", 14)
  puts "+#{'-' * 80}+"
  print ' ' * 40
end

loop do
  print_menu
  choice = gets.chomp
  case choice
  when 't'
    Tic_Tac_Toe.new.play
  when '2'
    Twenty_One.new.play
  when 'r'
    RPS.new.play
  when 'q'
    break
  end
end
require "./display.rb"

class RPS
  attr_reader :player, :computer, :display, :referee, :scoreboard

  def initialize
    @player = Player.new
    @computer = Computer.new
    @referee = Referee.new(player, computer)
    @scoreboard = Scoreboard.new(referee)
    @display = Display.new(player, computer, referee, scoreboard)
  end

  def play
    loop do
      display.show_idle_screen
      player.request_human_input
      break if player.ready_to_quit
      computer.make_choice
      display.show_animation
      referee.determine_outcome
      scoreboard.increment_score
      display.show_outcome
      referee.ask_if_player_ready
    end
  end
end

class Player
  attr_reader :move, :name

  def request_human_input
    loop do
      Display.show "[r]ock, [p]aper, [sc]issors, [l]izard, [sp]ock, or [q]uit"
      @move = Move.new(gets.chomp.downcase)
      break if move.valid?
      Display.show "invalid"
    end
  end

  def ready_to_quit
    move.quit?
  end

  private

  def valid_choice?
    Move::POSSIBLE_PLAYER_CHOICES.include?(choice[0])
  end
end

class Computer
  attr_reader :move

  def make_choice
    @move = Move.new(Move::GAME_CHOICES.sample)
  end
end

class Scoreboard
  attr_reader :list_of_results, :longest_streak

  def initialize(referee)
    @referee = referee
    @left_wins = 0
    @right_wins = 0
    @longest_streak = 0
    @list_of_results = []
  end

  def increment_score
    list_of_results << referee.outcome unless referee.outcome == 'draw'
  end

  def player_wins
    list_of_results.count('win')
  end

  def computer_wins
    list_of_results.count('lose')
  end

  def current_streak
    streak = 0
    list_of_results.reverse.each do |result|
      break unless result == 'win'
      streak += 1
    end
    update_longest_streak(streak)
    streak
  end

  private

  attr_reader :referee

  def update_longest_streak(streak)
    @longest_streak = streak unless longest_streak > streak
  end
end

class Move
  include Comparable
  MOVE_HIERARCHY = { 'r' => %w(sc l),
                     'p' => %w(sp r),
                     'sc' => %w(l p),
                     'l' => %w(p sp),
                     'sp' => %w(sc r) }
  GAME_CHOICES = MOVE_HIERARCHY.keys.map(&:to_s)
  POSSIBLE_PLAYER_CHOICES = GAME_CHOICES + %w(q)

  def initialize(value)
    POSSIBLE_PLAYER_CHOICES.each do |option|
      if value[0, option.size] == option
        @value = option
      end
    end
  end

  def rock?
    value == 'r'
  end

  def paper?
    value == 'p'
  end

  def scissors?
    value == 'sc'
  end

  def lizard?
    value == 'l'
  end

  def spock?
    value == 'sp'
  end

  def quit?
    value == 'q'
  end

  def valid?
    POSSIBLE_PLAYER_CHOICES.include?(value)
  end

  def to_s
    value
  end

  def <=>(other)
    if value == other.value
      0
    elsif MOVE_HIERARCHY[value].include?(other.value)
      1
    else
      -1
    end
  end

  protected

  attr_reader :value
end

class Referee
  attr_reader :game_choices, :outcome

  def initialize(player, computer)
    @player = player
    @computer = computer
  end

  def determine_outcome
    @outcome =  if player.move == computer.move
                  'draw'
                elsif player.move > computer.move
                  'win'
                else
                  'lose'
                end
  end

  def ask_if_player_ready
    Display.show "press [ENTER] when ready."
    gets
  end

  private

  attr_reader :player, :computer
end

RPS.new.play

require "./images.rb"
class Display
  SCREEN_WIDTH = 85
  attr_reader :scoreboard, :screen_width

  def initialize(player, computer, referee, scoreboard)
    @player = player
    @computer = computer
    @referee = referee
    @scoreboard = scoreboard
    @screen_width = SCREEN_WIDTH
  end

  def show_idle_screen
    show_game_frame(Images::LEFT_FRAME3, Images::RIGHT_FRAME3)
  end

  def show_animation
    left_throw_image = game_move_to_left_image(player.move)
    right_throw_image = game_move_to_right_image(computer.move)

    show_countdown_throws
    show_last_throw(left_throw_image, right_throw_image)
    sleep(1)
  end

  def show_outcome
    case referee.outcome
    when 'win'
      self.class.show "you win!"
    when 'draw'
      self.class.show "draw!"
    when 'lose'
      self.class.show "you lost..."
    end
  end

  def self.show(text)
    puts text.center(SCREEN_WIDTH)
  end

  private

  attr_reader :player, :computer, :referee

  def game_move_to_left_image(move)
    return Images::LEFT_FRAME3 if move.rock?
    return Images::LEFT_PAPER if move.paper?
    return Images::LEFT_SCISSORS if move.scissors?
    return Images::LEFT_LIZARD if move.lizard?
    return Images::LEFT_SPOCK if move.spock?
  end

  def game_move_to_right_image(move)
    return Images::RIGHT_FRAME3 if move.rock?
    return Images::RIGHT_PAPER if move.paper?
    return Images::RIGHT_SCISSORS if move.scissors?
    return Images::RIGHT_LIZARD if move.lizard?
    return Images::RIGHT_SPOCK if move.spock?
  end

  def show_top_banner
    puts "+#{'-' * screen_width}+"
    puts "|#{'welcome to RPS(LS)!'.center(screen_width)}|"
    puts "+#{'-' * screen_width}+"
  end

  def show_score_info
    print "   Player wins: #{scoreboard.player_wins}".ljust(screen_width / 2)
    puts "Computer wins: #{scoreboard.computer_wins}   ".rjust(screen_width / 2)
    Display.show "Current streak: #{scoreboard.current_streak}"
    Display.show "Longest streak: #{scoreboard.longest_streak}"
  end

  def prepare_image(image)
    ans = image.split("\n")
    ans.map { |line| line.ljust(45) }
  end

  def combine_images(*images)
    images = images.map { |bs| prepare_image(bs) }
    combined_image = images.shift
    combined_image.size.times do |row|
      images.each do |image|
        if combined_image[row].nil?
          combined_image[row] = ''
        else
          combined_image[row] << image[row]
        end
      end
    end
    combined_image
  end

  def show_game_frame(left_image, right_image, last_image=false)
    puts "\n" * 17
    show_top_banner
    show_score_info
    puts combine_images(left_image, right_image)
    puts "\n" unless last_image
  end

  def show_countdown_throws
    left_sequence = [Images::LEFT_FRAME3, Images::LEFT_FRAME2,
                     Images::LEFT_FRAME1, Images::LEFT_FRAME2]
    right_sequence = [Images::RIGHT_FRAME3, Images::RIGHT_FRAME2,
                      Images::RIGHT_FRAME1, Images::RIGHT_FRAME2]
    4.times do
      left_sequence.each_with_index do |_, i|
        sleep(0.1)
        show_game_frame(left_sequence[i], right_sequence[i])
      end
    end
  end

  def show_last_throw(left_throw, right_throw)
    show_game_frame(left_throw, right_throw, true)
  end
end

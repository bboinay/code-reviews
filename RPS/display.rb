require "./images.rb"
class Display
  SCREEN_WIDTH = 85 
  attr_reader :scoreboard, :screen_width
  
  def initialize(player, computer, referee, scoreboard)
    @player, @computer = player, computer
    @referee, @scoreboard = referee, scoreboard
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
    if move.rock?
      Images::LEFT_FRAME3
    elsif move.paper?
      Images::LEFT_PAPER
    elsif move.scissors?
      Images::LEFT_SCISSORS
    elsif move.lizard?
      Images::LEFT_LIZARD
    elsif move.spock?
      Images::LEFT_SPOCK
    end
  end
  
  def game_move_to_right_image(move)
    if move.rock?
      Images::RIGHT_FRAME3
    elsif move.paper?
      Images::RIGHT_PAPER
    elsif move.scissors?
      Images::RIGHT_SCISSORS
    elsif move.lizard?
      Images::RIGHT_LIZARD
    elsif move.spock?
      Images::RIGHT_SPOCK
    end
  end
  
  def show_top_banner
    puts "+#{"-" * screen_width}+"
    puts "|#{"welcome to RPS(LS)!".center(screen_width)}|"
    puts "+#{"-" * screen_width}+"
  end
  
  def show_score_info
    print "   Player wins: #{scoreboard.player_wins}".ljust(screen_width / 2)
    puts "Computer wins: #{scoreboard.computer_wins}   ".rjust(screen_width / 2)
    puts "Current streak: #{scoreboard.current_streak}".center(screen_width)
    puts "Longest streak: #{scoreboard.longest_streak}".center(screen_width)
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
    # puts "\n" unless last_image
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
    # show_game_frame(Images::LEFT_FRAME3, Images::RIGHT_FRAME3)
    # sleep(0.065)
    show_game_frame(left_throw, right_throw, true)
  end
end
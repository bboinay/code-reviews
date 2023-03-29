class Tic_Tac_Toe
  BLANK_CHAR = '-'
  PLAYER_MARK = 'X'
  AI_MARK = 'O'
  
  O_LINES = [
    '  __ ',
    ' |  |',
    ' |__|'
  ]
  
  X_LINES = [
    '     ',
    '  \/ ',
    '  /\ '
  ]
  
  INPUT_MAP = [
    %w(q w e),
    %w(a s d),
    %w(z x c)
  ]
  
  INPUT_DIAGRAM = "
                                                T I C - T A C - T O E
           K E Y B O A R D                           B O A R D
  
            |     |     |                             |     |
       ``|`````|`````|`````|``                     Q  |  W  |  E
         |  Q  |  W  |  E  |                          |     |
         |     |     |     |                     -----+-----+-----
        ``|```` |```` |```` |``                       |     |
          |  A  |  S  |  D  |          ==>         A  |  S  |  D
          |     |     |     |                         |     |
         `````|` ```|` ```|` ```|`               -----+-----+-----
              |  Z  |  X  |  C  |                     |     |
              |     |     |     |                  Z  |  X  |  C
           ```|`````|`````|````` ``                   |     |
  \n\n"
  
  WELCOME_MESSAGE = "\n
  +------------------------------------------------------------------------------+
  |    welcome to tic-tac-toe! Use QWE-ASD-ZXC to select a starting square.      |
  |        Players receive 1 point for a win, and 0.5 points for a draw.         |
  +------------------------------------------------------------------------------+
  "
  
  def display_welcome_info
    puts WELCOME_MESSAGE
    puts INPUT_DIAGRAM
  end
  
  def print_array(array)
    array.each { |row| p row }
    puts ""
  end
  
  def rotate_board(board, num_turns=1)
    num_turns.times do
      board = rotate_board_once(board)
    end
    board
  end
  
  def rotate_board_once(board)
    rotated_array = new_board
    board.each_with_index do |row, r|
      row.each_with_index do |_, c|
        rotated_array[r][c] = board[2 - c][r]
      end
    end
    rotated_array
  end
  
  def input_char_to_coord(input_char)
    INPUT_MAP.each_with_index do |row, r|
      row.each_with_index do |char, c|
        return [r, c] if char == input_char
      end
    end
  end
  
  def new_board
    array = []
    3.times do
      temp_array = []
      3.times do
        temp_array << '-'
      end
      array << temp_array
    end
    array
  end
  
  def left_score(score)
    "Player: #{score[:player]}".center((80 - 19) / 2)
  end
  
  def right_score(score)
    "AI: #{score[:ai]}".center((80 - 17) / 2) + "\n"
  end
  
  def print_big_char(char_lines, line_to_print)
    case char_lines.downcase
    when 'x'
      print X_LINES[line_to_print]
    when 'o'
      print O_LINES[line_to_print]
    else
      print ' ' * 5
    end
  end
  
  def clear_screen
    puts "\n" * 20
  end
  
  def print_board_horizontal(r, score, left_pad)
    if r == 0
      puts ' ' * left_pad + '-----+-----+-----'
    elsif r == 1
      puts left_score(score) + '-----+-----+-----' + right_score(score)
    end
  end
  
  def print_board(board, score)
    left_pad = 30
    board.each_with_index do |row, r|
      3.times do |i|
        print ' ' * left_pad
        row.each_with_index do |char, c|
          print_big_char(char, i)
          print '|' unless c == 2
          puts '' if c == 2
        end
      end
      print_board_horizontal(r, score, left_pad)
    end
  end
  
  def display_screen(board, score)
    display_welcome_info
    print_board(board, score)
    puts "\n" * 3
  end
  
  def valid_input_char?(char)
    INPUT_MAP.flatten.include?(char.downcase)
  end
  
  def valid_move?(board, coord)
    row, col = coord
    board[row][col] == BLANK_CHAR
  end
  
  def valid_moves_list(board)
    valid_moves = []
    board.each_with_index do |row, r|
      row.each_with_index do |_, c|
        current_space = [r, c]
        if valid_move?(board, current_space)
          valid_moves << current_space
        end
      end
    end
    valid_moves
  end
  
  def random_ai_move!(board)
    valid_moves = valid_moves_list(board)
    play_coord!(board, valid_moves.sample, AI_MARK) unless valid_moves.empty?
  end
  
  def find_char_on_board(char, board)
    board.each_with_index do |row, r|
      if row.include? char
        return [r, row.index(char)]
      end
    end
    nil
  end
  
  # if any row has 2 char_to_check's and 1 open space, marks that open space
  # on move_template
  def mark_template_rows!(board, char_to_check, move_template, mark)
    board.each_with_index do |row, r|
      if row.count(char_to_check) == 2 && row.count(BLANK_CHAR) == 1
        move_template[r][row.index(BLANK_CHAR)] = mark
      end
    end
  end
  
  # if \ diagonal has 2 char's and 1 open space, marks the open space on
  # move_template
  def mark_template_diagonal!(board, char_to_check, move_template, mark)
    diagonal = get_diagonal(board)
    if diagonal.count(char_to_check) == 2 && diagonal.count(BLANK_CHAR) == 1
      index = diagonal.index(BLANK_CHAR)
      move_template[index][index] = mark
    end
  end
  
  def last_blank_space_in_row_of_chars(board, char_to_check)
    move_template = new_board
    template_mark = '~'
    2.times do
      mark_template_rows!(board, char_to_check, move_template, template_mark)
      mark_template_diagonal!(board, char_to_check, move_template, template_mark)
      # spins board and move_template 90 degrees clockwise
      board = rotate_board(board)
      move_template = rotate_board(move_template)
    end
    # spins move_template back to original board orientation before checking where
    # a mark, if any, was made
    move_template = rotate_board(move_template, 2)
    find_char_on_board(template_mark, move_template)
  end
  
  def ai_defensive_move!(board)
    coord_to_defend = last_blank_space_in_row_of_chars(board, PLAYER_MARK)
    play_coord!(board, coord_to_defend, AI_MARK)
  end
  
  def player_can_win?(board)
    last_blank_space_in_row_of_chars(board, PLAYER_MARK) != nil
  end
  
  def ai_winning_move!(board)
    coord_to_play = last_blank_space_in_row_of_chars(board, AI_MARK)
    play_coord!(board, coord_to_play, AI_MARK)
  end
  
  def ai_can_win?(board)
    last_blank_space_in_row_of_chars(board, AI_MARK) != nil
  end
  
  def ai_turn!(board)
    if ai_can_win?(board)
      ai_winning_move!(board)
    elsif player_can_win?(board)
      ai_defensive_move!(board)
    else
      random_ai_move!(board)
    end
  end
  
  def get_diagonal(board)
    board.map.with_index { |row, i| row[i] }
  end
  
  # checks if any row is complete, or if the \ diagonal is complete, then
  # rotates the board 90 degrees and makes the same checks again.
  # returns a single char if game is over ('p' for player wins, 'a' for ai wins,
  # 'd' for draw) or nil otherwise.
  def get_end_result(board)
    2.times do
      board.each do |row|
        return 'p' if row.count(PLAYER_MARK) == 3
        return 'a' if row.count(AI_MARK) == 3
      end
      return 'p' if get_diagonal(board).count(PLAYER_MARK) == 3
      return 'a' if get_diagonal(board).count(AI_MARK) == 3
      board = rotate_board(board)
    end
    return 'd' if valid_moves_list(board).empty?
  end
  
  def game_over?(board)
    get_end_result(board) != nil
  end
  
  def update_scores(board, score)
    case get_end_result(board)
    when 'p'
      score[:player] += 1
    when 'a'
      score[:ai] += 1
    when 'd'
      score[:player] += 0.5
      score[:ai] += 0.5
    end
  end
  
  def display_result(board)
    case get_end_result(board)
    when 'p'
      puts "player wins"
    when 'a'
      puts "ai wins"
    when 'd'
      puts 'tie!'
    end
  end
  
  def display_end_game(board, score)
    display_screen(board, score)
    display_result(board)
  end
  
  def play_coord!(board, coord, char)
    row, col = coord
    board[row][col] = char if valid_move?(board, coord)
  end
  
  def player_move!(board, coord)
    play_coord!(board, coord, PLAYER_MARK)
  end
  
  def player_turn!(board)
    input_char, coord = nil
    # move validation loop
    loop do
      # input validation loop
      loop do
        input_char = gets.chomp.downcase
        break if valid_input_char?(input_char)
        puts "whoops, invald input! use QWE-ASD-ZXC to select a square."
      end
      coord = input_char_to_coord(input_char)
      if valid_move?(board, coord)
        player_move!(board, coord)
        break
      else
        puts "whoops, can't go there! pick another square using QWE-ASD-ZXC."
      end
      # end of input validation loop
    end
    # end of move validation loop
  end
  
  def play
    # repeating games loop
    score = { player: 0, ai: 0 }
    loop do
      board = new_board
      turn = [-1, 1].sample
      # game loop
      loop do
        display_screen(board, score)
        player_turn!(board) if turn == 1
        ai_turn!(board) if turn == -1
        clear_screen
        break if game_over?(board)
        turn *= -1
      end
      # end of game loop
      update_scores(board, score)
      display_end_game(board, score)
      puts "play again? (y/n)"
      play_again = gets.chomp
      break if play_again.downcase[0] == 'n'
    end
    # end of repeating games loop
  end
end

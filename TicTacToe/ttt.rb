# Tic tac toe by Ben Cwik

class TicTacToe
  # 2d array representing board
  attr_accessor :board, :moves_counter
  # const vars
  X = 'X'
  O = 'O'
  BOARD_SIZE = 3
  
  # initialize a game of Tic Tac Toe. Default board size is 3x3
  def initialize
    # create empty 2d array based on width and height parameter
    # array values are initially nil
    @board = Array.new(BOARD_SIZE) { Array.new BOARD_SIZE }

    # set moves counter to 0
    @moves_counter = 0
  end

  # returns the size of the board
  def board_size
    return BOARD_SIZE
  end

  # returns true if given coordinates lie within the board, false otherwise
  def is_valid_coordinates? x, y
    # check x coordinate
    if x.nil? or x.class != Fixnum or x < 0 or x >= board_size
      puts "Invalid x coordinate specified: #{x}"
      return false
    end

    # check y coordinate
    if y.nil? or y.class != Fixnum or y < 0 or y >= board_size
      puts "Invalid y coordinate specified: #{y}"
      return false
    end

    return true
  end

  # returns true if mark is X or O, false otherwise
  def is_valid_mark? mark
    if mark !~ /^#{X}|#{O}$/i
      puts "Mark \"#{mark}\" is invalid!"
      return false
    end
    return true
  end

  # returns an array containing any coordinates that will win the game with the mark passed in
  # otherwise returns false if there are no winning moves
  def can_win? mark
    return false unless is_valid_mark? mark

    winning_moves = []
    
    board_size.times.each do |x|
      board_size.times.each do |y|
        if place_mark x, y, mark
          winning_moves.push({:x => x, :y => y}) if victory? x, y
          remove_mark x, y
        end
      end
    end

    return (winning_moves.empty? ? false : winning_moves)
  end

  # checks to see if we can place a mark at the given location
  # returns true if the coordinates are valid and the spot is empty
  def can_place_mark? x, y
    return false unless is_valid_coordinates? x, y
    # check if spot is already taken
    unless @board[x][y].nil?
      puts "Coordinate x:#{x},y:#{y} is already taken by #{@board[x][y]}!"
      return false
    end
    
    return true
  end

  # returns true if we were able to place a mark at the give coordinate, false otherwise
  def place_mark x, y, mark
    # make sure the spot is empty and the mark type is valid
    return false unless can_place_mark? x, y and is_valid_mark? mark
    
    # actually record mark on the board and increment moves counter
    @board[x][y] = mark.upcase
    @moves_counter += 1
    return true
  end

  # returns true if we removed a mark from the give coordinates, false otherwise
  def remove_mark x, y
    return false unless is_valid_coordinates? x, y # out of bounds
    return false if @board[x][y].nil? # there isn't a mark to remove

    # remove mark on board and decrement moves counter
    @board[x][y] = nil
    @moves_counter -= 1
    return true
  end

  # represents the logic for the best possible move. The AI is unbeatable, but it is
  # still possible to draw. Returns the coordinates
  def get_best_move mark
    return unless is_valid_mark? mark

    # check if we can win
    coords = can_win? mark
    if coords
      place_mark coords.first[:x], coords.first[:y], mark
      return coords.first
    end
    # check if we need to block
    opponent_mark = mark =~ /#{X}/i ? O : X
    coords = can_win? opponent_mark
    if coords
      place_mark coords.first[:x], coords.first[:y], mark
      return coords.first
    end
    # check if we can fork
    if @moves_counter > 2
      forks = get_forks mark
      return forks.first if forks
    end
    # check if we need to block fork
    if @moves_counter > 3
      forks = get_forks opponent_mark
      return forks.first if forks
    end
    # check to see if we can mark center
    center_coord = board_size / 2
    if can_place_mark? center_coord, center_coord
      return {:x => center_coord, :y => center_coord}
    end
    # check to see if we need to play in an opposite corner
    # top left
    if @board[0][0] =~ /#{opponent_mark}/i
      if can_place_mark? board_size-1, board_size-1
        return {:x => (board_size-1), :y => (board_size-1)}
      end
    end
    # bottom left
    if @board[0][board_size-1] =~ /#{opponent_mark}/i
      if can_place_mark? board_size-1, 0
        return {:x => (board_size-1), :y => 0}
      end
    end
    # top right
    if @board[board_size-1][0] =~ /#{opponent_mark}/i
      if can_place_mark? 0, board_size-1
        return {:x => 0, :y => (board_size-1)}
      end
    end
    # bottom right
    if @board[board_size-1][board_size-1] =~ /#{opponent_mark}/i
      if can_place_mark? 0, 0
        return {:x => 0, :y => 0}
      end
    end
    # place mark in any open corner
    # top left
    if can_place_mark? 0, 0
      return {:x => 0, :y => 0}
    end
    # bottom left
    if can_place_mark? 0, 0
      return {:x => 0, :y => (board_size-1)}
    end
    # top right
    if can_place_mark?((board_size-1), 0)
      return {:x => (board_size-1), :y => 0}
    end
    # bottom right
    if can_place_mark?((board_size-1), (board_size-1))
      return {:x => (board_size-1), :y => (board_size-1)}
    end
    # place mark in any remaining side
    # top
    if can_place_mark? center_coord, 0
      return {:x => center_coord, :y => 0}
    end
    # bottom
    if can_place_mark? center_coord, (board_size-1)
      return {:x => center_coord, :y => (board_size-1)}
    end
    # left
    if can_place_mark? 0, center_coord
      return {:x => 0, :y => center_coord}
    end
    # right
    if can_place_mark?((board_size-1), center_coord)
      return {:x => (board_size-1), :y => center_coord}
    end

    # shouldn't ever get here
    raise 'PROBLEM WITH BOARD LOGIC, SHOULD HAVE MADE A MOVE BY NOW'
  end

  # returns all possible 'forks'. A fork is a move where it creates at least two
  # opportunities to win. Returns false if there are no forks
  def get_forks mark
    forks = []
    board_size.times.each do |x|
      board_size.times.each do |y|
        if place_mark x, y, mark
          coords = can_win? mark
          if coords and coords.size > 1
            forks.push({:x => x, :y => y})
          end
          remove_mark x, y
        end
      end
    end

    return forks.empty? ? false : forks
  end

  # returns true if the given coordinate is part of chain of three of the same marks
  # which indicates a win in TicTacToe. Returns false otherwise
  def victory? x, y
    return false unless is_valid_coordinates? x, y
    current_mark = @board[x][y]
    
    # if spot is empty, then obviously it's not a winner
    return false if current_mark.nil?
    
    # check column
    board_size.times.each do |temp_y|
      break if @board[x][temp_y] != current_mark
      return true if temp_y == (board_size - 1)
    end

    # check row
    board_size.times.each do |temp_x|
      break if @board[temp_x][y] != current_mark
      return true if temp_x == (board_size - 1)
    end
    
    # check diagonal
    if x == y # does it lie on the diagonal?
      board_size.times.each do |i|
        break if @board[i][i] != current_mark
        return true if i == (board_size - 1)
      end
    end
    
    # check reverse diagonal
    if (x + y) == (board_size - 1) # does it lie on the diagonal?
      board_size.times.each do |i|
        break if @board[i][board_size - 1 - i] != current_mark
        return true if i == (board_size - 1)
      end
    end

    return false
  end
  
  # Simply prints the board out
  def print_board
    board_size.times.each do |y|
      line = ''
      board_size.times.each do |x|
        line += @board[x][y].nil? ? " " : @board[x][y]
        line += ' | ' unless x == (board_size - 1)
      end
      puts line
    end
  end
  
  def play
    puts 'Welcome to Tic-Tac-Toe by Ben Cwik!'

    # determine if we're playing against the computer or another human
    puts 'Would you like to play against the <computer> or a <friend>?'
    puts 'Sorry, I didn\'t understand your input, please enter either <computer> or <friend>' while gets !~ /(c|f)/i
    use_computer = $1 =~ /c/i
    if use_computer
      # play against the computer!
      puts 'Would you like to go first? Answer <yes> or <no>'
      puts 'Sorry I didn\'t understand your input, please answer either <yes> or <no>' while gets !~ /(y|n)/i
      computer_turn = $1 =~ /n/i
    end

    # start the game
    x_turn = true
    puts "The upper left corner is specified as 0,0. The bottom right corner is #{board_size-1},#{board_size-1}"
    while (board_size * board_size) != @moves_counter
      current_mark = x_turn ? X : O
      puts "It's #{(use_computer and computer_turn) ? 'computer' : current_mark} turn! Choose a coordinate in the form of X,Y..."
      
      if use_computer and computer_turn
        # computer turn
        orig_stdout = $stdout.clone
        $stdout.reopen File.new('/dev/null', 'w') # temporarily suppress output while logic is processed
        coords = get_best_move current_mark
        # reenable stdout
        $stdout.reopen orig_stdout
        place_mark coords[:x], coords[:y], current_mark

        # check if computer won
        if victory? coords[:x], coords[:y]
          puts 'Computer has won the game!'
          print_board
          return
        end

        computer_turn = false
      else
        # human turn
        print_board
        puts 'Please enter a coordinate in the form of X,Y' while gets !~ /(\d+)\s*(,|\s+)\s*(\d+)/ or not place_mark $1.to_i, $3.to_i, current_mark
        
        # check if player won
        if victory? $1.to_i, $3.to_i
          puts "#{use_computer ? 'You have' : current_mark + ' has'} won the game!"
          print_board
          return
        end

        computer_turn = true
      end
      x_turn = !x_turn
    end
    puts 'Game ended in a draw!'
    print_board
    return
  end
  
end


# main entry, play a game!
while true do
  ttt = TicTacToe.new.play
  play_again = 'Would you like to play again? Please enter <yes> or <no>'
  puts play_again
  puts play_again while gets !~ /(y|n)/i
  exit if $1 =~ /n/i
end

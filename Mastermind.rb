# Game initialize - select whether to be code breaker/creator and run option
class MasterMind
  def initialize
    loop do
      puts 'Select 1 to be the code creator or 2 to be the code breaker?'
        @option = gets.chomp
        case @option
        when '1'
          puts 'Create code'
          computer_break
          break
        when '2'
          game
          break
        else
          puts 'invalid option'
        end
    end
  end
end

# if breaker, computer initializes random array
class PlayerSelect < MasterMind
  def initialize
    @computer_random = Array.new(4) { rand(1..6) }
    super
  end

  private

  # creates duplicate array
  def computer_copy
    @computer_code = @computer_random.dup
  end

  # player guesses computer code
  def player_input
    puts 'Enter 4 digits between 1 and 6'
    @player_guess = gets.chomp.split('').map(&:to_i)
    until @player_guess.length == 4 && @player_guess.all? { |b| b.between?(1, 6) }
      puts 'Enter 4 digits between 1 and 6'
      @player_guess = gets.chomp.split('').map(&:to_i)
    end
  end

  # checks if player code matches computer code
  def player_win_check
    if @player_guess == @computer_code
      puts "You cracked the code! #{@computer_random}"
      return true

    end
  end

  # check if player number matches computer number
  def win_index_match
    @player_guess.each_with_index do |player_number, player_idx|
      if player_number == @computer_code[player_idx]
        puts 'o'
        @computer_code[player_idx] = 'o'
        @player_guess[player_idx] = 'p'
      end
    end
  end

  # check if computer code includes player number
  def win_include
    @player_guess.each do |player_number|
      if @computer_code.include?(player_number)
        @computer_code[@computer_code.index(player_number)] = 'x'
        puts 'x'
      end
    end
  end

  public

  # game if breaker
  def game
    12.times do
      computer_copy
      player_input
      return if player_win_check == true

      win_index_match
      win_include
    end
    puts "You weren't able to crack the code #{@computer_random}"
  end
end

# initialize first guess of computer if player is code creator
class ComputerBreaker < PlayerSelect
  def initialize
    @list = [*1111..6666]
    @computer_guess = [1, 1, 1, 1]
    @clue_array = []
    @player_final = []
    super
  end

  private

  # player enters code
  def player_code
    puts 'Enter 4 digits between 1 and 6'
    @player_code = gets.chomp.split('').map(&:to_i)
    until @player_code.length == 4 && @player_code.all? { |b| b.between?(1, 6) }
      puts 'Enter 4 digits'
      @player_code = gets.chomp.split('').map(&:to_i)
    end
    @player_final = @player_code.dup
  end

  # check if computer number matches player number
  def comp_index_match
    @computer_guess.each_with_index do |computer_number, computer_idx|
      if computer_number == @player_code[computer_idx]
        @clue_array.push('o')
        @player_code[computer_idx] = 'o'
      end
    end
  end

  # check if player code includes computer number
  def comp_include
    @computer_guess.each do |computer_number|
      if @player_code.include?(computer_number)
        @player_code[@player_code.index(computer_number)] = 'x'
        @clue_array.push('x')
      end
    end
  end

  # cycles through numbers for new computer guess
  def new_comp
    @computer_guess.each_with_index do |_number, idx|
      if idx == @clue_array.length
        @computer_guess[idx] += 1
        if @computer_guess[idx] > 6
          @computer_guess[idx] -= 6
        end
      end
      if idx > @clue_array.length
        @computer_guess[idx] = @computer_guess[idx - 1]
      end
    end
  end

  # deletes numbers from list that cannot be code
  def delete_list
    if @clue_array.length == 4
      @list.each_with_index do |number, idx|
        if @computer_guess.sort != number.to_s.split('').map(&:to_i).sort
          @list[idx] = nil
        end
      end
      @list.compact!
      @computer_guess = @list[rand(@list.length - 1)].to_s.split('').map(&:to_i)
    end
  end

  # removes number if not part of code
  def cull
    @list.each_with_index do |number, idx|
      if (@clue_array.length == 2) && (@clue_array.count('o') == 1) && (number.to_s.split('').map(&:to_i)[0] == @computer_guess[0])
        @list[idx] = nil
      end
    end
  end

  # check if computer guesses code correctly
  def comp_win_check
    if @computer_guess == @player_final
      puts "Computer has cracked your code #{@player_final}"
      return true
    end
  end

  public

  # game if creator
  def computer_break
    player_code
    i = 1
    while i < 13
      puts "comp guess #{i}: #{@computer_guess}"
      sleep 2
      return if comp_win_check == true

      comp_index_match
      comp_include
      new_comp
      cull
      delete_list
      puts "clue #{i}: #{@clue_array}"
      sleep 2
      @player_code = @player_final.dup
      @clue_array = []
      i += 1
    end
    puts "Computer wasn't able to crack your code #{@player_final}"
  end
end

ComputerBreaker.new
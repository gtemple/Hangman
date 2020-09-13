require 'yaml'

class GameRules

  def find_solution(options)
    solution = options.split("\n").select { |w| w.size > 5 && w.size < 13 }.sample.strip
    @dictionary = ''
    return solution.downcase
  end

  def hide_solution(word)
    hidden_word = "_____".rjust(word.length - 1, '_')
    return hidden_word
  end

  def get_input(inc, hint)
    check = false
    g = ''
    puts "\nType in your guess!"
    while check == false
      g = gets.chomp
      if g == 'save' || g == 'load'
        game_save_load(g)
        check = false
      elsif g.length != 1 || ((g.ord < 65 || g.ord > 90) && (g.ord < 97 || g.ord > 122))
        puts "Invalid Input!"
        check = false
      elsif inc == nil
        check = true
      elsif inc.include?(g) || hint.include?(g)
        puts "You've already guessed that letter! try again"
        check = false
      else
        check = true
      end
    end
    g
  end

end

class Game < GameRules

  def initialize
    @dictionary = File.read "dictionary.txt"
    @incorrect = []
    @attempts = 6
    @solution = find_solution(@dictionary)
    @hidden_solution = hide_solution(@solution)
  end

  def p_incorrect
    puts "Incorrectly guessed letters." + @incorrect.join(', ')
  end

  def p_hidden_solution
    puts @hidden_solution
  end

  def p_solution 
    puts @solution
  end

  def round_play(gss)
    indexes = []
    if @solution.include?(gss)
      @solution.each_char.with_index do |l, i|
        indexes << i if l == gss
      end
      indexes.each { |n| @hidden_solution[n] = gss }
      return true
    else
      @incorrect << gss
      return false
    end
  end

  def game_play
    puts "\nWelcome to hangman! The computer has chosen its word."
    puts "Hint: At any point type 'save' to to save your game or 'load' to load an old game."
    game_end = false
    while game_end == false
      p_incorrect
      p_hidden_solution
      guess = round_play(get_input(@incorrect, @hidden_solution))
      if @hidden_solution == @solution
        puts "Congrats, the word is #{@solution}, you win!"
        game_end = true
      elsif guess == true
        puts "Good guess!"
      elsif guess == false && @attempts == 1
        puts "You lose! The word was #{@solution}" 
        game_end = true
      elsif guess == false
        @attempts -=1
        puts "Nope! Try again. You have #{@attempts} remaining attempts"
      end
    end
  end

  def game_save_load(save_load)
    Dir.mkdir("save_data") unless Dir.exists?("save_data")
    game_load = false
    if save_load == 'save'
      puts "Please type a name for your save"
      to_yaml
    elsif save_load == 'load'
      Dir.foreach('save_data') { |f| puts f if f.include?('.yml') }
      puts 'Type the name of the game you are trying to load'
      from_yaml
    end
    puts @hidden_solution
    puts "\nType in your guess!"
  end


  def to_yaml
    filename = gets.chomp
    File.open(('save_data/' + filename + '.yml'), 'w') { |f| YAML.dump(self, f) }
  end
  
  def from_yaml
    filename = gets.chomp
    File.open('save_data/' + filename) do |f|
      @saved_game = YAML.load_file(f)
      @saved_game.game_play
    end
  rescue StandardError
    puts "Sorry, invalid input."
  end
end



names = []

names << "GameID" + rand(9999).to_s
names[-1] = Game.new
names[-1].game_play

stop = false
while stop == false

  puts "That was fun! Play again? Type 'yes' or 'no'"
  check = gets.chomp
  if check == 'yes'
    names << "GameID" + rand(9999).to_s
    names[-1] = Game.new
    names[-1].game_play
  elsif check == 'no'
    puts "See ya later!"
    stop = true
  else
    "Sorry, invalid input!"
  end
end



# _______
# |     |
# |    \O/
# |     |
# |    / \
#/△\
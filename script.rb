# Color list
    # 41 -- red
    # 42 -- green
    # 43 -- yellow
    # 44 -- blue
    # 45 -- magenta
    # 46 -- cyan
    # 100 -- dark_gray
    # 107 -- white

class Table < Array
    @@colors = ["\e[41m \e[0m", "\e[42m \e[0m", "\e[43m \e[0m", "\e[44m \e[0m", "\e[45m \e[0m", "\e[46m \e[0m", "\e[100m \e[0m", "\e[107m \e[0m"]
    
    attr_accessor :player_one, :player_two
    
    def initialize(default, numbers, value)
        super(default){Array.new(numbers, value)}
        @player_one = ""
        @player_two = ""
        @rows = "" # used to print colours with puts command in CLI
    end

    def play 
        # Game start
        greetings = "*************************\n* " + "\e[93mWELCOME TO MASTERMIND\e[0m" + " *\n*************************"
        puts greetings + "\n\nPRESS #{"\e[5m1\e[0m"} TO START THE GAME"
        start_game_input = gets.chomp
        until start_game_input == "1" do
            puts "\nPRESS #{"\e[5m1\e[0m"} TO START THE GAME"
            start_game_input = gets.chomp
        end
        player_choice
    end

    # Choose to play vs AI / Human
    def player_choice 
        system "clear"
        puts "Play...\n\n#{"\e[5m1\e[0m"}) vs AI\n#{"\e[5m2\e[0m"}) vs Player"
        play_against_input = gets.chomp
        until play_against_input == "1" || play_against_input == "2"
            player_choice
            redo
        end
        if play_against_input == '1'
            game_starting
            ai_play
        elsif play_against_input == '2'
            game_starting
            human_play
        end 
    end

    def game_starting
        puts "Game starting#{"\e[5m...\e[0m"}"
        system "sleep 2; clear"
        puts "Insert Player One Name"
        @player_one = gets.chomp
    end

    def human_play
        puts "Insert Player Two Name"
        @player_two = gets.chomp

        puts player_one
        i = 0
        color_number = 1
        4.times do
            puts "Choose color # #{color_number}"
            color = gets.chomp.to_i
            puts 'Choose the position'
            cell = gets.chomp.to_i
            self[i][cell] = @@colors[color]
            self.each do |column|
                column.each_with_index do |item, idx|
                    if idx == 3
                        @rows = ""
                    end
                end
            end
            color_number += 1
        end
        i += 1
        @rows << "  #{item}"
    end
    puts @rows

    def ai_play
        @player_two = 'AI'
    end

    def code_maker
        i = 0
        color_number = 1
        4.times do
            puts "Choose color # #{color_number}"
            color = gets.chomp.to_i
            puts 'Choose the position'
            cell = gets.chomp.to_i
            self[i][cell] = @@colors[color]
            self.each do |column|
                column.each_with_index do |item, idx|
                    if idx == 3
                        @rows = ""
                    end
                end
            end
            color_number += 1
        end
        i += 1
        @rows << "  #{item}"
    end
    puts @rows
end

master_mind = Table.new(10, 4, "O")
master_mind.play

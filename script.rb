# Color list
    # 41 -- red
    # 42 -- green
    # 43 -- yellow
    # 44 -- blue
    # 45 -- magenta
    # 46 -- cyan
    # 100 -- dark_gray
    # 107 -- white

class MasterMind < Array
    @@colors = ["\e[41m \e[0m", "\e[42m \e[0m", "\e[43m \e[0m", "\e[44m \e[0m", "\e[45m \e[0m", "\e[46m \e[0m", "\e[100m \e[0m", "\e[107m \e[0m"]
    @@row_num = 0
    
    attr_accessor :player_one, :player_two, :code_table, :rows, :pegs, :score_list
    
    def initialize(row_number, cell_number, default_value)
        super(row_number){Array.new(cell_number, default_value)}
        @player_one = ""
        @player_two = ""
        @code_table = %w(O O O O)
        @rows = "" # used to print colours with puts command in CLI
        @pegs = []
        @score_list = {
            master_mind_one: 0,
            master_mind_two: 0,
            last_player: ""
        }
    end

    def show_table
        self.each do |column|
            column.each_with_index do |item, idx|
                @rows << "  #{item}"
                if idx == 3
                    puts "#{@rows}\n--------------"
                    @rows = ""
                end
            end
        end

        @rows = ""
    end

    def show_available_colors
        i = 0
        j = 0
        while j <= @@colors.length-3 do
            numbered_color = @@colors[j].gsub(' ', " #{i} ")
            @rows << "  #{numbered_color}"
            if j >= 5
                break
            end
            i += 1
            j += 1
        end
        puts @rows
        @rows = ""
    end

    def add_colors_code_breaker
        puts "It is your turn, Code Breaker\n"
        
        color_number = 1
        4.times do
            puts "\nChoose color # #{color_number}"
            show_available_colors
            color = gets.chomp.to_i
            puts 'Choose the cell'
            cell = gets.chomp.to_i
            self[@@row_num][cell] = @@colors[color]
            self.each do |column|
                column.each_with_index do |item, idx|
                    @rows << "  #{item}"
                    if idx == 3
                        puts "#{@rows}\n--------------"
                        @rows = ""
                    end
                end
            end
            color_number += 1
        end
        @rows = ""
        check_round
    end

    def add_colors_master_mind 
        puts "\nColors you can choose from:"
        show_available_colors
        color_number = 1
        4.times do
            puts "\nChoose color # #{color_number}"
            color = gets.chomp.to_i
            puts 'Choose the cell'
            cell = gets.chomp.to_i
            @code_table[cell] = @@colors[color]
            @code_table.each do |item|
                @rows << "  #{item}"
            end
            color_number += 1
            puts @rows
            @rows = ""
        end
        system "clear"
        puts "Your code is"
        show_code_table
        puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
        confirm_code_input = gets.chomp
        until confirm_code_input == "1" || confirm_code_input == "2"
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
            confirm_code_input = gets.chomp
        end
        if confirm_code_input == '2'
            @code_table = %w(O O O O)
            system "clear"
            show_code_table
            add_colors_master_mind
        end
    end

    def play
        # Game start
        system "clear"
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
        system "clear" # Clear the CLI for better readability
        puts "Play...\n\n#{"\e[5m1\e[0m"}) vs AI\n#{"\e[5m2\e[0m"}) vs Player"
        play_against_input = gets.chomp
        until play_against_input == "1" || play_against_input == "2"
            player_choice
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
        system "sleep 1.5; clear"
        puts "Insert Player One Name"
        @player_one = gets.chomp
    end

    def human_play
        puts "Insert Player Two Name"
        @player_two = gets.chomp

        # Codebreaker and mastermind selection
        puts "\nWho is going to be the Master Mind?\nShuffling Odds\e[5m...\e[0m"
        system "sleep 3; clear"
        who_is_mastermind = [@player_one, @player_two].sample
        if who_is_mastermind == @player_one
            puts "The Master Mind is #{@player_one}!\n\nGood luck #{@player_two}"
        else
            puts "The Master Mind is #{@player_two}!\n\nGood luck #{@player_one}"
        end
        puts "\nPRESS #{"\e[5m1\e[0m"} TO CONTINUE"
        continue_game_input = gets.chomp
        until continue_game_input == "1" do
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONTINUE"
            continue_game_input = gets.chomp
        end
        system "clear"
        master_mind
    end
    
    def ai_play
        @player_two = 'AI'
    end
    
    def master_mind
        puts "Go Ahead MasterMind, Create Your Unbreakable Code Away From Prying Eyes\n\n"
        show_code_table
        add_colors_master_mind
        system "clear"
        add_colors_code_breaker
    end

    def check_round
        self[@@row_num].each_with_index do |item, idx|
            if code_table.include?(item) 
                if item == code_table[idx]
                    @pegs << "\e[100m \e[0m"
                else
                    @pegs << "\e[107m \e[0m"
                end
            end
        end
        
        @pegs.each {|peg| puts "\n#{peg}"}
        won = pegs.all? { |item| item == "\e[100m \e[0m" }
        if won
            puts "Code Breaker won"
            if @score_list[:last_player] == "master_mind_one"
                score_list[:master_mind_two] += (10 - @@row_num)
                @score_list[:last_player] = "master_mind_two"
            else
                score_list[:master_mind_one] += (10 - @@row_num)
                @score_list[:last_player] = "master_mind_one"
            end

            @@row_num = 0
            @code_table = %w(O O O O)
            master_mind
        end

        if @@row_num == 10 && !won
            if @score_list[:last_player] == "master_mind_one"
                score_list[:master_mind_two] += 11
                @score_list[:last_player] = "master_mind_two"
            else
                score_list[:master_mind_one] += 11
                @score_list[:last_player] = "master_mind_one"
            end

            @@row_num = 0
            @code_table = %w(O O O O)
            master_mind
        end

        @@row_num += 1
        add_colors_code_breaker
    end

    private
    def show_code_table
        @code_table.each_with_index do |item, idx|
            @rows << "  #{"\e[2mcell#{idx} ->\e[0m " + item}"
        end
        puts @rows
        @rows = ""
    end
end

master_mind_table = MasterMind.new(10, 4, "O")
master_mind_table.play
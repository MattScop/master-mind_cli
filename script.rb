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
    
    attr_accessor :player_one, :player_two, :code_table, :rows, :pegs, :score_list, :last_player, :row_num, :total_score, :who_is_mastermind, :who_is_codebreaker, :temp_array_check_round, :temp_array_code
    
    def initialize(row_number, cell_number, default_value)
        super(row_number){Array.new(cell_number, default_value)}
        @code_table = %w(O O O O)
        @rows = "" # used to print colours with puts command in CLI
        @pegs = []
        @last_player = ""
        @row_num = 0
        @temp_array_check_round = %w(O O O O)
        @temp_array_code = %w(O O O O)
        @total_score = 0
        @who_is_mastermind = ""
        @who_is_codebreaker = ""
    end

    def set_total_score
        system "clear"
        puts "Set the TOTAL SCORE for winning the game (min: 33)"
        @total_score = gets.chomp.to_i
        until @total_score.class == Integer && @total_score >= 33
            puts "Set the TOTAL SCORE for winning the game (min: 33)"
            @total_score = gets.chomp.to_i
        end
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

    def get_cell_number
        example_table = %w(O O O O)
        example_table.each_with_index do |item, idx|
            @rows << "  #{"\e[2mcell#{idx} ->\e[0m " + item}"
        end
        puts @rows
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
        puts "Your turn, #{@who_is_codebreaker}, do your best!\n\n"
        get_cell_number
        puts "\nColors you can choose from:"
        show_available_colors
        
        color_number = 1
        4.times do
            puts "\nChoose color # #{color_number}"
            color = gets.chomp.to_i
            puts 'Choose the cell'
            cell = gets.chomp.to_i
            if self[@row_num][cell] != "O"
                puts "\e[91mCell is already filled or doesn't exist, try again\e[0m"
                redo
            else
                self[@row_num][cell] = @@colors[color]
                @temp_array_check_round[cell] = @@colors[color]
            end
            self[@row_num].each do |item|
                    @rows << "  #{item}"
            end
                    
            color_number += 1
            puts @rows
            @rows = ""
        end
        puts "\nChecking the score#{"\e[5m...\e[0m"}"
        system "sleep 1.5; clear"
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
            if @code_table[cell] != "O"
                puts "\e[91mCell is already filled or doesn't exist, try again\e[0m"
                redo
            else
                @code_table[cell] = @@colors[color]
                @temp_array_code[cell] = @@colors[color]
            end
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
        set_total_score
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
        @score_list = {
            @player_one => 0,
        }
    end

    def human_play
        puts "Insert Player Two Name"
        @player_two = gets.chomp
        @score_list[@player_two] = 0

        # Codebreaker and mastermind selection
        puts "\nWho is going to be the Master Mind?\nShuffling Odds\e[5m...\e[0m"
        system "sleep 3; clear"
        @who_is_mastermind = [@player_one, @player_two].sample
        if @who_is_mastermind == @player_one
            @who_is_codebreaker = @player_two
            puts "The Master Mind is #{@player_one}!\n\nGood luck #{@player_two}"
        else
            @who_is_codebreaker = @player_one
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
        puts "Go Ahead #{@who_is_mastermind}, Create Your Unbreakable Code Away From Prying Eyes\n\n"
        show_code_table
        add_colors_master_mind
        system "clear"
        add_colors_code_breaker
    end

    def check_round
        @temp_array_check_round.each_with_index do |item, idx|
            if item == @temp_array_code[idx]
                @pegs << "\e[100m \e[0m"
                @temp_array_check_round.delete_at(idx)
                @temp_array_check_round.insert(idx, "O")
                @temp_array_code.delete_at(idx)
                @temp_array_code.insert(idx, "O")
            end
        end
        @temp_array_check_round.each_with_index do |item, idx|
            if @temp_array_code.include?(item) && item != @temp_array_check_round[idx]
                @pegs << "\e[107m \e[0m"
                # @temp_array_check_round.delete(item)
            end
        end

        # self[@row_num].each_with_index do |item, idx|
        #     if code_table.include?(item) && item == code_table[idx]
        #     else
        #         code_table.select {|code_item| code_item == item}
        #         end
        #     end
        # end
        
        @pegs.each do |peg|
            @rows << "  #{peg}"
        end
        if @rows.empty?
            puts "MasterMind feedback:\nNo Pegs\n\n"
        else
            puts "MasterMind feedback:\n#{@rows}\n\n"
        end
        @rows = ""
        show_table

        won = pegs.all? { |item| item == "\e[100m \e[0m" } && pegs.length == 4
        if won
            puts "\n#{"\e[92m#{@who_is_codebreaker} broke the code!\e[0m"}"
            if @last_player == "player_one"
                score_list[player_two] += @row_num
                @last_player = "player_two"
            else
                score_list[player_one] += @row_num
                @last_player = "player_one"
            end

            @row_num = 0
            @code_table = %w(O O O O)
            @temp_array_check_round = %w(O O O O)
            puts "\n#{show_table}\n#{show_code_table}"
            puts "\nSCORES"
            score_list.each {|key, value| puts key, value}
            puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
            next_round_game_input = gets.chomp
            until next_round_game_input == "1" do
                puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
                next_round_game_input = gets.chomp
            end
            puts "\nSwitching Roles#{"\e[5m...\e[0m"}"
            if @who_is_mastermind == @player_one
                @who_is_mastermind = @player_two
                @who_is_codebreaker = @player_one
            elsif @who_is_mastermind == @player_two
                @who_is_mastermind = @player_one
                @who_is_codebreaker = @player_two
            end
            system "sleep 1.5; clear"
            master_mind
        end

        if @row_num == 10 && !won
            puts "\n#{"\e[92m#{@@who_is_mastermind}'code was unbreakable!\e[0m"}"
            if @last_player == "player_one"
                score_list[player_two] += 11
                @last_player = "player_two"
            else
                score_list[player_one] += 11
                @last_player = "player_one"
            end

            @row_num = 0
            @code_table = %w(O O O O)
            @temp_array_check_round = %w(O O O O)
            puts "\n#{show_table}\n#{show_code_table}"
            puts "\nSCORES"
            score_list.each {|key, value| puts key, value}
            puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
            next_round_game_input = gets.chomp
            until next_round_game_input == "1" do
                puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
                next_round_game_input = gets.chomp
            end
            puts "\nSwitching Roles#{"\e[5m...\e[0m"}"
            system "sleep 1.5; clear"
            master_mind
        end

        @row_num += 1
        @pegs = []
        @temp_array_check_round = %w(O O O O)
        puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
        next_round_game_input = gets.chomp
        until next_round_game_input == "1" do
            puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
            next_round_game_input = gets.chomp
        end
        system "clear"
        add_colors_code_breaker
    end

    def check_score
        if score_list[@player_one] >= @total_score
            puts @player_one + " won"
        elsif score_list[@player_two] >= @total_score
            puts @player_two + " won"
        end
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
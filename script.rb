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
    @@COLORS = ["\e[41m \e[0m", "\e[42m \e[0m", "\e[43m \e[0m", "\e[44m \e[0m", "\e[45m \e[0m", "\e[46m \e[0m", "\e[100m \e[0m", "\e[107m \e[0m"]
    @@COLORS_AI = ["\e[41m \e[0m", "\e[42m \e[0m", "\e[43m \e[0m", "\e[44m \e[0m", "\e[45m \e[0m", "\e[46m \e[0m"]
    
    def initialize(row_number, cell_number, default_value)
        super(row_number) { Array.new(cell_number, default_value) }
        @peg_array = Array.new(10) { Array.new }
        @master_mind_code_table = %w(O O O O)
        @duplicate_current_table_line = %w(O O O O) # dup for non distructive changes
        @table_line_number = 0
        @total_score = 0
        @who_is_mastermind = ''
        @who_is_codebreaker = ''
        @print = '' # used to print colours with 'puts' command in CLI
        @random_colors_ai = @@COLORS_AI.sample(2)
        @blacklist_colors_ai = [] # colors to be removed from ai choice options
        @yellowlist_colors_ai = [] # colors temporary removed from ai choice options
        @idx_temp_removed_colors = {} # for ai. Storage for index of temporary removed colors
    end

    def play
        # Game start
        system 'clear'
        greetings = "*************************\n* " + "\e[93mWELCOME TO MASTERMIND\e[0m" + " *\n*************************\n\n#{"\e[1;4mMAKE THE TERMINAL WINDOW FULL SIZE\e[0m"}\n\n\e[3;93mFor Game Rules, Check The README in the Repo\e[0m"
        puts greetings + "\n\nPRESS #{"\e[5m1\e[0m"} TO START THE GAME"
        start_game_input = gets.chomp
        until start_game_input == '1' do
            puts "\nPRESS #{"\e[5m1\e[0m"} TO START THE GAME"
            start_game_input = gets.chomp
        end
        set_total_score
        player_choice
    end

    private

    def set_total_score
        system 'clear'
        puts 'Set the TOTAL SCORE for winning the game (min: 33)'
        @total_score = gets.chomp.to_i
        until @total_score.class == Integer && @total_score >= 33
            puts 'Set the TOTAL SCORE for winning the game (min: 33)'
            @total_score = gets.chomp.to_i
        end
    end

    def player_choice 
        system 'clear'
        puts "Play...\n\n#{"\e[5m1\e[0m"}) vs AI\n#{"\e[5m2\e[0m"}) vs Player"
        play_against_input = gets.chomp
        until play_against_input == '1' || play_against_input == '2'
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
        system 'sleep 1.5; clear'
        puts 'Insert Player One Name'
        # declaring two instance variables below
        @player_one = gets.chomp
        @score_list = { @player_one => 0 }
    end

    def human_play
        puts 'Insert Player Two Name'
        # declaring instance variable
        @player_two = gets.chomp
        while @player_two == 'AI' do
            puts 'This name is reserved, please try another name'
            @player_two = gets.chomp
        end
        @score_list[@player_two] = 0

        # Codebreaker and mastermind selection
        puts "\nWho is going to be the Master Mind?\nShuffling Odds\e[5m...\e[0m"
        system 'sleep 3; clear'
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
        until continue_game_input == '1' do
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONTINUE"
            continue_game_input = gets.chomp
        end
        system 'clear'
        master_mind
    end

    def ai_play
        @player_two = 'AI'
        @score_list[@player_two] = 0

        # Codebreaker and mastermind selection
        puts "\nWho is going to be the Master Mind?\nShuffling Odds\e[5m...\e[0m"
        system "sleep 3; clear"
        @who_is_mastermind = [@player_one, @player_two].sample
        if @who_is_mastermind == @player_one
            @who_is_codebreaker = @player_two
            puts "You are the Master Mind!"
        else
            @who_is_codebreaker = @player_one
            puts "The Master Mind is #{@player_two}!\n\nGood luck #{@player_one}"
        end
        puts "\nPRESS #{"\e[5m1\e[0m"} TO CONTINUE"
        continue_game_input = gets.chomp
        until continue_game_input == '1' do
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONTINUE"
            continue_game_input = gets.chomp
        end
        system 'clear'
        if @who_is_mastermind == @player_one
            master_mind
        else
            master_mind_ai_play
        end
    end

    def master_mind
        puts "Go Ahead #{@who_is_mastermind}, Create Your Unbreakable Code Away From Prying Eyes\n\n"
        show_code_table
        add_colors_master_mind
        system 'clear'
        if @player_two == 'AI'
            ai_strategy
        else
            add_colors_code_breaker
        end
    end

    def master_mind_ai_play
        # grab 4 random numbers from colors_ai array and place them inside the code table
        i = 0
        while i < @master_mind_code_table.length
            @master_mind_code_table[i] = @@COLORS_AI.sample
            i += 1
        end
        puts "AI Generated the Code\n\n"
        add_colors_code_breaker
    end

    def show_code_table
        @master_mind_code_table.each_with_index do |item, idx|
            @print << "  #{"\e[2mcell#{idx} ->\e[0m " + item}"
        end
        puts @print
        @print = ''
    end

    def add_colors_master_mind 
        puts "\nColors you can choose from:"
        show_available_colors
        color_number = 1
        4.times do
            puts "\nChoose color # #{color_number}"
            color = gets.chomp.to_i
            if !@@COLORS[color]
                puts "\e[91mColor doesn't exist, try again\e[0m"
                redo
            end
            puts 'Choose the cell'
            cell = gets.chomp.to_i
            if @master_mind_code_table[cell] != 'O'
                puts "\e[91mCell is already filled or doesn't exist, try again\e[0m"
                redo
            else
                @master_mind_code_table[cell] = @@COLORS[color]
            end
            @master_mind_code_table.each do |item|
                @print << "  #{item}"
            end
            color_number += 1
            puts @print
            @print = ''
        end
        system 'clear'
        puts 'Your code is'
        show_code_table
        puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
        confirm_code_input = gets.chomp
        until confirm_code_input == "1" || confirm_code_input == "2"
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
            confirm_code_input = gets.chomp
        end
        if confirm_code_input == '2'
            @master_mind_code_table = %w(O O O O) # reset code table
            system 'clear'
            show_code_table
            add_colors_master_mind
        end
    end

    def show_available_colors
        # show all the colors except for black and white
        i = 0
        j = 0
        while j <= @@COLORS.length-3 do
            numbered_color = @@COLORS[j].gsub(' ', " #{i} ")
            @print << "  #{numbered_color}"
            if j >= 5
                break
            end
            i += 1
            j += 1
        end
        puts @print
        @print = ''
    end

    def add_colors_code_breaker
        puts "Try to break the code, #{@who_is_codebreaker}. Do your best!\n\n"
        get_cell_number
        puts "\nColors you can choose from:"
        show_available_colors
        color_number = 1
        4.times do
            puts "\nChoose color # #{color_number}"
            color = gets.chomp.to_i
            if !@@COLORS[color]
                puts "\e[91mColor doesn't exist, try again\e[0m"
                redo
            end
            puts 'Choose the cell'
            cell = gets.chomp.to_i
            if self[@table_line_number][cell] != 'O'
                puts "\e[91mCell is already filled or doesn't exist, try again\e[0m"
                redo
            else
                self[@table_line_number][cell] = @@COLORS[color]
                @duplicate_current_table_line[cell] = @@COLORS[color]
            end

            self[@table_line_number].each do |item|
                @print << "  #{item}"
            end
            color_number += 1
            puts @print
            @print = ''
        end
        system 'clear'
        puts 'Your combination is'
        self[@table_line_number].each_with_index do |item, idx|
            @print << "  #{"\e[2mcell#{idx} ->\e[0m " + item}"
        end
        puts @print
        @print = ''
        puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
        confirm_combination_input = gets.chomp
        until confirm_combination_input == '1' || confirm_combination_input == '2'
            puts "\nPRESS #{"\e[5m1\e[0m"} TO CONFIRM OR #{"\e[5m2\e[0m"} TO CHANGE IT"
            confirm_combination_input = gets.chomp
        end
        if confirm_combination_input == '2'
            self[@table_line_number] = %w(O O O O)
            @duplicate_current_table_line = %w(O O O O)
            system 'clear'
            add_colors_code_breaker
        end
        puts "\nChecking the score#{"\e[5m...\e[0m"}"
        system 'sleep 1.5; clear'
        check_round
    end

    def ai_strategy
        total_black_pegs = @peg_array[@table_line_number - 1].select { |peg| peg == "\e[100m \e[0m" }
        total_white_pegs = @peg_array[@table_line_number - 1].select { |peg| peg == "\e[107m \e[0m" }
        total_pegs = total_black_pegs.length + total_white_pegs.length
        
        if @table_line_number.zero?
            # add two of each color on first round
            @random_colors_ai = @@COLORS_AI.sample(2)
            i = 0
            while i < 4
                if i < 2
                    self[@table_line_number][i] = @random_colors_ai[0]
                    @duplicate_current_table_line[i] = @random_colors_ai[0]
                else
                    self[@table_line_number][i] = @random_colors_ai[1]
                    @duplicate_current_table_line[i] = @random_colors_ai[1]
                end
                i += 1
            end
        elsif @peg_array[@table_line_number - 1].empty?
            # no pegs case
            # grab two different colours while placing the first two in the blacklist
            @random_colors_ai.each { |item| @blacklist_colors_ai << item }
            if @@COLORS_AI.difference(@blacklist_colors_ai).length < 2
                @random_colors_ai = @@COLORS_AI.difference(@blacklist_colors_ai).union(@yellowlist_colors_ai).sample(2)
            else
                @random_colors_ai = @@COLORS_AI.difference(@blacklist_colors_ai).sample(2)
            end
            @blacklist_colors_ai.uniq!
            @yellowlist_colors_ai.uniq!
            i = 0
            while i < 4
                if i < 2
                    self[@table_line_number][i] = @random_colors_ai[0]
                    @duplicate_current_table_line[i] = @random_colors_ai[0]
                else
                    self[@table_line_number][i] = @random_colors_ai[1]
                    @duplicate_current_table_line[i] = @random_colors_ai[1]
                end
                i += 1
            end
        else
            # for each peg missing , change one color.
            # for each white peg, change the position of one different cell
            colors_to_be_removed = self[@table_line_number - 1].sample(4 - total_pegs)
            colors_to_be_switched = self[@table_line_number - 1].difference(colors_to_be_removed).sample(total_white_pegs.length)
            colors_to_be_removed.each do |color|
                @blacklist_colors_ai << color
                @yellowlist_colors_ai << color
            end
            @blacklist_colors_ai.uniq!
            @yellowlist_colors_ai.uniq!
            if @@COLORS_AI.difference(@blacklist_colors_ai).length < colors_to_be_removed.length
                @random_colors_ai = @@COLORS_AI.difference(@blacklist_colors_ai).union(@yellowlist_colors_ai).sample(colors_to_be_removed.length)
            else
                @random_colors_ai = @@COLORS_AI.difference(@blacklist_colors_ai).sample(colors_to_be_removed.length)
            end
            i = 0
            k = 0
            j = 1
            while i < 4
                if colors_to_be_removed.include?(self[@table_line_number - 1][i]) && @random_colors_ai.length > k
                    self[@table_line_number][i] = @random_colors_ai[k]
                    @duplicate_current_table_line[i] = @random_colors_ai[k]
                    k += 1
                elsif colors_to_be_switched.include?(self[@table_line_number - 1][i]) && colors_to_be_switched.length >= j
                    self[@table_line_number][i] = self[@table_line_number - 1][i]
                    @duplicate_current_table_line[i] = self[@table_line_number - 1][i]
                    color_register = self[@table_line_number - 1][i]
                    if !@idx_temp_removed_colors.include?(color_register)
                        @idx_temp_removed_colors[color_register] = []
                    end
                    if !@idx_temp_removed_colors[color_register].include?(i)
                        @idx_temp_removed_colors[color_register] << i
                    end
                    j += 1
                else
                    self[@table_line_number][i] = self[@table_line_number - 1][i]
                    @duplicate_current_table_line[i] = self[@table_line_number - 1][i]
                end
                i += 1
            end
            # shuffle
            # while the two colors in color_to_be_switched have an index present in hash, shuffle
            colors_to_be_switched.each do |color|
                to_redo = false
                self[@table_line_number].shuffle
                @duplicate_current_table_line.shuffle
                self[@table_line_number].each_with_index do |cell, idx|
                    if cell == color && @idx_temp_removed_colors[cell].include?(idx)
                        to_redo = true
                    end
                end
                if to_redo
                    to_redo = false
                    redo
                end
            end
        end
        system 'clear'
        puts "Checking the score#{"\e[5m...\e[0m"}"
        system 'sleep 1.5; clear'
        check_round
    end

    def get_cell_number
        temp_table = %w(O O O O)
        temp_table.each_with_index do |item, idx|
            @print << "  #{"\e[2mcell#{idx} ->\e[0m " + item}"
        end
        puts @print
        @print = ''
    end

    def check_round
        dup_code_table = @master_mind_code_table.dup
        @duplicate_current_table_line.each_with_index do |item, idx|
            # if color and position match >> black peg
            if item == dup_code_table[idx]
                @peg_array[@table_line_number] << "\e[100m \e[0m"
                @duplicate_current_table_line.delete_at(idx)
                @duplicate_current_table_line.insert(idx, 0)
                dup_code_table.delete_at(idx)
                dup_code_table.insert(idx, 'O')
            # if only color matches >> white peg
            elsif dup_code_table.include?(item) && dup_code_table[idx] != @duplicate_current_table_line[idx]
                @peg_array[@table_line_number] << "\e[107m \e[0m"
            end
        end
        # print pegs
        @peg_array[@table_line_number].each do |peg|
            @print << "  #{peg}"
        end
        if @print.empty?
            puts "MasterMind feedback:\nNo Pegs\n\n"
        else
            puts "MasterMind feedback:\n#{@print}\n\n"
        end
        @print = ''
        show_table

        won = @peg_array[@table_line_number].all? { |item| item == "\e[100m \e[0m" } && @peg_array[@table_line_number].length == 4

        if won
            puts "\n#{"\e[92m#{@who_is_codebreaker} broke the code!\e[0m"}\n"
            # insert scores
            if @who_is_mastermind == @player_two
                score_list[player_two] += @table_line_number
            else
                score_list[player_one] += @table_line_number
            end
            puts "\nMasterMind Code was:"
            show_code_table

            # reset values
            @table_line_number = 0
            @peg_array.each do |row|
                row.replace([])
            end
            self.each do |row|
                row.replace(%w(O O O O))
            end
            @master_mind_code_table = %w(O O O O)
            @duplicate_current_table_line = %w(O O O O)
            puts "\nSCORES"
            score_list.each { |key, value| puts key, value }
            check_score
        elsif @table_line_number == 9 && !won
            puts "\n#{"\e[92m#{@who_is_mastermind}'s code was unbreakable!\e[0m"}"
            if @who_is_mastermind == @player_two
                score_list[player_two] += 11
            else
                score_list[player_one] += 11
            end
            puts "\nMasterMind Code was:"
            show_code_table

            # reset values
            @table_line_number = 0
            peg_array.each do |row|
                row.replace([])
            end
            self.each do |row|
                row.replace(%w(O O O O))
            end
            @master_mind_code_table = %w(O O O O)
            @duplicate_current_table_line = %w(O O O O)
            # puts "\n#{show_table}\n#{show_code_table}"
            puts "\nSCORES"
            score_list.each { |key, value| puts key, value }
            check_score
        else
            @table_line_number += 1
            @duplicate_current_table_line = %w(O O O O)
            puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
            next_round_game_input = gets.chomp
            until next_round_game_input == '1' do
                puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT ROUND"
                next_round_game_input = gets.chomp
            end
            system 'clear'
            puts "ROUND # #{@table_line_number + 1}"
            if @player_two == 'AI' && @player_two != @who_is_mastermind
                ai_strategy
            else
                add_colors_code_breaker
            end
        end
    end

    def show_table
        i = 0
        temp_peg_row = ''
        self.each do |column|
            column.each_with_index do |item, idx|
                @print << "  #{item}"
                if @peg_array[idx] && i < @table_line_number
                    temp_peg_row << "  #{@peg_array[i][idx]}"
                end
                if idx == 3 # go next line
                    puts "#{@print}   #{temp_peg_row}\n--------------"
                    @print = ''
                    temp_peg_row = ''
                    i += 1
                end
            end
        end
        @print = ''
    end

    def check_score
        if score_list[@player_one] >= @total_score
            puts "\n\n\e[7m#{@player_one.upcase} WON THE GAME\e[0m"
            puts "\nPRESS #{"\e[5m1\e[0m"} TO PLAY ANOTHER GAME"
            next_game_input = gets.chomp
            until next_game_input == "1" do
                puts "\nPRESS #{"\e[5m1\e[0m"} TO PLAY ANOTHER GAME"
                next_game_input = gets.chomp
            end
            set_total_score
            player_choice
        elsif score_list[@player_two] >= @total_score
            puts "\n\n\e[7m#{@player_two.upcase} WON THE GAME\e[0m"
            puts "\nPRESS #{"\e[5m1\e[0m"} TO PLAY ANOTHER GAME"
            next_game_input = gets.chomp
            until next_game_input == "1" do
                puts "\nPRESS #{"\e[5m1\e[0m"} TO PLAY ANOTHER GAME"
                next_game_input = gets.chomp
            end
            set_total_score
            player_choice
        else
            puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT GAME"
            next_input = gets.chomp
            until next_input == '1' do
                puts "\nPRESS #{"\e[5m1\e[0m"} FOR THE NEXT GAME"
                next_input = gets.chomp
            end
            puts "\nSwitching Roles#{"\e[5m...\e[0m"}"
            if @who_is_mastermind == @player_one
                @who_is_mastermind = @player_two
                @who_is_codebreaker = @player_one
            elsif @who_is_mastermind == @player_two
                @who_is_mastermind = @player_one
                @who_is_codebreaker = @player_two
            end
            system 'sleep 1.5; clear'
            if @player_two == 'AI' && @player_two == @who_is_mastermind
                master_mind_ai_play
            else
                master_mind
            end
        end
    end
end
master_mind_table = MasterMind.new(10, 4, 'O')
master_mind_table.play

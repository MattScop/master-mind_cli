# master-mind_cli

![MASTERMIND-WALLPAPER](./img/Mastermind.jpg)

# Project from TOP lesson, designed to be playable on CLI.

> RULES
- 8 colors
- 12 rows
- duplicates are allowed

The game consists of two players, the <b>master-mind</b>, which is the one creating a code of 4 colors and the <b>codebreaker</b>,
the one who must guess what the code is within 12 tries. On each try the master-mind must provide feedback with:
- white peg if a color is present in the code but in the wrong position
- black pag if a color is present in the code and is in the correct position

If the codebreaker guesses the correct code within the 12 tries, the master-mind gains a point for each failed try.\
If the codebreaker doesn't guess the correct code within the 12 tries, the master-mind gains 12 points + 1.\
The roles are then switched.\
The game ends when one of the players reaches the amount of points set before the game started (an even number).

> SOURCE
- Link to the lesson [HERE](https://www.theodinproject.com/lessons/ruby-mastermind)
- Wallpaper https://it.wikipedia.org/wiki/Mastermind
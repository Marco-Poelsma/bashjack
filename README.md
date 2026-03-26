# BashJack: A shell terminal blackjack.

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

Welcome to BashJack! This project is a class assignment where I had to make a shell script that lets the user play blackjack.

## Usage

BashJack has 3 main modes:

- Card draw mode.
- Blackjack mode.
- Deck (re)initialisation.

Due to the use of functions on this script, it is restricted to sudo mode only... so either trust me or check out the code yourself.

### Activating card draw mode

This mode will let you draw one card from the deck. To do so, use `sudo bash cards.sh draw`.

### Activating blackjack mode

This mode will let you play blackjack. To do so, use `sudo bash cards.sh blackjack`.

### Deck (re)initialisation mode

The default mode for BashJack. If you use any input parametre other than `draw` or `blackjack` (incl. nothing at all), the program will default to reinitialising the deck. 

> [!TIP]
> Blackjack mode reinitialises the deck before running, so you do not have to run this command before playing blackjack.


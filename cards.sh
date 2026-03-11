#!/bin/bash

# This function prints all items in an array
print_drawn_cards() {
	for i in "${@}"; do #Using an array iterator
		echo $i
	done
}

# Serves as a general reinitaliser for the deck
init() {
	touch cards.txt # Create our cards file if it doesn't exist
	echo -n "" > cards.txt # Delete its content if it exists
	for suit in "Spades" "Hearts" "Clubs" "Diamonds" ; do # We iterate over suit
		for j in {1..13}; do # We iterate over the ranks
			case $j in # Let's rename some suits for better legibility
				1) # So rank 1 will be an Ace
					value="Ace" 
					;;
				11) # Rank 11 is a Jack
					value="Jack"
					;;
				12) # Rank 12 is a Queen
					value="Queen"
					;;
				13) # Rank 13 is a King
					value="King"
					;;
				*) # Every other rank can be kept the same (mainly because I don't want to 
				   # literally transcribe all of the values for all of the cards).
					value=$j
					;;
			esac
			echo "$value of $suit" >> cards.txt # We can append each line to our cards file
		done
	done
}

# Draw a card, any card...
draw() {
	local n_linies=$(wc -l < cards.txt) # First figure out how many cards we have in our deck
	local linia=$(( (RANDOM % n_linies) + 1)) # Then select a random line
	local drawn_card=$(sed -n "${linia}p" cards.txt) # And view its data
	sed -i "${linia}d" cards.txt # Finally we will delete this card from the deck
	                             # (afeter all, it's no longer there)
	echo $drawn_card # A bit janky, but apparently this is how we can return values from functions...
}

# Check how much your hand is worth (hopefully 21)
get_hand_value() {
	local total=0
	local aces=0

	for card in "${@}"; do
		local rank="${card%% *}" # We don't care about the suit. We just need to know
					 # the value of everything before the first space
		case "$rank" in
			Ace)
				aces=$(( aces + 1 )) # Aces can be 1 or 11. We'll keep track of them
						     # To avoid bust when we can count them as 1.
				total=$(( total + 10 ))
				;;
			Jack|Queen|King) # These are all worth 10
				total=$(( total + 10 ))
				;;
			*) # And the rest of the cards are worth their rank
				total=$(( total + rank ))
				;;
		esac
	done
	while [ $aces -gt 0 ] && [ $total -gt 21 ]; do #And here we downgrade aces as needed.
		total=$(( total - 10 ))
		aces=$(( aces - 1 ))
	done

	echo $total # Return the total worth of the player's hand
}


if [ "$1" = "draw" ]; then # sudo bash cards.sh draw -- Returns a card (any card) and removes it from the deck
	draw
elif [ "$1" = "blackjack" ]; then # LET'S GO GAMBLING! LET'S GO GAMBLING! LET'S GO GAMBLING!!!!!!!!
	echo "You're playing black jack. Good luck!"
	init

	drawn_cards=() # Initialise card array for player
	drawn_cards+=("$(draw)") # Always draw two cards when you start a game.
	drawn_cards+=("$(draw)")
	echo "Your cards:"
	print_drawn_cards "${drawn_cards[@]}" # And show them to keep track of them
	echo "Hand value: $(get_hand_value "${drawn_cards[@]}")" # Also show the value (it's easier to visualise)

	dealer_cards=() # Initialise card array for dealer
	dealer_cards+=("$(draw)") # Draw two
	dealer_cards+=("$(draw)")
	echo "Dealer's cards:"
	print_drawn_cards "${dealer_cards[@]}" # Show cards
	echo "Hand value: $(get_hand_value "${dealer_cards[@]}")" # And print the card value
	match_ended=false # I might delete this later... for now it's here.
	while true; do
		
		while true; do # Error checking loop for player
			# read -p does not support escape characters, so I'm just going to
			# handle those by adding a menu with echo
			echo -e "Hit or stand?\nHit - h\nStand - s"
			read -p "Your choice: " choice # Also adding a prompt for clarity
			case "$choice" in
				h|H) # HIT
					drawn_cards+=("$(draw)") # Draw a card
					echo "Your cards:"
					print_drawn_cards "${drawn_cards[@]}" # Show cards and total value beneath
					echo "Your hand value is $(get_hand_value "${drawn_cards[@]}")"
					break # We can stop error checking
					;;
				s|S) # STAND
					echo "You stand. Final hand:"
					print_drawn_cards "${drawn_cards[@]}" # Final hand cards
					echo "With value: $(get_hand_value "${drawn_cards[@]}")" # And their value
					match_ended=true # TEMP: Set match end boolean to true
					break # We can stop error checking
					;;
				*) # INVALID INPUT
					echo "Please introduce a valid choice."
					;;
			esac
		done

		# I'm going to add some very simple logic for the dealer here. If the value of their hand
		# is less than 17, the dealer will hit. Otherwise, they will stand. It's not the best,
		# but it's better than nothing.
		# I want it to be based on turns, like the real game
		if [ $(get_hand_value "${dealer_cards[@]}") -lt 17 ]; then
			echo "The dealer hits."
			dealer_cards+=("$(draw)") # The dealer draws
			echo "Dealer's hand:"
			print_drawn_cards "${dealer_cards[@]}" # We show their hand
			echo "The dealer's hand value is $(get_hand_value "${dealer_cards[@]}")" # And the value
		else
			echo "The dealer stands."
			echo "Dealer's hand:"
			print_drawn_cards "${dealer_cards[@]}" # Show dealer's hand
			echo "Dealer hand value: $(get_hand_value "${dealer_cards[@]}")" # And value
		fi

		# And obviously we can exit the game if:
		# - both players stand,
		# - either player busts,
		# - or if there's blackjack
		# TODO: Add match end checks
		if [ "$match_ended" = true ]; then 
			break
		fi

	done
else # Default to deck reinitialisation if anything other than "draw" or "blackjack" is passed
     # As an input parametre
	echo "No parametres detected. Defaulting to deck reinitalisation"
	init
fi

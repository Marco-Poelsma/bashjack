#!/bin/bash
print_drawn_cards() {
	for i in "${@}"; do
		echo $i
	done
}

init() {
	touch cards.txt
	echo -n "" > cards.txt
	for suit in "Spades" "Hearts" "Clubs" "Diamonds" ; do
		for j in {1..13}; do
			case $j in
				1)
					value="Ace"
					;;
				11)
					value="Jack"
					;;
				12)
					value="Queen"
					;;
				13)
					value="King"
					;;
				*)
					value=$j
					;;
			esac
			echo "$value of $suit" >> cards.txt
		done
	done
}

draw() {
	local n_linies=$(wc -l < cards.txt)
	local linia=$(( (RANDOM % n_linies) + 1))
	local drawn_card=$(sed -n "${linia}p" cards.txt)
	sed -i "${linia}d" cards.txt
	echo $drawn_card
}

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

	echo $total
}


if [ "$1" = "draw" ]; then
	draw
elif [ "$1" = "blackjack" ]; then
	echo "You're playing black jack. Good luck!"
	init

	drawn_cards=()
	drawn_cards+=("$(draw)")
	drawn_cards+=("$(draw)")
	echo "Your cards:"
	print_drawn_cards "${drawn_cards[@]}"

	dealer_cards=()
	dealer_cards+=("$(draw)")
	dealer_cards+=("$(draw)")
	echo "Dealer's cards:"
	print_drawn_cards "${dealer_cards[@]}"
	echo "Hand value: $(get_hand_value "${drawn_cards[@]}")"	
	match_ended=false
	while true; do
		
		while true; do # Error checking loop for player
			read -p "Hit or stand?\nHit - h\nStand - s\n" choice
			case "$choice" in
				h|H)
					drawn_cards+=("$(draw)")
					echo "Your cards:"
					print_drawn_cards "${drawn_cards[@]}"
					echo "Your hand value is $(get_hand_value "${drawn_cards[@]}")"
					break
					;;
				s|S)
					echo "You stand. Final hand:"
					print_drawn_cards "${drawn_cards[@]}"
					match_ended=true
					break
					;;
				*)
					echo "Please introduce a valid choice."
					;;
			esac
		done

		# I'm going to add some very simple logic for the dealer here. If the value of their hand
		# is less than 17, the dealer will hit. Otherwise, they will stand. It's not the best,
		# but it's better than nothing.
		if [ $(get_hand_value "${dealer_cards[@]}") -lt 17 ]; then
			echo "The dealer hits."
			dealer_cards+=("$(draw)")
			echo "Dealer's hand:"
			print_drawn_cards "${dealer_cards[@]}"
			echo "The dealer's hand value is $(get_hand_value "${drawn_cards[@]}")"
		else
			echo "The dealer stands."
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
else
	echo "No parametres detected. Defaulting to deck reinitalisation"
	init
fi

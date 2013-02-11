#Things to do
# 1)change @@all_cards Done
# 2) change @order into a class variable to ease the access. DONE
# 3) make the necesery changes due to number 2 Done
# 4) handle the ace's Done
# 5) test! In Progrses
# 6) class variables are not directly accessible dammit!, find a way around it  Done
# 7) Hand calls should be changed to deck pointer Done


#Known Issues
#Under Unknown conditions, it states that an Ace was dealt even if it was not
#Dealer getting an Ace crashes the program, add a small decision maker class for dealer, repackage dealer attributes

#------------------------------------------------------------CLASS Begin----------------------------------------------------------
class Deck

	#@@order[x][y]
	#@@order x represents the position within the deck, there are 52 positions within the deck 
	#@@order y represents the card type such as clubs(when 0) and card value such as J(when 1)  
	#@@Deck_pointer
	#This pointr refers to the location of the deck that has been progressed to
	def initialize
		@@order = Array.new(52).map!{Array.new(2)}
		@@deck_pointer = 0
		ran_number = 0
		puts "Please wait, randomizing cards"
		["Club","Diamond","Heart","Spade"].each do |card|
			["A",2,3,4,5,6,7,8,9,10,"J","Q","K"].each do |value|
				while 1 do	#Randomising the order on the deck
					ran_number = rand(52)
					if  @@order[ran_number][0] == nil
						@@order[ran_number][0] = value.to_s + " " + card
						value = 10 if value == "J" || value == "Q" || value == "K"  
						@@order[ran_number][1] = value     
						break
					end
				end
			end
		end
		puts "Complete! Starting Application"
	end

	def self.access_deck(suit_or_value)
		@@deck_pointer += 1
		if suit_or_value == 0 #suit
			return @@order[(@@deck_pointer - 1)][0]
		else
			return @@order[(@@deck_pointer - 2)][1]
		end
	end

end
#------------------------------------------------------------CLASS END------------------------------------------------------------

#------------------------------------------------------------CLASS Begin----------------------------------------------------------
class Hand 

	def initialize(name) #distributes initial cards
		@hand = Array.new(52).map!{Array.new(2)}
		@name = name
		@hand[0][0] = Deck.access_deck(0)
		@hand[0][1] = Deck.access_deck(1)
		if @hand[0][1] == "A"
			@hand[0][1] = Hand.case_check
		end 
		@hand[1][0] = Deck.access_deck(0)
		@hand[1][1] = Deck.access_deck(1)
		if @hand[1][1] == "A"	
			@hand[1][1] = Hand.case_check
		end 
		@cards_held = 2 #Cards held by this player/dealer used to navigate the hand
		@total = 0      #Contains the total of the player/dealers hand
	end

	def hit_me # Distributes additional Cards
		@hand[@cards_held][0] = Deck.access_deck(0)
		@hand[@cards_held][1] = Deck.access_deck(1)
		if @hand[@cards_held][1] == "A"
			@hand[@cards_held][1] = Hand.case_check
		end  
		@cards_held += 1
		return @hand[@cards_held][1]
	end

	#This Method returns the requested cards
	def hand_query(row,col,auto)
		if auto == 1
			return @hand[(@cards_held - 1)][col]
		else
		 	return @hand[row][col]
		end
	end

	#This Method returns the total card values of this players hand
	def total_query
		@total = 0
		@cards_held.times do |x|
			@total += hand_query(x,1,0)
		end
		return @total
	end

	#This method checks if the dealt card is an named card
	def self.case_check 
		flag = 1
		case State.state_query  
			when 1
				puts "You have been dealt an Ace, please choose a value of either 1 or 11"
				while flag do
					ace_value = gets.chomp
					if ace_value == "1"
						flag = 0
						return 1
					elsif ace_value == "11"
						flag = 0
						return 11
					else 
						puts "That was not a valid command, please type either 1 or 11"
						flag = 1
					end 
				end
			else
				puts "Dealer has been dealt an Ace"	
				if dealer.total_query <=10 
					puts "Dealer has chosen 11"
					return 11
				else 
					puts "Dealer has chosen 1"
					return 1
				end
		end		
	end
end
#------------------------------------------------------------CLASS END------------------------------------------------------------

#------------------------------------------------------------CLASS Begin----------------------------------------------------------
class State

	def initialize
		@@state = 1
	end

	def self.change_state(state)
		@@state = state
		self.state_query
	end

	def self.state_query
		return @@state
	end

end
#------------------------------------------------------------CLASS END------------------------------------------------------------


#------------------------------------------------------------- Main --------------------------------------------------------------


#Preparing instances and initial setups
#initializing the inital state of the code
#1 = players turn
#2 = dealer turn
#3 = comparison
#4 = game over
state = State.new
puts"---------------------------------------------------------------------------------------------"
deck = Deck.new()
puts "Name please?"
player_name = gets.chomp
player = Hand.new(player_name)
dealer = Hand.new("Dealer")

puts "Welcome #{player_name}!. Yours Cards are: " + player.hand_query(0,0,0) + " and " + player.hand_query(1,0,0) 
puts "Your current running total is #{player.total_query}"  
puts "type h for HITME! and s for stay"
puts"---------------------------------------------------------------------------------------------"


while true do
	case State.state_query
		when 1 
			while true do
				if player.total_query == 21
					puts "You lucky person! you've already won!"
					State.change_state(4)
					break
				end
				puts "#{player_name}, What would you like to do?"
		        move = gets.chomp
		        if move == "h"
		        	player.hit_me
		        	puts "Your new card is " + player.hand_query(0,0,1)
		        	puts "Your new total is #{player.total_query}" 
		        	if player.total_query == 21
		        		puts "Congratulations you win!"
		        		State.change_state(4)
		        		break
		        	elsif player.total_query > 21
		        		puts "You loose!"
		        		State.change_state(4)
		        		break
		        	end
		        	State.change_state(1)

		        elsif move == "s"
		        	puts "#{player_name} Stays, with a total of #{player.total_query}, dealers turn"
		        	State.change_state(2)
		        	break
		        else 
		        	puts "Unrecognised command Try again"
		        	State.change_state(1)
		        end
		    end
	    when 2 
	    	while true do
		       	puts "Dealers current total is #{dealer.total_query}"
		       	if dealer.total_query < 17
		       		puts "Dealer draws a card"
		       		dealer.hit_me
		       		State.change_state(2)
		       		break
		       	elsif (dealer.total_query >= 17) && (dealer.total_query < 21)
		       		puts "Dealer Stays"
		       		State.change_state(3)
		       		break
		       	elsif dealer.total_query == 21
		       		puts "Dealer wins!"
		       		State.change_state(4)
		       		break
		       	elsif dealer.total_query > 21
		       		puts "#{player_name} Wins!"
		       		State.change_state(4)
		       		break
		       	end
		    end
	    when 3
	    	while true do
		    	puts "Comparing Dealer VS player"
		    	if player.total_query == dealer.total_query
		    		puts "Its a draw"
		    		State.change_state(4)
		    		break
		    	elsif player.total_query > dealer.total_query
		    		puts "#{player_name} Wins!"
		    		State.change_state(4)
		    		break
		    	elsif player.total_query < dealer.total_query
		    		puts "Dealer Wins!"  
		    		State.change_state(4)
		    		break
		    	end
		    end
	    else
	    	puts "Thanks for playing! GoodBye!"
	    	break
	end
end
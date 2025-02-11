#!/bin/bash

luggage=("Ring" "Watch" "Travel Guide" "Travel Pillow" "Toothbrush" "Sunscreen" "Headphones" "Power Bank" "Hat" "Laptop")
cities=("Sydney, Australia" "Tokyo, Japan" "Rome, Italy" "Paris, France" "New York, USA" "Dubai, UAE" "London, England" "Wellington, New Zealand" "Berlin, Germany" "Oslo, Norway" "Mexico City, Mexico" "Amsterdam, Netherlands" "Kathmandu, Nepal" "Cairo, Egypt" "Madrid, Spain")

declare -A lost_luggage
declare -A player
declare -a visited=("${cities[0]}")
declare -a found=()

function intro() {
    clear
    echo -e "Welcome to the Lost Luggage Adventure Game!

You had everything planned perfectly.

The flights were booked, the hotel reservations confirmed, and most importantly—the ring was safely tucked away in your luggage. A beautiful, one-of-a-kind engagement ring, meant for a once-in-a-lifetime proposal.

But somewhere along the way—between connecting flights, airport chaos, and a rushed baggage check—the ring vanished. Lost. Misplaced in the labyrinth of airport luggage systems, shuffled between terminals, and now, who knows where?

Armed with lost luggage claim tickets and a relentless determination, you must embark on a journey across multiple cities, following the trail of misplaced bags in hopes of recovering your precious ring. Along the way, you might recover your other lost luggage.\n\n"

    echo -n "Enter your name: "
    read player_name
    player["name"]=$player_name

    echo -e "\nWelcome ${player["name"]}.

Your adventure begins now. Will you track down the ring, or will it be lost forever in the sea of unclaimed baggage?\n\n"

    read -p "Press enter to begin your quest"
}


function init() {
    player["name"]="Traveller"
    player["duration"]=0
    player["cost"]=0
    player["city"]="${cities[0]}"
    player["found_ring"]=false
    player["quit"]=false


    # Randomise the location of each piece of lost luggage
    shuffled_city_indexes=($(shuf -e "${!cities[@]}"))
    luggage_index=${#luggage[@]}
    for key in "${shuffled_city_indexes[@]}"; do
        luggage_index=$((luggage_index-1))
        lost_luggage["${cities[$key]}"]+="${luggage[$luggage_index]}"
        if (( $luggage_index <= 0 )); then
            break
        fi
    done

#   Debug luggage shuffle
#   echo -e "\nLOST_LUGGAGE"
#   for key in "${!lost_luggage[@]}"; do
#       echo "$key -> ${lost_luggage[$key]}"
#   done
}

function search() {
    city="$1"
    echo -e "\nSearching for lost luggage in $city..."
    if [[ -v lost_luggage["$city"] ]]; then
        echo -e "\nFOUND ${lost_luggage[$city]}!\n"
        found+=("${lost_luggage["${city}"]}")
        if [[ "${lost_luggage["${city}"]}" == "Ring" ]]; then
            player["found_ring"]=true
        fi
    else
        echo -e "Nothing found in $city\n"
    fi
    read -p "Press enter to begin your quest"
}

function travel() {
    echo -e "\nWhere would you like to go next?"
    available_cities=()
    temp=()
    for city in "${cities[@]}"; do
        echo "Have you previously visited ${city}?"
        previously_visited=false
        for visited_city in "${visited[@]}"; do
            if [[ "$city" == "$visited_city" ]]; then
                echo "Previously Visited ${city}"
                previously_visited=true
            fi
        done
        if [[ previously_visited == true ]]; then
            echo "You have already been to ${city}"
        else
            echo "You haven't been to ${city} yet"
            available_cities+=("${city}")
        fi
    done

    if [ ${#available_cities[@]} -eq 0 ]; then
        echo "You've already visited all cities."
        return
    fi

    for i in "${!available_cities[@]}"; do
        echo "$((i+1)). ${available_cities[$i]}"
    done

    echo -n "Choose a city by number: "
    read city_choice
    destination="${available_cities[$((city_choice-1))]}"
    visited+=("${destination}")
    player["city"]="${destination}"
    echo -e "\nTravelling to ${destination}..."
}

function play() {
    while [ "${player["found_ring"]}" == false ]; do
        city="${player["city"]}"

        # echo -e "You have visited: ${visited[@]}"
   
        clear
        # echo -e "${city_descriptions[$city]}\n"
        echo -e "Welcome to $city!

You are on a quest to find the lost ring! Choose an action:
  1. Search for lost luggage
  2. Travel to another city
  3. Abandon your quest"

        echo -n "What will you do? (1, 2, or 3): "
        read action

        case $action in
            1)  # Search for luggage
                search "$city"
                ;;
            2)  # Travel to another city
                travel
                ;;
            3)  # Abandon the quest
                player["quit"]=true
                ;;
            *)
                echo -e "\nInvalid choice, please choose 1, 2, or 3."
                ;;
        esac

        if [ "${player["found_ring"]}" == true ]; then
            echo -e "\nCongratulations! You have found the ring!"
            echo -e "Your journey has ended successfully.\n"
            break
        fi

        if [ "${player["quit"]}" == true ]; then
            echo -e "Your journey has ended.\n"
            break
        fi
    done

    echo -e "\nLuggage found: ${found[@]}"
    echo -e "Cities visited: ${visited[@]}"
}


init
intro
play

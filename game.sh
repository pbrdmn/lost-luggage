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

    read -t 5 -p 'Name for your ticket: ' -e -i 'Traveller' username || username="Traveller"
    player["name"]=$username

    echo -e "\nWelcome ${player["name"]}.

Your adventure begins now. Will you track down the ring, or will it be lost forever in the sea of unclaimed baggage?\n\n"

    read -t 3 -p "Preparing your trip..."
}

function victory() {
    clear

    echo -e "After a whirlwind journey across multiple cities, following cryptic baggage claim tickets and chasing down lost luggage, you finally unzip a suitcase and there it is—your precious ring, gleaming under the dim airport storage lights.

Relief washes over you. The long flights, the confusing city streets, the countless misplaced suitcases—it was all worth it. The moment you’ve been working toward is finally within reach.

Now, all that’s left is to return home, knowing that soon, you’ll be down on one knee, holding out this very ring, and asking the most important question of your life.

"

}

function summary() {
    echo -e "\n * \$${player["cost"]} spent on flights"
    echo -e "\n * ${player["duration"]} hours spent travelling"
    echo -e "\n * ${#visited[@]} Cities Visited:"
    for key in "${!visited[@]}"; do
        echo "   -> ${visited[$key]}"
    done

    echo -e "\n * Luggage Found:"
    for key in "${!found[@]}"; do
        echo "   -> ${found[$key]}"
    done


echo -e "

Some journeys are about the destination, but this one was about the adventure.

"
    read -t 1 -p "Thank you for playing...\n\n"
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
    echo -en "\nSearching for lost luggage in $city... "
    if [[ -v lost_luggage["$city"] ]]; then
        echo -e "you FOUND your ${lost_luggage[$city]}!\n"
        found+=("${lost_luggage["${city}"]}")
        if [[ "${lost_luggage["${city}"]}" == "Ring" ]]; then
            player["found_ring"]=true
        fi

        # The player has found the luggage, so remove it from lost_luggage
        unset lost_luggage["$city"]
    else
        echo -e "nothing found\n"
    fi

    read -t 3 -p "Preparing your next trip..."
}

function travel() {
    city="$1"
    N=5
    flights=()
    costs=()
    durations=()

    echo -e "\nWhere would you like to go next?"
    echo -e "\nAvailable flights from ${city}:"
    shuffled_city_indexes=($(shuf -e "${!cities[@]}"))
    for index in $(shuf --input-range=0-$(( ${#cities[*]} - 1 )) -n ${N}); do
        flights+=("${cities[$index]}")
        costs+=("100")
        durations+=("5")
    done

    for i in "${!flights[@]}"; do
        echo "$((i+1)). ${flights[$i]}. \$${costs[$i]}. ${durations[$i]}h"
    done

    echo -n "Choose a city by number: "
    read city_choice
    selection=$((city_choice-1))

    destination="${flights[$selection]}"
    visited+=("${destination}")

    player["cost"]=$((player["cost"] + costs[$selection]))
    player["duration"]=$((player["duration"] + durations[$selection]))
    player["city"]="${destination}"

    echo -e "\nTravelling to ${destination}..."
    read -n 1 -s -r -p "Thank you for visiting ${city}."
}

function play() {
    while [ "${player["found_ring"]}" == false ]; do
        city="${player["city"]}"

        echo -e "You have visited: ${visited[@]}"
   
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
                travel "$city"
                ;;
            3)  # Abandon the quest
                player["quit"]=true
                ;;
            *)
                echo -e "\nInvalid choice, please choose 1, 2, or 3."
                ;;
        esac

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
if [ "${player["found_ring"]}" == true ]; then
    victory
fi
summary

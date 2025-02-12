#!/bin/bash

# luggage=("Ring" "Watch" "Travel Guide" "Travel Pillow" "Toothbrush" "Sunscreen" "Headphones" "Power Bank" "Hat" "Laptop")

declare -A lost_luggage
declare -A player
declare -a visited=()
declare -a found=()
declare -a luggage=()
declare -a cities=()
declare -A countries=()
declare -A descriptions=()

function intro() {
    #clear
    echo -e "Welcome to the Lost Luggage Adventure Game!

You had everything planned perfectly.

The flights were booked, the hotel reservations confirmed, and most importantly—the ring was safely tucked away in your luggage. A beautiful, one-of-a-kind engagement ring, meant for a once-in-a-lifetime proposal.

But somewhere along the way—between connecting flights, airport chaos, and a rushed baggage check—the ring vanished. Lost. Misplaced in the labyrinth of airport luggage systems, shuffled between terminals, and now, who knows where?

Armed with lost luggage claim tickets and a relentless determination, you must embark on a journey across multiple cities, following the trail of misplaced bags in hopes of recovering your precious ring. Along the way, you might recover your other lost luggage.\n\n"

    read -t 5 -p 'Name for your ticket: ' -e -i `whoami` name
    player["name"]=$name

    echo -e "\nWelcome ${player["name"]}."
    echo -e "\nYour adventure begins now."
    echo -e "\nWill you track down the ring, or will it be lost forever in the sea of unclaimed baggage?"
    echo -e "\nYour search begins in ${player["city"]}\n"
}

function victory() {
    #clear

    echo -e "After a whirlwind journey across multiple cities, following cryptic baggage claim tickets and chasing down lost luggage, you finally unzip a suitcase and there it is—your precious ring, gleaming under the dim airport storage lights.

Relief washes over you. The long flights, the confusing city streets, the countless misplaced suitcases—it was all worth it. The moment you’ve been working toward is finally within reach.

Now, all that’s left is to return home, knowing that soon, you’ll be down on one knee, holding out this very ring, and asking the most important question of your life.

"

}

function summary() {
    echo -e "\n * You spent \$${player["cost"]} on plane tickets"
    echo -e " * You endured ${player["duration"]} hours of in-flight entertainment"
    echo -e " * You visited ${#visited[@]} cities:"
    for key in "${!visited[@]}"; do
        echo "   -> ${visited[$key]}"
    done

    echo -e "\n * You found ${#found[@]} pieces of lost luggage:"
    for key in "${!found[@]}"; do
        echo "   -> ${found[$key]}"
    done
}

function farewell() {
    echo -e "\n\nSome adventures are about the destination, but this one was about the journey.\n"
    echo -e "Thank you for playing..."
}

function init() {
    player["name"]="Traveller"
    player["duration"]=0
    player["cost"]=0
    player["city"]=""
    player["found_ring"]=false
    player["quit"]=false

    # Load cities from data file
    load_cities
    player["city"]="${cities[0]}"
    visited+=("${cities[0]}")

    # Load luggage from data file
    load_luggage

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
}

function load_cities() {
    # Load cities from data/cities.csv
    csv_file="data/cities.csv"

    while IFS="," read -r city country description
    do
        cities+=("${city}")
        countries["${city}"]="${country}"
        description=$(echo "$description" | sed 's/^"\(.*\)"$/\1/')
        descriptions["${city}"]="${description}"
    done < "$csv_file"
}

function load_luggage() {
    # Load lost luggage from data/luggage.csv
    csv_file="data/luggage.csv"

    while IFS="," read -r item description
    do
        luggage+=("${item}")
        description=$(echo "$description" | sed 's/^"\(.*\)"$/\1/')
        descriptions+=("${description}")
    done < "$csv_file"
}

function search() {
    city="$1"
    echo -e "\nYou search for lost luggage in $city... "
    if [[ -v lost_luggage["$city"] ]]; then
        found_luggage="${lost_luggage[$city]}"
        found+=("${found_luggage}")

        # The player has found the luggage, so remove it from lost_luggage
        unset lost_luggage["$city"]

        echo -e " ... and you found your ${found_luggage}!\n"

        if [[ "${found_luggage}" == "Ring" ]]; then
            player["found_ring"]=true
        fi
    else
        echo -e " ... but you found nothing\n"
    fi
}

function travel() {
    city="$1"
    N=5
    flights=()
    costs=()
    durations=()

    # Load flights from data/flights.csv
    declare -a flight_data
    csv_file="data/flights.csv"

    while IFS=, read -r origin destination duration cost
    do
        # Find flights from the current city
        if [ "$origin" == "${city}" ]; then
            flight_data+=("$origin,$destination,$duration,$cost")
            flights+=("${destination}")
            costs+=("${cost}")
            durations+=("${duration}")
        fi
    done < "$csv_file"

    echo -e "\n\nWhere would you like to go next?"
    echo -e "\nAvailable flights from ${city}:"

    # Limit the number of flights available
    # This will randomise each time
    shuffled_flight_indexes=($(shuf -e "${!cities[@]}"))
    for i in $(shuf --input-range=0-$(( ${#flights[*]} - 1 )) -n ${N}); do
        echo "$((i+1)). ${flights[$i]}. \$${costs[$i]}. ${durations[$i]}h"
    done

    echo -en "\nChoose a city by number: "
    read city_choice
    selection=$((city_choice-1))
    # Validate selection?

    destination="${flights[$selection]}"
    visited+=("${destination}")

    player["cost"]=$((player["cost"] + costs[$selection]))
    player["duration"]=$((player["duration"] + durations[$selection]))
    player["city"]="${destination}"

    echo -e "\nBoarding flight from ${city} to ${destination}...\n"
}

function describe_city() {
    city="$1"
    echo -e "\n\nYou are in $city, ${countries[${city}]}!"
    echo -e "\n${descriptions[${city}]}\n"
}

function play() {
    while [ "${player["found_ring"]}" == false ]; do
        city="${player["city"]}"

        # Auto-search
        # search "${city}"

        echo -e "Choose an action:"
        echo -e "  1. Describe ${city}"
        echo -e "  2. Search for lost luggage"
        echo -e "  3. Travel to another city"
        echo -e "  4. View your progress"
        echo -e "  5. Abandon your quest"

        echo -n "What will you do? (1, 2, 3, 4, or Q): "
        read action

        case $action in
            1)  # Describe this city
                describe_city "$city"
                ;;
            2)  # Search for luggage
                search "$city"
                ;;
            3)  # Travel to another city
                travel "$city"
                ;;
            4)  # View your progress
                summary
                ;;
            5 | Q | q)  # Abandon the quest
                player["quit"]=true
                ;;
            *)
                echo -e "\nInvalid choice\n"
                ;;
        esac

        if [ "${player["quit"]}" == true ]; then
            echo -e "Your journey has ended.\n"
            break
        fi
    done
}


init
intro
play
if [ "${player["found_ring"]}" == true ]; then
    victory
fi
summary
farewell

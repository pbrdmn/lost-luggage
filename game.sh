#!/bin/bash

luggage=("Ring" "Watch" "Travel Guide" "Travel Pillow" "Toothbrush" "Sunscreen" "Headphones" "Power Bank" "Hat" "Laptop")
cities=(
    "Sydney, Australia"
    "Tokyo, Japan"
    "Rome, Italy"
    "Paris, France"
    "New York, USA"
    "Dubai, UAE"
    "London, England"
    "Wellington, New Zealand"
    "Berlin, Germany"
    "Oslo, Norway"
    "Mexico City, Mexico"
    "Amsterdam, Netherlands"
    "Kathmandu, Nepal"
    "Cairo, Egypt"
    "Madrid, Spain"
)

declare -rA city_descriptions=(
    ["Sydney, Australia"]="Sydney is known for its iconic Opera House and Harbour Bridge, as well as its laid-back beach culture. The weather is generally mild, with hot, sunny summers and cooler, rainy winters."
    ["Tokyo, Japan"]="Tokyo is a city of contrasts, where ultra-modern skyscrapers coexist with tranquil temples and traditional gardens. The streets are bustling with neon lights, and cherry blossoms bloom in spring. Tokyo's weather is varied, with hot, humid summers and cold, snowy winters."
    ["Rome, Italy"]="Rome is steeped in history, with landmarks like the Colosseum and Roman Forum. The city’s cobblestone streets and ancient ruins create a unique atmosphere. The weather is Mediterranean, with warm summers and mild winters."
    ["Paris, France"]="Known as the 'City of Light,' Paris boasts stunning landmarks like the Eiffel Tower and the Louvre Museum, and its architecture is a blend of classical elegance and modern artistry. The weather is mild, with warm summers and cool, crisp winters."
    ["New York, USA"]="The vibrant and diverse New York is known for its iconic skyline, Central Park, and the Statue of Liberty. The weather is varied, with hot, humid summers and cold, snowy winters."
    ["Dubai, UAE"]="Dubai is a futuristic metropolis in the desert, with incredible skyscrapers like the Burj Khalifa standing tall amidst luxury shopping malls and hotels. The weather is hot and dry year-round, with scorching summers."
)

declare -A lost_luggage
declare -A player
declare -a visited_cities=()
declare -a found_luggage=()

function init() {
    shuffle
    player["found_ring"]=false
    player["quit"]=false
    player["duration"]=0
    player["cost"]=0
}

function shuffle() {
    shuffled_city_indexes=($(shuf -e "${!cities[@]}"))
    luggage_index=${#luggage[@]}
    for key in "${shuffled_city_indexes[@]}"; do
        luggage_index=$((luggage_index-1))
        lost_luggage["${cities[$key]}"]+="${luggage[$luggage_index]}"
        if (( $luggage_index <= 0 )); then
            break
        fi
    done
#    Debug luggage shuffle
    echo -e "\nLOST_LUGGAGE"
    for key in "${!lost_luggage[@]}"; do
        echo "$key -> ${lost_luggage[$key]}"
    done
}

function description() {
    city="$1"
    echo -e "\nWelcome to $city!"
#    echo -e "${city_descriptions[$city]}\n"
    echo -e "You are on a quest to find the lost ring! Choose an action:"
    echo -e "  1. Search for lost luggage"
    echo -e "  2. Travel to another city"
    echo -e "  3. Abandon your quest"
}

function search() {
    city="$1"
    echo -e "\nSearching for lost luggage in $city..."
    if [[ -v lost_luggage["$city"] ]]; then
        echo -e "\nFOUND ${lost_luggage[$city]}!\n"
        found_luggage+=("${lost_luggage["${city}"]}")
        if [[ "${lost_luggage["${city}"]}" == "Ring" ]]; then
            player["found_ring"]=true
        fi
    else
        echo -e "\nNothing found in $city\n"
    fi
}

function travel() {
    echo -e "\nWhere would you like to go next?"
    available_cities=()
    temp=()
    for city in "${cities[@]}"; do
        for visited_city in "${visited_cities[@]}"; do
            if [[ "$city" == "$visited_city" ]]; then
                break
            fi
        done
        available_cities+=("${city}")
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
    visited_cities+=("${destination}")
    player["current_city"]="${destination}"
    echo -e "\nTravelling to ${destination}..."
}

function play() {
    while [ "${player["found_ring"]}" == false ]; do
        if [ ${#visited_cities[@]} -eq 0 ]; then
            current_city="${cities[0]}"
            player["current_city"]="${current_city}"
            visited_cities+=("${current_city}")
        else
            current_city="${player["current_city"]}"
        fi

        echo -e "You have visited: ${visited_cities}"
   
        description "$current_city"

        echo -n "What will you do? (1, 2, or 3): "
        read action

        case $action in
            1)  # Search for luggage
                search "$current_city"
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

    echo -e "\nLuggage found: ${found_luggage}"
    echo -e "Cities visited: ${visited_cities}"
}

init

echo -e "Welcome to the Lost Luggage Adventure Game!"

play

# 🧳 Lost Luggage

An interactive choose-your-own adventure text game to play in the terminal.

You, the player, have been travelling and your luggage has been lost. Not only has it been lost, your bag seems to have broken and the contents have spilled into other luggage. You must track down a list of lost luggage in search of your missing belongongs, and in particular a family heirloom ring you were planning on using to propose to your partner.

You have called the airline and they've given you a list of other lost luggage in a number of other cities that you will need to search to find your belongings, and in particular the ring. You have enough time and money to search through all of the cities, but your score will be determined by the total length time and money spent on the flights tracking down your belongings. The game will end when you find the ring.

## Setup

When the game starts, it will randomly generate cities, flights, and distribute the contents of your luggage between the cities.

## Goal

Examine the flight schedules, plan your route between cities, search the lost luggage, and find your lost ring.

## Gameplay

Each turn starts at an airport. In an airport you can:

1. Search the local city for a piece of lost luggage
2. Book a ticket (and travel) to another city
3. See a summary of your game, including the cities you have visited and any lost luggage your have found
4. (Q)uit the game

### Search for lost luggage

If your current city has a piece of lost luggage, you can search the city for the luggage.
This will involve solving a maze of street names until you find the correct street.
When you find the luggage, and lost items will be collected.
When you collect the ring, the game is over and a summary of your adventure will be displayed.

Initially, searching is a single event that will immediately find a piece of lost luggage, if there is one in the player's current city. Once found, the luggage is no longer lost and cannot be found again.

### Travelling

You can select a destination city from the available flights departing your current city.
You will spend time and money on each flight your take.
You do not have any limits on either time or money and can continue to travel and search for lost luggage until you find the lost ring, or abandon your quest.

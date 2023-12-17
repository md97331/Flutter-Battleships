
# Battleships

## Overview
I've developed an application that allows users to engage in the classic game of Battleships. This project involved integrating a RESTful API into a Flutter application, allowing players to register, log in, and compete against both human and computer opponents in Battleships.

## Features
* User Authentication: Players can register for a new account or log in to an existing one. The app handles session tokens securely, ensuring that users remain logged in across application restarts but require re-authentication once the token expires.

* Game List Management: The app displays a list of ongoing and completed Battleships games. Players can manually refresh this list to update the game statuses. Each game entry shows essential details like game ID, player usernames, and current game status.

* Interactive Game Play: Players can engage in Battleships games against either human or computer opponents. The game board is interactive, allowing players to place shots and view game progress in real-time.
 
* Responsive Game Board: The 5x5 grid game board is designed to be responsive, scaling up to fit various screen sizes without cropping or clipping. It shows distinct markers for the player's ships, hits, misses, and enemy ship locations.

* Ship Placement for New Games: When starting a new game, players are prompted to place their ships on the board. Each ship occupies a single tile, and players can add or remove ships before starting the game.

* Real-time Gameplay Updates: The app updates the game view immediately after a player takes a shot, especially in games against AI opponents. This feature keeps the gameplay dynamic and engaging.

## Experience
Creating this Battleships game app was a blend of technical programming skills and strategic game design. It was challenging and rewarding to implement a responsive, user-friendly interface and integrate it with a backend RESTful API. This project enhanced my skills in Flutter app development, particularly in managing asynchronous operations and stateful data.

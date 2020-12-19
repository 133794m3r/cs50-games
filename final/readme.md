# Block Falling Game
Following Features exist in the game. Also it has a save feature where it'll save your settings and also your high scores upon exiting and restarting the game. This data is serialized in a very effecient format. Plus I've added a version string to the savedata so that in the future if I add more options I can initialize the default properties with those items and then resave it in the new format to migrate the save data to a new version.

## Code overview
There are states, and menus. Each menu is a state, and each game mode is also a state.
## Game States
Each game "mode" inherits from the BaseGame State which inherits from the BaseState class. which they then modify for the specific game mode requirements. It also handles all of the basic stuff for them. The game modes then ineherit from this BaseGame state for their own state information.

## Menus
The game menus all inherit from the BaseState class.
Each menu is also interactive and modifies the screen contents depending on what's there.
### Help
This menu has 8 screens of text that can be navigated by either pressing the approriate number or using the left/right arrows. It also highlights which screen of text that you're on and explains the gameplay.
### Main
This is the main menu after pressing enter on the title screen. It lets you select the game mode and also highlights which option you're currently on. When you're on the game mode you can press left/right arrows to change the game mode. And this will select which game mode you'll play upon pressing enter.
### High Score
Same thing here the arrow keys shift between the game mode's high score tables. Also the difficulty that's currently active will show that difficulty level. Pressing left/right will shift through the different tables. It's also entered upon getting a high score or a game over.
### Title
This is the bootup screen. Took way too long to get the title image to look right.
### Settings
For now just does difficulty. In the future may add the option to do classic/dynamic for levels. Also the ability for blocks to drop due to gravity after clearing a line.
### Add Score
This is more of a state than a menu but it's still here. This lets the person enter their name(up to 10 characters) and it will then take them to the new high score table and also save their data.


## The 3 game modes
Also will have 2 difficulties.

### Marathon Mode
This game mode is a race till you get to level 15 and clear it. The goal here is to get the maximum possible score within the 15 levels.

### Endless Mode
The person will play until they fail trying to get as high of a score as possible.

### Time Attack
In this mode the person tries to get 50 lines as fast as possible.

## Difficulties
There is an easy and a hard mode. Easy mode has a slower acceleration curve for the drop rate and also gives the person more time before the piece locks into place. "hard" is the default curve and lock timing for pieces.

#Features Done
The features below are my simple way to track these items.

## Modes
- [x] Marathon Mode
- [x] Endless Mode
- [x] Time Attack

## Gameplay Features
 -[x] Wall/Floor Kicks
 -[x] Gravity Curve
 -[x] Piece Locking after timeout
 -[x] 7 Batch RNG
 -[x] Held Piece
 -[x] Next Piece
 -[x] Scoring System
 -[x] High Score table for each type/mode.
 
 ## Basic Game Stuff
 Basic items for the game itself.
 
 ## Menus
 -[x] Main Menu
 -[x] Help Menu
 -[x] Game type selector
 -[x] Difficulty Options
 -[x] Game Mode selector
 
 ### States
 -[x] Menu State
   -[x] High Score Menu
   -[x] Add High Score
   -[x] Main Menu
 -[x] Paused state
 -[x] Gameplay states
   - [x] Marathon Mode
   - [x] Sprint/Time Attack Mode
   - [x] Endless Mode
 -[x] Game over state
 -[x] Countdown state
 
 ### Classes
 -[x] Game Board
 -[x] GUI
 -[x] Pieces
 
 Held Piece and Next piece will be instances of said class.
 
 ### Music
 -[x] Basic game track
 -[x] Menu track
 -[x] Game over track


# Licenses
#Fonts
Source Code Pro(in res folder) is licensed under the Open Font License. Repo: https://github.com/adobe-fonts/source-code-pro
## Libraries
All of these files live in the lib folder.

Hump's Class.lua looks like an MIT based license. Repo: https://github.com/vrld/hump

Knife's Timer.lua is licensed under the MIT license Repo: https://github.com/airstruck/knife

Bitser.lua is licensed under MIT license. Repo: https://github.com/gvx/bitser

All other code in this repo by myself is licensed under the GPLv3.
 

## Music
https://opengameart.org/content/chip-bit-danger by Sudocolon

https://opengameart.org/content/this-game-is-over by mccartneytm

https://opengameart.org/content/space-boss-battle-theme by Matthew Pablo

https://opengameart.org/content/twister-tetris by poinl

https://opengameart.org/content/chiptune-techno by Nicole Marie T

https://opengameart.org/content/let-the-games-begin-0 by section31

## SFX

https://opengameart.org/content/rpg-sound-pack by artisticdude
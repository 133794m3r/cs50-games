# Match 3
A simple "bewjeweled" like game in lua.

The following features are implemented.
\+ are required features.
## Features

- +Starting level has only a single color.
- +Starting level has no "variety" of the gems.
- +If there are no valid moves the game will tell them such and regenerate the board.
    + The entire time that this is going on the game is "paused" thus pausing the timer and not taking away player time.
- +It doesn't allow the person to move the tiles if the move won't result in a match.
- +A shiny gem that's part of a match will destroy all of the ones in the row it contains.
- The board won't ever be on that'll already have matches. 
- The board should always have a match.
- +As you clear gems it'll increase the timer for each match.
    * The time you get added to the timer is based upon the "variety"(later ones are worth more), how many matches you've chained, and also whether they're a shiny gem was part of a match.
- As the player clears matches from the board you get their score increased. As before all of the items listed above also increase the total score that you gain from each match.
- Every 2 levels an additional color is added to the board.(After level 20 all 14 colors are possible to appear on the board.)
- Every 2 levels adds an additional variety to the game board.(After level 6 the highest pattern can be spawned.)
- You can pause the game and the timer is also paused during this time, and the user can't move the cursor. (The pause feature was implemented during development so that I could look at the log and not end up running out the clock.)

## Other Notes
I also used a modified modified tileset to make it easier to view the gems so that I could actually play it.
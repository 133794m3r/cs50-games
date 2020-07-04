#Breakout
CS50-G Assignment #2 Breakout.

##Features
This lists the major features of the projects. <br />
Ones with a `*` are/were required by the assignment. If it is a feature all subfeatures also apply to it.<br />
`**` means that I may or may not get to them and are just nice to have.<br />
`+` means that they are features/sub-features. not required from the assignment. 
### Powerups
- `*`"key" powerup spawns to unlock locked brick.
    - `+`if all bricks that carry a "key" powerup are destroyed and it wasn't collected one will continually spawn.
- `*`"multi-ball" powerup that spawns additional balls(up to 5)
    - All balls have proper collision with the bricks.
    - The player's life doesn't decrease until all balls are removed from play.
- `*`Paddle size increaser powerup. This powerup will make the paddle go up one size(up to the maximum)
    - The powerup will only last some period of time before being removed(generally ~30s)
- Paddle size decreaser power-down. Will decrease them down one size.
    - Same as above the amount of time it's active is ~30s. 
- `**`Powerups can stack. So getting a larger powerup and then a size powerdown. You will end up having your ship be the standard size and upon the size-up retiring your size will go down by one step. Then after the power-down powerup expires it'll return to normal.
- `+`Bonus Life powerup
    - Getting this powerup will increase your life count above the current to an absolute maximum of 5.
- `**`AI Mode powerup for the paddle.
    - This mode will cause your paddle to instantly move to the ball and also constantly try to track all of the balls.
- `**` "Glue" powerup.
    - This powerup will let you catch balls on your paddle. Upon all balls being on the paddle then it'll move to "serve" mode or I may make it so that you press "space" or a similar key to release the balls.
##TODO
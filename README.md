# The-great-space-adventure-68k-assem

![Gameplay Screenshot 1](POSTER.jpg)

A Space Invaders recreation written in 68k assembly.

This project recreates classic arcade-style alien waves with a custom Time Stop ability, background stars, and sound effects for shooting, hits, and special moments. It is a small retro game project focused on low-level gameplay logic and fast arcade action.
try to beat the current top score of 1260.

current settings

SHIP_W      EQU         20          ; Ship Width
SHIP_H      EQU         10          ; Ship Height
SHIP_SPEED  EQU         01          ; Ship Movement Speed

BULLET_W    EQU         3           ; Bullet Width
BULLET_H    EQU         10          ; Bullet Height
BULLET_SPD  EQU         07          ; Bullet Speed (upward)

ALIEN_W     EQU         40          ; Alien Width
ALIEN_H     EQU         10          ; Alien Height
ALIEN_COLS  EQU         09          ; Number of alien columns
ALIEN_ROWS  EQU         02          ; Number of alien rows
ALIEN_SPD   EQU         01          ; Alien base horizontal speed (slower)
ALIEN_GAP   EQU         40          ; Gap between aliens
ALIEN_MOVE_DELAY EQU    4           ; Only move aliens every N frames

SLOW_DURATION EQU       500         ; Slow motion lasts 5 seconds (in hundredths)
SLOW_COOLDOWN EQU       2000        ; 20 second cooldown (in hundredths)
SLOW_FACTOR EQU         10          ; Aliens move 10x slower during slow-mo

NUM_STARS   EQU         40          ; Number of stars in background

; Particle system constants
MAX_PARTICLES EQU       12          ; Max particles per explosion
PARTICLE_LIFE EQU       20          ; Particle lifetime in frames

; Heart pickup constants
HEART_SIZE    EQU       14          ; Heart pickup size
HEART_SPEED   EQU       2           ; Heart fall speed
MAX_LIVES     EQU       5           ; Maximum lives player can have

ALN_BLT_W   EQU         02          ; Alien bullet width
ALN_BLT_H   EQU         06          ; Alien bullet height
ALN_BLT_SPD EQU         01          ; Alien bullet speed (downward)
MAX_ALN_BLT EQU         25          ; Max alien bullets at once

SHOOT_INDEX EQU         00          ; Shoot Sound Index  
HIT_INDEX   EQU         01          ; Hit Sound Index  
OPPS_INDEX  EQU         02          ; Game Over Sound Index
MUSIC_INDEX EQU         03          ; Music Sound Index
TIMEFREEZE_INDEX EQU    04          ; Time Freeze Sound Index

BULLET_OFF  EQU         130         ; Bullet off-screen Y position

SCR_WIDTH   EQU         580         ; Screen width
SCR_HEIGHT  EQU         820         ; Screen height

and also max hearts are 5 and you start with 3 and gain 1 every wave clearance

## Trailer

https://youtu.be/X13U2M3_ZVo

## Screenshots

![Gameplay Screenshot 1](Screenshot%202026-03-03%20010644.png)
![Gameplay Screenshot 2](Screenshot%202026-03-03%20190848.png)
![Gameplay Screenshot 3](Screenshot%202026-03-03%20190902.png)


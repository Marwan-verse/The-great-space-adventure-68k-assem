*-----------------------------------------------------------
* Title        : The Great Space Adventure
* starter kit  : Philip Bourke
* programed by : Marwan Fayad
* Date         : 27/02/2026
* Description  : Space Invaders with Time Stop ability, waves,
*                background stars, and sound effects
*
*
*       to do list
* music not playing
*figure out why screen is shifted to the left
*figure out how to add bmp sprites into game
*maybe add boss at wave 5
*make trailer
*
*
*
*

*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    BRA     START_SCREEN            ; Show title screen first

*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout Game
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position
TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Game Setup
* Description   : Size of Player Ship, Bullet, and Aliens
*-----------------------------------------------------------
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

ALN_BLT_W   EQU         02          ; Alien bullet width
ALN_BLT_H   EQU         06          ; Alien bullet height
ALN_BLT_SPD EQU         01          ; Alien bullet speed (downward)
MAX_ALN_BLT EQU         04          ; Max alien bullets at once

SHOOT_INDEX EQU         00          ; Shoot Sound Index  
HIT_INDEX   EQU         01          ; Hit Sound Index  
OPPS_INDEX  EQU         02          ; Game Over Sound Index
MUSIC_INDEX EQU         03          ; Music Sound Index
TIMEFREEZE_INDEX EQU    04          ; Time Freeze Sound Index

BULLET_OFF  EQU         130         ; Bullet off-screen Y position

SCR_WIDTH   EQU         580         ; Screen width
SCR_HEIGHT  EQU         820         ; Screen height

*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points per alien
*-----------------------------------------------------------
POINTS      EQU         10          ; Points per alien hit

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Arrow keys, Spacebar and Escape
*-----------------------------------------------------------
KEY_LEFT    EQU         $25         ; Left Arrow
KEY_RIGHT   EQU         $27         ; Right Arrow
KEY_UP      EQU         $26         ; Up Arrow (Slow Motion)
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode (Shoot)
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    : Start Screen
* Description   : Display title screen and wait for key press
*-----------------------------------------------------------
START_SCREEN:
    ; Set Graphics Window Size
    MOVE.L  #$02080334, D1          ; $0208 = 520, $0334 = 820
    MOVE.B  #33,        D0
    TRAP    #15
    
    ; Enable double buffer
    MOVE.B  #TC_DBL_BUF,D0
    MOVE.B  #17,        D1
    TRAP    #15
    
    ; Clear screen
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$FF00,     D1
    TRAP    #15
    
    ; Load and play music for title screen (after screen init)
    BSR     MUSIC_LOAD
    BSR     PLAY_MUSIC
    
DRAW_TITLE_SCREEN:
    ; Repaint
    MOVE.B  #94,        D0
    TRAP    #15
    
    ; Clear screen
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$FF00,     D1
    TRAP    #15
    
    ; Draw ASCII Art Title - Line 1
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0206,     D1          ; Col 2, Row 6
    TRAP    #15
    LEA     TITLE_1,    A1
    MOVE    #14,        D0
    TRAP    #15
    
    ; Line 2
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0207,     D1          ; Col 2, Row 7
    TRAP    #15
    LEA     TITLE_2,    A1
    MOVE    #14,        D0
    TRAP    #15
    
    ; Line 3
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0208,     D1          ; Col 2, Row 8
    TRAP    #15
    LEA     TITLE_3,    A1
    MOVE    #14,        D0
    TRAP    #15
    
    ; Line 4
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0209,     D1          ; Col 2, Row 9
    TRAP    #15
    LEA     TITLE_4,    A1
    MOVE    #14,        D0
    TRAP    #15
    
    ; Line 5
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$020A,     D1          ; Col 2, Row 10
    TRAP    #15
    LEA     TITLE_5,    A1
    MOVE    #14,        D0
    TRAP    #15
    
    ; Line 6
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$020B,     D1          ; Col 2, Row 11
    TRAP    #15
    LEA     TITLE_6,    A1
    MOVE    #14,        D0
    TRAP    #15

    ; Space Adventure subtitle
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0614,     D1          ; Col 6, Row 20
    TRAP    #15
    LEA     SHIP_ART3,  A1
    MOVE    #14,        D0
    TRAP    #15
    

    ; Draw controls info
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$061C,     D1          ; Col 6, Row 28
    TRAP    #15
    LEA     CONTROLS1,  A1
    MOVE    #14,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$061D,     D1          ; Col 6, Row 29
    TRAP    #15
    LEA     CONTROLS2,  A1
    MOVE    #14,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$061E,     D1          ; Col 6, Row 30
    TRAP    #15
    LEA     CONTROLS3,  A1
    MOVE    #14,        D0
    TRAP    #15
    
WAIT_FOR_KEY:
    ; Check if any key is pressed using key state check
    MOVE.B  #TC_KEYCODE,D0          ; Check key state (trap 19)
    MOVE.L  #SPACEBAR,  D1          ; Check spacebar
    TRAP    #15
    BTST    #0,         D1          ; Key pressed?
    BNE     INITIALISE              ; Yes - start game!
    
    ; Also check Enter key
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #$0D,       D1          ; Enter key
    TRAP    #15
    BTST    #0,         D1
    BNE     INITIALISE
    
    ; Small delay to prevent CPU spinning
    MOVE.L  #1,         D1
    MOVE.B  #23,        D0          ; Delay
    TRAP    #15
    
    BRA     DRAW_TITLE_SCREEN       ; Keep displaying

*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory
*-----------------------------------------------------------
INITIALISE:
    ; Stop the title screen music
    BSR     STOP_MUSIC
    
    ; Set Graphics Window Size to 520x820
    ; Trap 33: D1 high word = width, D1 low word = height
    MOVE.L  #$01600334, D1          ; $0208 = 520, $0334 = 820
    MOVE.B  #33,        D0
    TRAP    #15
    
    ; Initialise Sounds
    BSR     SHOOT_LOAD              ; Load Shoot Sound into Memory
    BSR     HIT_LOAD                ; Load Hit Sound into Memory
    BSR     OPPS_LOAD               ; Load Game Over Sound into Memory
    BSR     TIMEFREEZE_LOAD         ; Load Time Freeze Sound into Memory
    
    ; Initialize time stop message timer
    MOVE.L  #0,         TIMESTOP_MSG_TIME

    ; Store Screen Size
    MOVE.W  #SCR_WIDTH, SCREEN_W    ; Store screen width
    MOVE.W  #SCR_HEIGHT,SCREEN_H    ; Store screen height

    ; Place the Player Ship at the bottom center of the screen
    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    SUB.L   #SHIP_W/2,  D1          ; Center the ship
    MOVE.L  D1,         SHIP_X      ; Ship X Position

    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_H,   D1          ; Place Screen height in D1
    SUB.L   #30,        D1          ; Place ship near bottom
    MOVE.L  D1,         SHIP_Y      ; Ship Y Position

    ; Initialise Bullet (off screen)
    MOVE.L  #BULLET_OFF,BULLET_Y    ; Bullet starts off screen
    MOVE.L  #0,         BULLET_X    ; Bullet X position

    ; Initialize Bullet Active Flag
    MOVE.L  #0,         BULLET_ACT  ; Bullet not active

    ; Initialise Player Score
    MOVE.L  #0,         PLAYER_SCORE

    ; Initialise Alien Direction (1 = right, -1 = left)
    MOVE.L  #1,         ALIEN_DIR   ; Start moving right

    ; Initialize Aliens
    BSR     INIT_ALIENS             ; Set up alien grid

    ; Initialize Game Over flag
    MOVE.L  #0,         GAME_OVER   ; Game is not over

    ; Initialize alien bullets
    BSR     INIT_ALIEN_BULLETS
    
    ; Initialize random seed
    MOVE.B  #8,         D0          ; Get time
    TRAP    #15
    MOVE.L  D1,         RANDOM_SEED ; Use time as random seed
    
    ; Initialize slow motion variables
    MOVE.L  #0,         SLOW_ACTIVE ; Slow motion not active
    MOVE.L  #0,         SLOW_END_TIME ; No end time
    MOVE.L  #0,         SLOW_READY_TIME ; Can use immediately
    
    ; Initialize wave system
    MOVE.L  #1,         WAVE_NUM    ; Start at wave 1
    MOVE.L  #ALIEN_SPD, CURRENT_ALIEN_SPD ; Current alien speed
    MOVE.L  #0,         ALIEN_MOVE_CNT ; Alien move frame counter
    
    ; Initialize stars
    BSR     INIT_STARS

    ; Enable the screen back buffer
    MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
    TRAP    #15                     ; Trap (Perform action)

    ; Clear the screen
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$FF00,     D1          ; Fill Screen Clear
    TRAP    #15                     ; Trap (Perform action)
    
    ; Start game music (loops)
    BSR     MUSIC_LOAD              ; Load music for game
    BSR     PLAY_MUSIC              ; Play music in loop
    
    BRA     GAMELOOP                ; Start the game loop

*-----------------------------------------------------------
* Subroutine    : Init Aliens
* Description   : Initialize alien positions (1 = alive, 0 = dead)
*-----------------------------------------------------------
INIT_ALIENS:
    LEA     ALIENS,     A0          ; Load aliens array address
    MOVE.L  #(ALIEN_ROWS*ALIEN_COLS)-1, D7  ; Loop counter
    MOVE.L  #1,         D1          ; 1 = alive
INIT_ALIEN_LOOP:
    MOVE.L  D1,         (A0)+       ; Set alien as alive
    DBRA    D7,         INIT_ALIEN_LOOP
    
    ; Set starting position for alien formation
    MOVE.L  #100,       ALIENS_X    ; Start X position of formation (centered)
    MOVE.L  #40,        ALIENS_Y    ; Start Y position of formation
    RTS

*-----------------------------------------------------------
* Subroutine    : Game Loop
* Description   : Main game loop
*-----------------------------------------------------------
GAMELOOP:
    ; Check if game is over
    MOVE.L  GAME_OVER,  D1
    CMP.L   #1,         D1
    BEQ     SHOW_GAME_OVER

    ; Update slow motion timer
    BSR     UPDATE_SLOW_MOTION

    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE_BULLET           ; Update bullet position
    BSR     UPDATE_ALIENS           ; Move aliens
    BSR     CHECK_BULLET_COLLISIONS ; Check bullet hitting aliens
    BSR     UPDATE_ALIEN_BULLETS    ; Update alien bullets
    BSR     ALIEN_SHOOT_RANDOM      ; Random alien shooting
    BSR     CHECK_ALIEN_BULLET_HIT  ; Check if player is hit
    BSR     CHECK_ALIEN_REACHED     ; Check if aliens reached bottom
    BSR     CHECK_NEXT_WAVE         ; Check if all aliens dead -> spawn next wave
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Show Game Over
* Description   : Display game over screen
*-----------------------------------------------------------
SHOW_GAME_OVER:
    BSR     DRAW                    ; Draw final state
    BSR     INPUT                   ; Still check for escape
    BRA     SHOW_GAME_OVER

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Check for escape - restart if game over, exit if playing
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #ESCAPE,    D1
    TRAP    #15
    BTST    #0,         D1
    BEQ     .NO_ESC
    
    ; Check if game is over
    MOVE.L  GAME_OVER,  D1
    CMP.L   #0,         D1
    BEQ     EXIT                    ; Playing - exit game
    BRA     INITIALISE              ; Game over - restart
    
.NO_ESC:
    
    ; Check for up arrow (slow motion)
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #KEY_UP,    D1
    TRAP    #15
    BTST    #0,         D1
    BNE     ACTIVATE_SLOW
    
    ; Check for left arrow (held)
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #KEY_LEFT,  D1
    TRAP    #15
    BTST    #0,         D1
    BNE     MOVE_LEFT
    
    ; Check for right arrow (held)
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #KEY_RIGHT, D1
    TRAP    #15
    BTST    #0,         D1
    BNE     MOVE_RIGHT
    
    ; Check for spacebar (shoot)
    MOVE.B  #TC_KEYCODE,D0
    MOVE.L  #SPACEBAR,  D1
    TRAP    #15
    BTST    #0,         D1
    BNE     SHOOT
    
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Activate Slow Motion
* Description   : Activate slow motion if cooldown is ready
*-----------------------------------------------------------
ACTIVATE_SLOW:
    ; Check if already active
    MOVE.L  SLOW_ACTIVE,D1
    CMP.L   #1,         D1
    BEQ     ACTIVATE_SLOW_DONE      ; Already active
    
    ; Check if cooldown has passed
    MOVE.B  #8,         D0          ; Get current time
    TRAP    #15
    MOVE.L  D1,         D2          ; Current time in D2
    MOVE.L  SLOW_READY_TIME,D3
    CMP.L   D3,         D2          ; Current time >= ready time?
    BLT     ACTIVATE_SLOW_DONE      ; Not ready yet
    
    ; Activate slow motion!
    MOVE.L  #1,         SLOW_ACTIVE
    
    ; Play time freeze sound
    BSR     PLAY_TIMEFREEZE
    
    ; Set message display timer (show for 2 seconds = 200 hundredths)
    MOVE.B  #8,         D0
    TRAP    #15
    ADD.L   #200,       D1
    MOVE.L  D1,         TIMESTOP_MSG_TIME
    
    ; Set end time = current time + duration
    MOVE.B  #8,         D0
    TRAP    #15
    MOVE.L  D1,         D2          ; Current time in D2
    ADD.L   #SLOW_DURATION,D1
    MOVE.L  D1,         SLOW_END_TIME
    
ACTIVATE_SLOW_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Move Left
* Description   : Move ship left
*-----------------------------------------------------------
MOVE_LEFT:
    MOVE.L  SHIP_X,     D1
    SUB.L   #SHIP_SPEED,D1
    CMP.L   #0,         D1          ; Don't go past left edge
    BLE     MOVE_LEFT_DONE
    MOVE.L  D1,         SHIP_X
MOVE_LEFT_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Move Right  
* Description   : Move ship right
*-----------------------------------------------------------
MOVE_RIGHT:
    MOVE.L  SHIP_X,     D1
    ADD.L   #SHIP_SPEED,D1
    MOVE.L  #SCR_WIDTH, D2
    SUB.L   #SHIP_W,    D2          ; Right edge (screen width - ship width)
    CMP.L   D2,         D1
    BGE     MOVE_RIGHT_DONE
    MOVE.L  D1,         SHIP_X
MOVE_RIGHT_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Shoot
* Description   : Fire bullet from ship
*-----------------------------------------------------------
SHOOT:
    ; Only shoot if bullet not active
    MOVE.L  BULLET_ACT, D1
    CMP.L   #1,         D1
    BEQ     SHOOT_DONE              ; Already active, skip
    
    ; Fire new bullet
    BSR     PLAY_SHOOT              ; Play shoot sound
    MOVE.L  #1,         BULLET_ACT  ; Set bullet active
    
    ; Position bullet at center of ship
    MOVE.L  SHIP_X,     D1
    ADD.L   #SHIP_W/2,  D1
    SUB.L   #BULLET_W/2,D1
    MOVE.L  D1,         BULLET_X
    
    MOVE.L  SHIP_Y,     D1
    SUB.L   #BULLET_H,  D1
    MOVE.L  D1,         BULLET_Y
    
SHOOT_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Update Bullet
* Description   : Move bullet upward
*-----------------------------------------------------------
UPDATE_BULLET:
    ; Check if bullet is active
    MOVE.L  BULLET_ACT, D1
    CMP.L   #0,         D1
    BEQ     BULLET_UPDATE_DONE      ; Not active, skip
    
    ; Move bullet up
    MOVE.L  BULLET_Y,   D1
    SUB.L   #BULLET_SPD,D1
    MOVE.L  D1,         BULLET_Y
    
    ; Check if bullet went off screen
    CMP.L   #0,         D1
    BLE     DEACTIVATE_BULLET
    BRA     BULLET_UPDATE_DONE

DEACTIVATE_BULLET:
    MOVE.L  #0,         BULLET_ACT
    MOVE.L  #BULLET_OFF,BULLET_Y
    
BULLET_UPDATE_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Update Aliens
* Description   : Move aliens side to side and down
*-----------------------------------------------------------
UPDATE_ALIENS:
    ; Check if slow motion is active
    MOVE.L  SLOW_ACTIVE,D0
    CMP.L   #1,         D0
    BEQ     SLOW_ALIEN_MOVE
    
    ; Normal speed - add frame delay for slower movement
    MOVE.L  ALIEN_MOVE_CNT,D0
    ADD.L   #1,         D0
    CMP.L   #ALIEN_MOVE_DELAY,D0
    BLT     SKIP_NORMAL_MOVE
    CLR.L   D0                      ; Reset counter
    
    ; Move aliens
    MOVE.L  ALIENS_X,   D1
    MOVE.L  ALIEN_DIR,  D2
    MOVE.L  CURRENT_ALIEN_SPD,D3
    MULS    D3,         D2
    ADD.L   D2,         D1
    MOVE.L  D1,         ALIENS_X
    MOVE.L  D0,         ALIEN_MOVE_CNT
    BRA     CHECK_ALIEN_BOUNDS
    
SKIP_NORMAL_MOVE:
    MOVE.L  D0,         ALIEN_MOVE_CNT
    RTS
    
SLOW_ALIEN_MOVE:
    ; Slow motion - only move every 4th frame
    MOVE.L  SLOW_FRAME, D3
    ADD.L   #1,         D3
    CMP.L   #SLOW_FACTOR,D3
    BLT     SKIP_ALIEN_MOVE
    CLR.L   D3                      ; Reset frame counter
    
    ; Move aliens at reduced rate
    MOVE.L  ALIENS_X,   D1
    MOVE.L  ALIEN_DIR,  D2
    MOVE.L  CURRENT_ALIEN_SPD,D4
    MULS    D4,         D2
    ADD.L   D2,         D1
    MOVE.L  D1,         ALIENS_X
    MOVE.L  D3,         SLOW_FRAME
    BRA     CHECK_ALIEN_BOUNDS
    
SKIP_ALIEN_MOVE:
    MOVE.L  D3,         SLOW_FRAME
    RTS
    
CHECK_ALIEN_BOUNDS:
    MOVE.L  ALIENS_X,   D1
    
    ; Calculate rightmost alien X position
    ; Rightmost alien = ALIENS_X + (ALIEN_COLS-1) * ALIEN_GAP + ALIEN_W
    MOVE.L  D1,         D3          ; ALIENS_X
    ADD.L   #((ALIEN_COLS-1)*ALIEN_GAP),D3
    ADD.L   #ALIEN_W,   D3          ; Right edge of rightmost alien
    
    ; Check right boundary (screen width - margin)
    MOVE.L  #SCR_WIDTH, D2
    SUB.L   #0,         D2          ; 5 pixel margin from edge
    CMP.L   D2,         D3
    BGE     ALIENS_MOVE_DOWN_LEFT
    
    ; Check left boundary (leftmost alien at ALIENS_X)
    CMP.L   #0,         D1          ; 5 pixel margin from edge
    BLE     ALIENS_MOVE_DOWN_RIGHT
    
    BRA     ALIENS_UPDATE_DONE
    
ALIENS_MOVE_DOWN_LEFT:
    MOVE.L  #-1,        ALIEN_DIR   ; Change direction to left
    ADD.L   #15,        ALIENS_Y    ; Move down
    ; Push aliens back inside boundary
    MOVE.L  #SCR_WIDTH, D1
    SUB.L   #5,         D1
    SUB.L   #ALIEN_W,   D1
    SUB.L   #((ALIEN_COLS-1)*ALIEN_GAP),D1
    MOVE.L  D1,         ALIENS_X
    BRA     ALIENS_UPDATE_DONE
    
ALIENS_MOVE_DOWN_RIGHT:
    MOVE.L  #1,         ALIEN_DIR   ; Change direction to right
    ADD.L   #15,        ALIENS_Y    ; Move down
    ; Push aliens back inside boundary
    MOVE.L  #35,        ALIENS_X
    
ALIENS_UPDATE_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen (black background)
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_STARS              ; Draw stars first (background)
    BSR     DRAW_HUD                ; Draw Score
    BSR     DRAW_SHIP               ; Draw Player Ship
    BSR     DRAW_BULLET             ; Draw Bullet
    BSR     DRAW_ALIENS             ; Draw Aliens
    BSR     DRAW_ALIEN_BULLETS      ; Draw alien bullets
    
    ; Check for game over message
    MOVE.L  GAME_OVER,  D1
    CMP.L   #1,         D1
    BEQ     DRAW_GAME_OVER_MSG
    
    RTS

DRAW_GAME_OVER_MSG:
    ; Draw GAME OVER text
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0F10,     D1          ; Col 15, Row 16
    TRAP    #15
    LEA     GAMEOVER_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
    ; Draw final score label
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0F12,     D1          ; Col 15, Row 18
    TRAP    #15
    LEA     FINAL_SCORE_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
    ; Draw final score value
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1C12,     D1          ; Col 28, Row 18
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLAYER_SCORE,D1
    TRAP    #15
    
    ; Draw restart message
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0A14,     D1          ; Col 10, Row 20
    TRAP    #15
    LEA     RESTART_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw HUD
* Description   : Draw Score, Wave, and Slow Motion Status
*-----------------------------------------------------------
DRAW_HUD:
    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A01,     D1          ; Col 10, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Wave Number
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1401,     D1          ; Col 20, Row 01
    TRAP    #15
    LEA     WAVE_MSG,   A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1A01,     D1          ; Col 26, Row 01
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  WAVE_NUM,   D1
    TRAP    #15
    
    ; Slow Motion Status
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$2001,     D1          ; Col 32, Row 01
    TRAP    #15
    
    ; Check if slow motion is active
    MOVE.L  SLOW_ACTIVE,D1
    CMP.L   #1,         D1
    BEQ     DRAW_SLOW_ACTIVE
    
    ; Check if on cooldown
    MOVE.B  #8,         D0
    TRAP    #15
    MOVE.L  D1,         D2          ; Current time
    MOVE.L  SLOW_READY_TIME,D3
    CMP.L   D3,         D2          ; Ready?
    BGE     DRAW_SLOW_READY
    
    ; On cooldown - show time remaining
    LEA     SLOW_CD_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
    ; Calculate seconds remaining
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$2C01,     D1          ; Col 44, Row 01
    TRAP    #15
    
    MOVE.L  SLOW_READY_TIME,D1
    SUB.L   D2,         D1          ; Time remaining
    DIVU    #100,       D1          ; Convert to seconds
    AND.L   #$FFFF,     D1
    MOVE.B  #03,        D0
    TRAP    #15
    BRA     HUD_DONE
    
DRAW_SLOW_ACTIVE:
    LEA     SLOW_ON_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
    ; Check if we should display the TIME STOP message
    MOVE.B  #8,         D0
    TRAP    #15
    MOVE.L  D1,         D2          ; Current time
    MOVE.L  TIMESTOP_MSG_TIME,D3
    CMP.L   D3,         D2          ; Message time expired?
    BGE     HUD_DONE                ; Yes, skip message
    
    ; Draw TIME STOP message in center of screen
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0610,     D1          ; Col 6, Row 16 (center)
    TRAP    #15
    LEA     TIMESTOP_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    BRA     HUD_DONE
    
DRAW_SLOW_READY:
    LEA     SLOW_RDY_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
HUD_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw Ship
* Description   : Draw player ship (multi-colored spaceship)
*-----------------------------------------------------------
DRAW_SHIP:
    ; === Draw Engine Flames (Animated feel with multiple colors) ===
    ; Inner flame (Yellow/White - hottest)
    MOVE.L  #YELLOW,    D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #8,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #10,        D2
    MOVE.L  D1,         D3
    ADD.L   #4,         D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Outer flame (Orange)
    MOVE.L  #$000080FF, D1          ; Orange color
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #6,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #10,        D2
    MOVE.L  D1,         D3
    ADD.L   #8,         D3
    MOVE.L  D2,         D4
    ADD.L   #3,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Left Wing (Blue with gradient) ===
    ; Wing base (darker blue)
    MOVE.L  #$00AA5500, D1          ; Darker blue
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #5,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Wing tip (lighter blue)
    MOVE.L  #$00FF8800, D1          ; Light blue
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    SUB.L   #2,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #7,         D2
    MOVE.L  D1,         D3
    ADD.L   #4,         D3
    MOVE.L  D2,         D4
    ADD.L   #3,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Right Wing (Blue with gradient) ===
    ; Wing base (darker blue)
    MOVE.L  #$00AA5500, D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #14,        D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #5,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Wing tip (lighter blue)
    MOVE.L  #$00FF8800, D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #18,        D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #7,         D2
    MOVE.L  D1,         D3
    ADD.L   #4,         D3
    MOVE.L  D2,         D4
    ADD.L   #3,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Main Body (Green with metallic look) ===
    ; Body shadow (darker green)
    MOVE.L  #$0000AA00, D1          ; Darker green
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #5,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #4,         D2
    MOVE.L  D1,         D3
    ADD.L   #10,        D3
    MOVE.L  D2,         D4
    ADD.L   #6,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Body main (bright green)
    MOVE.L  #GREEN,     D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #5,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #2,         D2
    MOVE.L  D1,         D3
    ADD.L   #10,        D3
    MOVE.L  D2,         D4
    ADD.L   #6,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Body highlight (lighter green stripe)
    MOVE.L  #$0000FF66, D1          ; Light green
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #6,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #3,         D2
    MOVE.L  D1,         D3
    ADD.L   #8,         D3
    MOVE.L  D2,         D4
    ADD.L   #2,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Nose Cone (Pointed top) ===
    MOVE.L  #$00AAAAAA, D1          ; Silver/Gray
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #8,         D1
    MOVE.L  SHIP_Y,     D2
    SUB.L   #2,         D2
    MOVE.L  D1,         D3
    ADD.L   #4,         D3
    MOVE.L  D2,         D4
    ADD.L   #4,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Cockpit (Cyan glass) ===
    MOVE.L  #CYAN,      D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #8,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #1,         D2
    MOVE.L  D1,         D3
    ADD.L   #4,         D3
    MOVE.L  D2,         D4
    ADD.L   #3,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Cockpit Highlight (White reflection) ===
    MOVE.L  #WHITE,     D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  SHIP_X,     D1
    ADD.L   #9,         D1
    MOVE.L  SHIP_Y,     D2
    ADD.L   #1,         D2
    MOVE.L  D1,         D3
    ADD.L   #2,         D3
    MOVE.L  D2,         D4
    ADD.L   #1,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Bullet
* Description   : Draw bullet (yellow rectangle)
*-----------------------------------------------------------
DRAW_BULLET:
    ; Check if bullet is active
    MOVE.L  BULLET_ACT, D1
    CMP.L   #0,         D1
    BEQ     BULLET_DRAW_DONE        ; Not active, skip
    
    ; Set Pixel Colors (Yellow for bullet)
    MOVE.L  #YELLOW,    D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  BULLET_X,   D1          ; X
    MOVE.L  BULLET_Y,   D2          ; Y
    MOVE.L  BULLET_X,   D3
    ADD.L   #BULLET_W,  D3          ; Width
    MOVE.L  BULLET_Y,   D4 
    ADD.L   #BULLET_H,  D4          ; Height
    
    ; Draw Bullet
    MOVE.B  #87,        D0          ; Draw filled rectangle
    TRAP    #15                     ; Trap (Perform action)
    
BULLET_DRAW_DONE:
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Aliens
* Description   : Draw all alive aliens as cool space invaders
*-----------------------------------------------------------
DRAW_ALIENS:
    LEA     ALIENS,     A0          ; Load aliens array
    MOVE.L  #0,         D7          ; Counter for alien index
    
DRAW_ALIEN_LOOP:
    CMP.L   #(ALIEN_ROWS*ALIEN_COLS), D7
    BGE     DRAW_ALIENS_DONE
    
    ; Check if this alien is alive
    MOVE.L  (A0)+,      D1          ; Get alien status
    CMP.L   #0,         D1
    BEQ     NEXT_ALIEN              ; Dead, skip drawing
    
    ; Calculate alien position
    ; Row = D7 / ALIEN_COLS
    ; Col = D7 % ALIEN_COLS
    MOVE.L  D7,         D3
    DIVU    #ALIEN_COLS,D3          ; D3.W = row, high word = col
    MOVE.W  D3,         D4          ; D4 = row
    SWAP    D3
    MOVE.W  D3,         D5          ; D5 = col
    
    ; Calculate X position: ALIENS_X + col * ALIEN_GAP
    CLR.L   D1
    MOVE.W  D5,         D1
    MULU    #ALIEN_GAP, D1
    ADD.L   ALIENS_X,   D1          ; Alien X
    
    ; Calculate Y position: ALIENS_Y + row * (ALIEN_H + 10)
    CLR.L   D2
    MOVE.W  D4,         D2
    MULU    #(ALIEN_H+10),D2
    ADD.L   ALIENS_Y,   D2          ; Alien Y
    
    ; Save base X,Y in A1,A2 for drawing parts
    MOVE.L  D1,         A3          ; Save base X
    MOVE.L  D2,         A4          ; Save base Y
    
    ; === Draw Alien Tentacles (Purple) ===
    MOVE.L  #$00FF00FF, D1          ; Purple/Magenta
    MOVE.B  #80,        D0
    TRAP    #15
    
    ; Left tentacle
    MOVE.L  A3,         D1
    ADD.L   #2,         D1
    MOVE.L  A4,         D2
    ADD.L   #8,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #4,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Right tentacle
    MOVE.L  A3,         D1
    ADD.L   #32,        D1
    MOVE.L  A4,         D2
    ADD.L   #8,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #4,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Main Body (Red) ===
    MOVE.L  #RED,       D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  A3,         D1
    ADD.L   #4,         D1
    MOVE.L  A4,         D2
    MOVE.L  D1,         D3
    ADD.L   #32,        D3
    MOVE.L  D2,         D4
    ADD.L   #10,        D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Head Dome (Darker Red) ===
    MOVE.L  #$000000AA, D1          ; Dark red
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  A3,         D1
    ADD.L   #10,        D1
    MOVE.L  A4,         D2
    SUB.L   #3,         D2
    MOVE.L  D1,         D3
    ADD.L   #20,        D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Left Eye (Yellow) ===
    MOVE.L  #YELLOW,    D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  A3,         D1
    ADD.L   #10,        D1
    MOVE.L  A4,         D2
    ADD.L   #2,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Right Eye (Yellow) ===
    MOVE.L  A3,         D1
    ADD.L   #24,        D1
    MOVE.L  A4,         D2
    ADD.L   #2,         D2
    MOVE.L  D1,         D3
    ADD.L   #6,         D3
    MOVE.L  D2,         D4
    ADD.L   #5,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; === Draw Eye Pupils (Black) ===
    MOVE.L  #$00000000, D1          ; Black
    MOVE.B  #80,        D0
    TRAP    #15
    
    ; Left pupil
    MOVE.L  A3,         D1
    ADD.L   #12,        D1
    MOVE.L  A4,         D2
    ADD.L   #4,         D2
    MOVE.L  D1,         D3
    ADD.L   #2,         D3
    MOVE.L  D2,         D4
    ADD.L   #2,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
    ; Right pupil
    MOVE.L  A3,         D1
    ADD.L   #26,        D1
    MOVE.L  A4,         D2
    ADD.L   #4,         D2
    MOVE.L  D1,         D3
    ADD.L   #2,         D3
    MOVE.L  D2,         D4
    ADD.L   #2,         D4
    MOVE.B  #87,        D0
    TRAP    #15
    
NEXT_ALIEN:
    ADD.L   #1,         D7
    BRA     DRAW_ALIEN_LOOP
    
DRAW_ALIENS_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Initialize Stars
* Description   : Set up random star positions
*-----------------------------------------------------------
INIT_STARS:
    MOVEM.L D0-D7/A0-A1,-(SP)       ; Save registers
    LEA     STAR_X,     A0
    LEA     STAR_Y,     A1
    
    ; Generate pseudo-random star positions using fixed seed pattern
    MOVE.L  #0,         D7          ; Counter
    MOVE.L  #37,        D4          ; Seed X
    MOVE.L  #91,        D5          ; Seed Y
    
INIT_STAR_LOOP:
    CMP.L   #NUM_STARS, D7
    BGE     INIT_STARS_DONE
    
    ; Calculate X position (pseudo-random)
    MOVE.L  D4,         D0
    MULU    #127,       D0
    ADD.L   #17,        D0
    DIVU    #SCR_WIDTH, D0          ; Remainder in upper word
    SWAP    D0
    AND.L   #$FFFF,     D0
    MOVE.L  D0,         (A0)+       ; Store X
    MOVE.L  D0,         D4          ; Update seed
    ADD.L   #73,        D4
    
    ; Calculate Y position (pseudo-random)
    MOVE.L  D5,         D0
    MULU    #97,        D0
    ADD.L   #53,        D0
    MOVE.L  #SCR_HEIGHT,D1
    SUB.L   #100,       D1          ; Keep stars above HUD area
    DIVU    D1,         D0          ; Remainder in upper word
    SWAP    D0
    AND.L   #$FFFF,     D0
    ADD.L   #60,        D0          ; Below top HUD
    MOVE.L  D0,         (A1)+       ; Store Y
    MOVE.L  D0,         D5          ; Update seed
    ADD.L   #41,        D5
    
    ADD.L   #1,         D7
    BRA     INIT_STAR_LOOP
    
INIT_STARS_DONE:
    ; Set star brightness
    LEA     STAR_BRIGHT,A0
    MOVE.L  #0,         D7
    MOVE.L  #0,         D4          ; Brightness cycle
    
INIT_BRIGHT_LOOP:
    CMP.L   #NUM_STARS, D7
    BGE     INIT_BRIGHT_DONE
    
    MOVE.L  D4,         (A0)+
    ADD.L   #1,         D4
    CMP.L   #3,         D4
    BLT     .SKIP_RESET
    MOVE.L  #0,         D4
.SKIP_RESET:
    ADD.L   #1,         D7
    BRA     INIT_BRIGHT_LOOP
    
INIT_BRIGHT_DONE:
    MOVEM.L (SP)+,D0-D7/A0-A1       ; Restore registers
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw Stars
* Description   : Draw twinkling stars in background
*-----------------------------------------------------------
DRAW_STARS:
    MOVEM.L D0-D7/A0-A2,-(SP)       ; Save registers
    
    LEA     STAR_X,     A0
    LEA     STAR_Y,     A1
    LEA     STAR_BRIGHT,A2
    MOVE.L  #0,         D7          ; Counter
    
DRAW_STAR_LOOP:
    CMP.L   #NUM_STARS, D7
    BGE     DRAW_STARS_DONE
    
    ; Get brightness level for color
    MOVE.L  (A2)+,      D6
    
    ; Set star color based on brightness
    CMP.L   #0,         D6
    BEQ     .DIM_STAR
    CMP.L   #1,         D6
    BEQ     .MED_STAR
    
    ; Bright star - white
    MOVE.L  #$00FFFFFF, D1
    BRA     .SET_COLOR
    
.DIM_STAR:
    MOVE.L  #$00666666, D1
    BRA     .SET_COLOR
    
.MED_STAR:
    MOVE.L  #$00AAAAAA, D1
    
.SET_COLOR:
    MOVE.B  #80,        D0
    TRAP    #15
    
    ; Get star position
    MOVE.L  (A0)+,      D1          ; X
    MOVE.L  (A1)+,      D2          ; Y
    
    ; Draw small star (2x2 pixel)
    MOVE.L  D1,         D3
    ADD.L   #2,         D3          ; X + 2
    MOVE.L  D2,         D4
    ADD.L   #2,         D4          ; Y + 2
    
    MOVE.B  #87,        D0          ; Draw filled rectangle
    TRAP    #15
    
    ADD.L   #1,         D7
    BRA     DRAW_STAR_LOOP
    
DRAW_STARS_DONE:
    MOVEM.L (SP)+,D0-D7/A0-A2       ; Restore registers
    RTS

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Game sounds - using traps 74/75/77 for multi-sound support
*-----------------------------------------------------------
SHOOT_LOAD:
    LEA     SHOOT_WAV,  A1          ; Load Wav File into A1
    MOVE    #SHOOT_INDEX,D1         ; Assign it INDEX
    MOVE    #74,        D0          ; Load into memory (trap 74)
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_SHOOT:
    MOVEM.L D0-D7/A0-A6,-(SP)       ; Save registers
    MOVE    #SHOOT_INDEX,D1         ; Load Sound INDEX
    MOVE    #75,        D0          ; Play Sound (trap 75)
    TRAP    #15                     ; Trap (Perform action)
    MOVEM.L (SP)+,D0-D7/A0-A6       ; Restore registers
    RTS                             ; Return to subroutine

HIT_LOAD:
    LEA     HIT_WAV,    A1          ; Load Wav File into A1
    MOVE    #HIT_INDEX, D1          ; Assign it INDEX
    MOVE    #74,        D0          ; Load into memory (trap 74)
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_HIT:
    MOVEM.L D0-D7/A0-A6,-(SP)       ; Save registers
    MOVE    #HIT_INDEX, D1          ; Load Sound INDEX
    MOVE    #75,        D0          ; Play Sound (trap 75)
    TRAP    #15                     ; Trap (Perform action)
    MOVEM.L (SP)+,D0-D7/A0-A6       ; Restore registers
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #74,        D0          ; Load into memory (trap 74)
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVEM.L D0-D7/A0-A6,-(SP)       ; Save registers
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #75,        D0          ; Play Sound (trap 75)
    TRAP    #15                     ; Trap (Perform action)
    MOVEM.L (SP)+,D0-D7/A0-A6       ; Restore registers
    RTS                             ; Return to subroutine

MUSIC_LOAD:
    LEA     MUSIC_WAV,  A1          ; Load Wav File into A1
    MOVE    #MUSIC_INDEX,D1         ; Assign it INDEX
    MOVE    #74,        D0          ; Load into memory (trap 74)
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_MUSIC:
    MOVE    #MUSIC_INDEX,D1         ; Load Sound INDEX
    MOVE.L  #1,         D2          ; D2=1 for loop
    MOVE    #77,        D0          ; Trap 77 = Loop control
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

STOP_MUSIC:
    MOVE    #MUSIC_INDEX,D1         ; Load Sound INDEX
    MOVE.L  #2,         D2          ; D2=2 for stop
    MOVE    #77,        D0          ; Trap 77 = Loop control
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

TIMEFREEZE_LOAD:
    LEA     TIMEFREEZE_WAV,A1       ; Load Wav File into A1
    MOVE    #TIMEFREEZE_INDEX,D1    ; Assign it INDEX
    MOVE    #74,        D0          ; Load into memory (trap 74)
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_TIMEFREEZE:
    MOVEM.L D0-D7/A0-A6,-(SP)       ; Save registers
    MOVE    #TIMEFREEZE_INDEX,D1    ; Load Sound INDEX
    MOVE    #75,        D0          ; Play Sound (trap 75)
    TRAP    #15                     ; Trap (Perform action)
    MOVEM.L (SP)+,D0-D7/A0-A6       ; Restore registers
    RTS

*-----------------------------------------------------------
* Subroutine    : Check Bullet Collisions
* Description   : Check if bullet hits any alien
*-----------------------------------------------------------
CHECK_BULLET_COLLISIONS:
    ; Check if bullet is active
    MOVE.L  BULLET_ACT, D1
    CMP.L   #0,         D1
    BEQ     BULLET_COLL_DONE        ; Not active, skip
    
    ; Get bullet position
    MOVE.L  BULLET_X,   D1          ; Bullet X
    MOVE.L  BULLET_Y,   D2          ; Bullet Y
    
    LEA     ALIENS,     A0          ; Load aliens array
    MOVE.L  #0,         D7          ; Counter
    
CHECK_ALIEN_COLL_LOOP:
    CMP.L   #(ALIEN_ROWS*ALIEN_COLS), D7
    BGE     BULLET_COLL_DONE
    
    ; Check if alien is alive
    MOVE.L  A0,         A1          ; Save A0
    MOVE.L  D7,         D6
    MULU    #4,         D6
    ADDA.L  D6,         A1
    MOVE.L  (A1),       D3
    CMP.L   #0,         D3
    BEQ     NEXT_ALIEN_COLL         ; Dead, skip
    
    ; Calculate alien position
    MOVE.L  D7,         D3
    DIVU    #ALIEN_COLS,D3          ; D3.W = row
    MOVE.W  D3,         D4          ; D4 = row
    SWAP    D3
    MOVE.W  D3,         D5          ; D5 = col
    
    ; Calculate alien X: ALIENS_X + col * ALIEN_GAP
    CLR.L   D3
    MOVE.W  D5,         D3
    MULU    #ALIEN_GAP, D3
    ADD.L   ALIENS_X,   D3          ; Alien X in D3
    
    ; Calculate alien Y: ALIENS_Y + row * (ALIEN_H + 10)
    CLR.L   D6
    MOVE.W  D4,         D6
    MULU    #(ALIEN_H+10),D6
    ADD.L   ALIENS_Y,   D6          ; Alien Y in D6
    
    ; Simple AABB collision check
    ; Bullet center vs alien bounds
    MOVE.L  BULLET_X,   D1
    ADD.L   #BULLET_W/2,D1          ; Bullet center X
    
    ; Check X bounds
    CMP.L   D3,         D1          ; Bullet X < Alien X?
    BLT     NEXT_ALIEN_COLL
    MOVE.L  D3,         D4
    ADD.L   #ALIEN_W,   D4
    CMP.L   D4,         D1          ; Bullet X > Alien X + W?
    BGT     NEXT_ALIEN_COLL
    
    ; Check Y bounds
    MOVE.L  BULLET_Y,   D2
    CMP.L   D6,         D2          ; Bullet Y < Alien Y?
    BLT     NEXT_ALIEN_COLL
    MOVE.L  D6,         D4
    ADD.L   #ALIEN_H,   D4
    CMP.L   D4,         D2          ; Bullet Y > Alien Y + H?
    BGT     NEXT_ALIEN_COLL
    
    ; HIT! Kill alien and deactivate bullet
    BSR     PLAY_HIT
    MOVE.L  #0,         (A1)        ; Kill alien
    MOVE.L  #0,         BULLET_ACT  ; Deactivate bullet
    MOVE.L  #BULLET_OFF,BULLET_Y
    
    ; Add points
    MOVE.L  PLAYER_SCORE,D1
    ADD.L   #POINTS,    D1
    MOVE.L  D1,         PLAYER_SCORE
    
    BRA     BULLET_COLL_DONE
    
NEXT_ALIEN_COLL:
    ADD.L   #1,         D7
    BRA     CHECK_ALIEN_COLL_LOOP
    
BULLET_COLL_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Check if aliens reached bottom
* Description   : Game over if aliens reach ship
*-----------------------------------------------------------
CHECK_ALIEN_REACHED:
    ; Calculate lowest alien Y position
    MOVE.L  ALIENS_Y,   D1
    ADD.L   #(ALIEN_ROWS*(ALIEN_H+10)), D1
    
    ; Compare with ship Y
    MOVE.L  SHIP_Y,     D2
    CMP.L   D2,         D1
    BGE     SET_GAME_OVER
    RTS

SET_GAME_OVER:
    BSR     PLAY_OPPS
    MOVE.L  #1,         GAME_OVER
    RTS

*-----------------------------------------------------------
* Subroutine    : Check Next Wave
* Description   : If all aliens dead, spawn next wave (faster)
*-----------------------------------------------------------
CHECK_NEXT_WAVE:
    LEA     ALIENS,     A0
    MOVE.L  #(ALIEN_ROWS*ALIEN_COLS)-1, D7
    
CHECK_WAVE_LOOP:
    MOVE.L  (A0)+,      D1
    CMP.L   #1,         D1          ; Any alien alive?
    BEQ     WAVE_NOT_DONE
    DBRA    D7,         CHECK_WAVE_LOOP
    
    ; All aliens dead - spawn next wave!
    BSR     PLAY_HIT                ; Sound for new wave
    
    ; Increment wave number
    MOVE.L  WAVE_NUM,   D1
    ADD.L   #1,         D1
    MOVE.L  D1,         WAVE_NUM
    
    ; Increase alien speed by 3 each wave
    MOVE.L  CURRENT_ALIEN_SPD,D1
    ADD.L   #3,         D1          ; Add 3 speed per wave
    CMP.L   #20,        D1          ; Cap at speed 20
    BLE     SET_NEW_SPEED
    MOVE.L  #20,        D1
SET_NEW_SPEED:
    MOVE.L  D1,         CURRENT_ALIEN_SPD
    
    ; Reset aliens
    BSR     INIT_ALIENS
    
    ; Add bonus points for completing wave
    MOVE.L  PLAYER_SCORE,D1
    ADD.L   #50,        D1          ; 50 bonus points per wave
    MOVE.L  D1,         PLAYER_SCORE
    
WAVE_NOT_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : Init Alien Bullets
* Description   : Initialize alien bullet array
*-----------------------------------------------------------
INIT_ALIEN_BULLETS:
    LEA     ALN_BLT_ACT,A0
    MOVE.L  #MAX_ALN_BLT-1,D7
INIT_ABL_LOOP:
    MOVE.L  #0,         (A0)+       ; Set inactive
    DBRA    D7,         INIT_ABL_LOOP
    RTS

*-----------------------------------------------------------
* Subroutine    : Alien Shoot Random
* Description   : Randomly fire bullets from alive aliens
*-----------------------------------------------------------
ALIEN_SHOOT_RANDOM:
    ; Generate random number to decide if we shoot
    BSR     GET_RANDOM
    AND.L   #$FF,       D1          ; Limit to 0-255
    CMP.L   #4,         D1          ; ~1.5% chance each frame
    BGT     NO_ALIEN_SHOT
    
    ; Count alive aliens first
    LEA     ALIENS,     A0
    MOVE.L  #0,         D5          ; Alive count
    MOVE.L  #(ALIEN_ROWS*ALIEN_COLS)-1, D7
COUNT_ALIVE_LOOP:
    MOVE.L  (A0)+,      D1
    CMP.L   #1,         D1
    BNE     .NOT_ALIVE
    ADD.L   #1,         D5
.NOT_ALIVE:
    DBRA    D7,         COUNT_ALIVE_LOOP
    
    ; If no aliens alive, skip
    CMP.L   #0,         D5
    BEQ     NO_ALIEN_SHOT
    
    ; Pick random index from 0 to (alive_count-1)
    BSR     GET_RANDOM
    AND.L   #$FFFF,     D1
    DIVU    D5,         D1          ; D1.W = quotient, high word = remainder
    SWAP    D1
    AND.L   #$FFFF,     D1          ; D1 = random index (0 to alive_count-1)
    
    ; Find the Nth alive alien
    LEA     ALIENS,     A0
    MOVE.L  #0,         D7          ; Alien array index
    MOVE.L  #-1,        D6          ; Alive counter (will increment to 0 on first find)
    
FIND_NTH_ALIEN:
    CMP.L   #(ALIEN_ROWS*ALIEN_COLS), D7
    BGE     NO_ALIEN_SHOT           ; Safety check
    
    MOVE.L  (A0)+,      D2
    CMP.L   #1,         D2
    BNE     .SKIP_DEAD
    
    ; Found alive alien, increment counter
    ADD.L   #1,         D6
    CMP.L   D1,         D6          ; Is this the one we want?
    BEQ     ALIEN_SELECTED
    
.SKIP_DEAD:
    ADD.L   #1,         D7
    BRA     FIND_NTH_ALIEN
    
ALIEN_SELECTED:
    ; D7 now has the alien index
    ; Calculate alien position for bullet spawn
    MOVE.L  D7,         D3
    DIVU    #ALIEN_COLS,D3
    MOVE.W  D3,         D4          ; Row
    SWAP    D3
    MOVE.W  D3,         D5          ; Col
    
    ; Alien X position
    CLR.L   D1
    MOVE.W  D5,         D1
    MULU    #ALIEN_GAP, D1
    ADD.L   ALIENS_X,   D1
    ADD.L   #ALIEN_W/2, D1          ; Center of alien
    
    ; Alien Y position
    CLR.L   D2
    MOVE.W  D4,         D2
    MULU    #(ALIEN_H+10),D2
    ADD.L   ALIENS_Y,   D2
    ADD.L   #ALIEN_H,   D2          ; Bottom of alien
    
    ; Find inactive bullet slot
    BSR     FIRE_ALIEN_BULLET
    
NO_ALIEN_SHOT:
    RTS

*-----------------------------------------------------------
* Subroutine    : Fire Alien Bullet
* Description   : Spawn alien bullet at D1,D2 position
*-----------------------------------------------------------
FIRE_ALIEN_BULLET:
    LEA     ALN_BLT_ACT,A0
    LEA     ALN_BLT_X,  A1
    LEA     ALN_BLT_Y,  A2
    MOVE.L  #MAX_ALN_BLT-1,D7
FIND_SLOT:
    MOVE.L  (A0)+,      D3
    CMP.L   #0,         D3
    BEQ     FOUND_SLOT
    ADDA.L  #4,         A1
    ADDA.L  #4,         A2
    DBRA    D7,         FIND_SLOT
    RTS                             ; No slots available
    
FOUND_SLOT:
    MOVE.L  #1,         -4(A0)      ; Set active
    MOVE.L  D1,         (A1)        ; Set X
    MOVE.L  D2,         (A2)        ; Set Y
    RTS

*-----------------------------------------------------------
* Subroutine    : Update Alien Bullets
* Description   : Move alien bullets downward
*-----------------------------------------------------------
UPDATE_ALIEN_BULLETS:
    ; Check if slow motion is active for bullet speed
    MOVE.L  SLOW_ACTIVE,D6
    CMP.L   #1,         D6
    BNE     UPDATE_ABL_NORMAL
    
    ; Slow motion active - only move every 4th frame
    MOVE.L  ABL_SLOW_CNT,D6
    ADD.L   #1,         D6
    CMP.L   #4,         D6          ; Move every 4th frame
    BLT     SKIP_ABL_UPDATE
    CLR.L   D6
    MOVE.L  D6,         ABL_SLOW_CNT
    BRA     DO_ABL_UPDATE
    
SKIP_ABL_UPDATE:
    MOVE.L  D6,         ABL_SLOW_CNT
    RTS
    
UPDATE_ABL_NORMAL:
    MOVE.L  #0,         ABL_SLOW_CNT ; Reset counter when not in slow-mo
    
DO_ABL_UPDATE:
    LEA     ALN_BLT_ACT,A0
    LEA     ALN_BLT_Y,  A1
    MOVE.L  #MAX_ALN_BLT-1,D7
UPD_ABL_LOOP:
    MOVE.L  (A0),       D1
    CMP.L   #0,         D1
    BEQ     NEXT_ABL
    
    ; Move bullet down
    MOVE.L  (A1),       D1
    ADD.L   #ALN_BLT_SPD,D1
    MOVE.L  D1,         (A1)
    
    ; Check if off screen
    CLR.L   D2
    MOVE.W  SCREEN_H,   D2
    CMP.L   D2,         D1
    BGE     DEACT_ABL
    BRA     NEXT_ABL
    
DEACT_ABL:
    MOVE.L  #0,         (A0)        ; Deactivate
    
NEXT_ABL:
    ADDA.L  #4,         A0
    ADDA.L  #4,         A1
    DBRA    D7,         UPD_ABL_LOOP
    RTS

*-----------------------------------------------------------
* Subroutine    : Check Alien Bullet Hit
* Description   : Check if player is hit by alien bullet
*-----------------------------------------------------------
CHECK_ALIEN_BULLET_HIT:
    LEA     ALN_BLT_ACT,A0
    LEA     ALN_BLT_X,  A1
    LEA     ALN_BLT_Y,  A2
    MOVE.L  #MAX_ALN_BLT-1,D7
CHK_HIT_LOOP:
    MOVE.L  (A0),       D1
    CMP.L   #0,         D1
    BEQ     NEXT_HIT_CHK
    
    ; Get bullet position
    MOVE.L  (A1),       D1          ; Bullet X
    MOVE.L  (A2),       D2          ; Bullet Y
    
    ; Check collision with ship
    MOVE.L  SHIP_X,     D3
    CMP.L   D3,         D1
    BLT     NEXT_HIT_CHK
    ADD.L   #SHIP_W,    D3
    CMP.L   D3,         D1
    BGT     NEXT_HIT_CHK
    
    MOVE.L  SHIP_Y,     D3
    CMP.L   D3,         D2
    BLT     NEXT_HIT_CHK
    ADD.L   #SHIP_H,    D3
    CMP.L   D3,         D2
    BGT     NEXT_HIT_CHK
    
    ; HIT! Game over
    BSR     PLAY_OPPS
    MOVE.L  #1,         GAME_OVER
    MOVE.L  #0,         (A0)        ; Deactivate bullet
    RTS
    
NEXT_HIT_CHK:
    ADDA.L  #4,         A0
    ADDA.L  #4,         A1
    ADDA.L  #4,         A2
    DBRA    D7,         CHK_HIT_LOOP
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw Alien Bullets
* Description   : Draw all active alien bullets (cyan)
*-----------------------------------------------------------
DRAW_ALIEN_BULLETS:
    LEA     ALN_BLT_ACT,A0
    LEA     ALN_BLT_X,  A1
    LEA     ALN_BLT_Y,  A2
    MOVE.L  #MAX_ALN_BLT-1,D7
DRAW_ABL_LOOP:
    MOVE.L  (A0)+,      D1
    CMP.L   #0,         D1
    BEQ     NEXT_ABL_DRAW
    
    ; Set color (Cyan for alien bullets)
    MOVE.L  #CYAN,      D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    ; Draw bullet
    MOVE.L  (A1),       D1          ; X
    MOVE.L  (A2),       D2          ; Y
    MOVE.L  D1,         D3
    ADD.L   #ALN_BLT_W, D3          ; X + W
    MOVE.L  D2,         D4
    ADD.L   #ALN_BLT_H, D4          ; Y + H
    MOVE.B  #87,        D0
    TRAP    #15
    
NEXT_ABL_DRAW:
    ADDA.L  #4,         A1
    ADDA.L  #4,         A2
    DBRA    D7,         DRAW_ABL_LOOP
    RTS

*-----------------------------------------------------------
* Subroutine    : Get Random
* Description   : Improved pseudo-random number generator
*-----------------------------------------------------------
GET_RANDOM:
    MOVE.L  RANDOM_SEED,D1
    MOVE.L  D1,         D2
    LSL.L   #5,         D2          ; Multiply by 32
    ADD.L   D2,         D1
    MOVE.L  D1,         D2
    LSR.L   #7,         D2          ; Add some high bits
    EOR.L   D2,         D1
    ADD.L   #12345,     D1          ; Add constant
    MOVE.L  D1,         RANDOM_SEED
    RTS

*-----------------------------------------------------------
* Subroutine    : Update Slow Motion
* Description   : Check if slow motion should end
*-----------------------------------------------------------
UPDATE_SLOW_MOTION:
    ; Check if slow motion is active
    MOVE.L  SLOW_ACTIVE,D1
    CMP.L   #0,         D1
    BEQ     SLOW_UPDATE_DONE
    
    ; Check if duration has ended
    MOVE.B  #8,         D0          ; Get current time
    TRAP    #15
    MOVE.L  D1,         D2          ; Current time in D2
    MOVE.L  SLOW_END_TIME,D3
    CMP.L   D3,         D2          ; Current time >= end time?
    BLT     SLOW_UPDATE_DONE        ; Not yet
    
    ; Deactivate slow motion
    MOVE.L  #0,         SLOW_ACTIVE
    MOVE.L  #0,         SLOW_FRAME
    
    ; Set cooldown ready time = current time + cooldown
    ADD.L   #SLOW_COOLDOWN,D2
    MOVE.L  D2,         SLOW_READY_TIME
    
SLOW_UPDATE_DONE:
    RTS

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console
*-----------------------------------------------------------
; Title Screen ASCII Art
TITLE_1     DC.B    '  _____ _            ____                _          ___     ',0
TITLE_2     DC.B    ' |_   _| |__   ___  / ___|_ __ ___  __ _| |_    ___/   \___ ',0
TITLE_3     DC.B    '   | | | `_ \ / _ \| |  _| `__/ _ \/ _` | __|  /   "---"   \',0
TITLE_4     DC.B    '   | | | | | |  __/| |_| | | |  __/ (_| | |_   "--_______--"',0
TITLE_5     DC.B    '   |_| |_| |_|\___| \____|_|  \___|\__,_|\__|       / \     ',0
TITLE_6     DC.B    '       ____                          _             /   \    ',0
SHIP_ART3   DC.B    '                  === SPACE ADVENTURE ===                   ',0
PRESS_KEY   DC.B    '           >>> PRESS SPACE OR ENTER TO START <<<            ',0
CONTROLS1   DC.B    '                         CONTROLS:                          ',0
CONTROLS2   DC.B    '           LEFT/RIGHT - Move Ship | SPACE - Shoot           ',0
CONTROLS3   DC.B    '                UP - Time Stop | ESC - Exit                 ',0

SCORE_MSG       DC.B    'SCORE : ', 0       ; Score Message
WAVE_MSG        DC.B    'WAVE: ', 0          ; Wave Message
SLOW_RDY_MSG    DC.B    '[UP] SLOW: READY', 0
SLOW_ON_MSG     DC.B    '[UP] SLOW: ACTIVE!', 0
SLOW_CD_MSG     DC.B    '[UP] SLOW CD: ', 0
TIMESTOP_MSG    DC.B    '*** TIME STOP ABILITY ACTIVATED ***', 0
GAMEOVER_MSG    DC.B    '*** GAME OVER ***', 0
FINAL_SCORE_MSG DC.B    'FINAL SCORE: ', 0
RESTART_MSG     DC.B    'Press ESC to play again', 0
EXIT_MSG        DC.B    'Exiting....', 0

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
GREEN           EQU     $0000FF00
YELLOW          EQU     $0000FFFF
CYAN            EQU     $00FFFF00

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Player Ship Position
* Description   : Ship position and bullet data
*-----------------------------------------------------------
SHIP_X          DS.L    01  ; Ship X Position
SHIP_Y          DS.L    01  ; Ship Y Position
PLAYER_SCORE    DS.L    01  ; Player Score

BULLET_X        DS.L    01  ; Bullet X Position
BULLET_Y        DS.L    01  ; Bullet Y Position
BULLET_ACT      DS.L    01  ; Bullet Active (1=yes, 0=no)

*-----------------------------------------------------------
* Section       : Alien Data
* Description   : Alien formation position and state
*-----------------------------------------------------------
ALIENS_X        DS.L    01  ; Alien formation X position
ALIENS_Y        DS.L    01  ; Alien formation Y position
ALIEN_DIR       DS.L    01  ; Alien direction (1=right, -1=left)
ALIENS          DS.L    ALIEN_ROWS*ALIEN_COLS  ; Array of alien alive states

*-----------------------------------------------------------
* Section       : Game State
* Description   : Game over flag (0=playing, 1=lost, 2=won)
*-----------------------------------------------------------
GAME_OVER       DS.L    01  ; Game over flag

*-----------------------------------------------------------
* Section       : Alien Bullets
* Description   : Alien bullet positions and states
*-----------------------------------------------------------
ALN_BLT_X       DS.L    MAX_ALN_BLT  ; Alien bullet X positions
ALN_BLT_Y       DS.L    MAX_ALN_BLT  ; Alien bullet Y positions
ALN_BLT_ACT     DS.L    MAX_ALN_BLT  ; Alien bullet active flags
ABL_SLOW_CNT    DS.L    01           ; Alien bullet slow motion frame counter

*-----------------------------------------------------------
* Section       : Random & Timing
* Description   : Random seed
*-----------------------------------------------------------
RANDOM_SEED     DS.L    01  ; Random number seed

*-----------------------------------------------------------
* Section       : Slow Motion
* Description   : Slow motion ability state
*-----------------------------------------------------------
SLOW_ACTIVE     DS.L    01  ; Is slow motion active? (1=yes, 0=no)
SLOW_END_TIME   DS.L    01  ; When slow motion ends
SLOW_READY_TIME DS.L    01  ; When slow motion can be used again
SLOW_FRAME      DS.L    01  ; Frame counter for slow motion

*-----------------------------------------------------------
* Section       : Wave System
* Description   : Infinite wave spawning
*-----------------------------------------------------------
WAVE_NUM        DS.L    01  ; Current wave number
CURRENT_ALIEN_SPD DS.L  01  ; Current alien speed (increases each wave)
ALIEN_MOVE_CNT  DS.L    01  ; Frame counter for alien movement delay

*-----------------------------------------------------------
* Section       : Stars
* Description   : Background stars
*-----------------------------------------------------------
STAR_X          DS.L    NUM_STARS  ; Star X positions
STAR_Y          DS.L    NUM_STARS  ; Star Y positions
STAR_BRIGHT     DS.L    NUM_STARS  ; Star brightness (0-2)

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files
*-----------------------------------------------------------
SHOOT_WAV       DC.B    'shoot.wav',0       ; Shoot Sound
HIT_WAV         DC.B    'hit.wav',0         ; Hit Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Game Over Sound
MUSIC_WAV       DC.B    'music.wav',0       ; Background Music
TIMEFREEZE_WAV  DC.B    'timefreeze.wav',0  ; Time Freeze Sound

*-----------------------------------------------------------
* Section       : Time Stop Message
* Description   : Timer for displaying time stop message
*-----------------------------------------------------------
TIMESTOP_MSG_TIME DS.L  01  ; When to stop showing time stop message

    END    START        ; last line of sourcece


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

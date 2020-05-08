%include "/usr/local/share/csc314/asm_io.inc"


;INPUT FILE THAT STORES THE INITIAL BOARD FILE
%define BOARD_FILE 'board.txt'

;HOW THE REPRESENT CHARACTERS
%define WALL_CHAR '#'
%define PLAYER_CHAR 'O'
%define FOOD_CHAR '*'
%define EMPTY_CHAR ' '
%define TAIL_CHAR 'o'
%define AUTO_WIN 'k'
%define PAUSE_CHAR 'p'
%define INVIN_CHAR 'i'

;GAME RESOLUTION
%define HEIGHT 40
%define WIDTH 80

;PLAYER AND FOOD STARTING STATES
%define STARTX 1
%define STARTY 1
%define FOODX 15
%define FOODY 15
%define TOTALFOOD 0

;CONTROL CHARACTERS
%define EXITCHAR 'x'
%define RESTARTCHAR 'r'
%define UPCHAR 'w'
%define LEFTCHAR 'a'
%define DOWNCHAR 's'
%define RIGHTCHAR 'd'

;STARTING TIME
%define STARTTIME 1000

;1/10TH OF A SECOND
%define TICK 100000
%define LOADWAIT 1000000

segment .data

        ;USED TO OPEN THE BOARD FILE ABOVE
        board_file                      db BOARD_FILE,0

        ;TAIL ARRAYS UP TO SIZE 150
        xtail                           dd      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ytail                           dd      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,

        ;USED TO CHANGE THE TERMINAL MODE
        mode_r                          db "r",0
        raw_mode_on_cmd         db "stty raw -echo",0
        raw_mode_off_cmd        db "stty -raw echo",0

        ;CLEARS THE SCREEN
        clear_screen_cmd        db "clear",0

        ;INFORMATION THAT GETS PRINTED TO THE SCREEN
        title_str                       db 13,10,"                                                                         ",10,13, \
                                                                 "         ",27,"[36;1m_______    ____  _____        __        ___  ____     _________ ",10,13, \
                                                                                         "        /  ___  |  |_   \|_   _|      /  \      |_  ||_  _|   |_   ___  |",10,13, \
                                                                                         "       |  (__ \_|    |   \ | |       / /\ \       | |_/ /       | |_  \_|",10,13, \
                                                                                         "        '.___`-.     | |\ \| |      / ____ \      |  __'.       |  _|  _ ",10,13, \
                                                                                         "       |`\____) |   _| |_\   |_   _/ /    \ \_   _| |  \ \_    _| |___/ |",10,13, \
                                                                                         "       |_______.'  |_____|\____| |____|  |____| |____||____|  |_________|",10,13, \
                                                                                         "                                                                         ",27,"[0m",13,10,0
        help_str                        db 13,10,"   CONTROLS: ", \
                                                        "W=UP | ", \
                                                        "A=LEFT | ", \
                                                        "S=DOWN | ", \
                                                        "D=RIGHT | ", \
                                                        "X=EXIT | ", \
                                                        "R=RESTART | ", \
                                                        "P=Pause", \
                                                        13,10,10,0
        score_tracker           db "Food Eaten: %d                   ",0
        load_scr                        db 13,10,10,10,10,10,10,10,10,10,10,10,27,"[91;1m   7MMF         .g8==8q.      db       7MM===Yb.  7MMF  7MN.    7MF  .g8===bgd  ",10,13, \
                                                                                                                                  "    MM        .dP      YM.   ;MM:       MM     Yb. MM    MMN.    M .dP       M  ",10,13, \
                                                                                                                                  "    MM        dM        MM  .V^MM.      MM      Mb MM    M YMb   M dM           ",10,13, \
                                                                                                                                  "    MM        MM        MM .M   MM      MM      MM MM    M   MN. M MM           ",10,13, \
                                                                                                                                  "    MM        MM.       MP AbmmmqMA     MM      MP MM    M    MM.M MM.     7MMF ",10,13, \
                                                                                                                                  "    MM      M  Mb.     dP A      VML    MM     dP  MM    M     YMM  Mb.     MM  ",10,13, \
                                                                                                                                  "  .JMMmmmmMMM    YbmmdY .AMA.   .AMMA..JMMmmmdP  .JMML..JML.    YM    YbmmmdPY  ",27,"[0m",10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,13,0
        load_scr2                       db 13,10,10,10,10,10,10,10,10,10,10,10,27,"[93;1m   7MMF         .g8==8q.      db       7MM===Yb.  7MMF  7MN.    7MF  .g8===bgd  ",10,13, \
                                                                                                                                  "    MM        .dP      YM.   ;MM:       MM     Yb. MM    MMN.    M .dP       M  ",10,13, \
                                                                                                                                  "    MM        dM        MM  .V^MM.      MM      Mb MM    M YMb   M dM           ",10,13, \
                                                                                                                                  "    MM        MM        MM .M   MM      MM      MM MM    M   MN. M MM           ",10,13, \
                                                                                                                                  "    MM        MM.       MP AbmmmqMA     MM      MP MM    M    MM.M MM.     7MMF ",10,13, \
                                                                                                                                  "    MM      M  Mb.     dP A      VML    MM     dP  MM    M     YMM  Mb.     MM  ",10,13, \
                                                                                                                                  "  .JMMmmmmMMM    YbmmdY .AMA.   .AMMA..JMMmmmdP  .JMML..JML.    YM    YbmmmdPY  ",27,"[0m",10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,13,0
        load_scr3                       db 13,10,10,10,10,10,10,10,10,10,10,10,27,"[92;1m   7MMF         .g8==8q.      db       7MM===Yb.  7MMF  7MN.    7MF  .g8===bgd  ",10,13, \
                                                                                                                                  "    MM        .dP      YM.   ;MM:       MM     Yb. MM    MMN.    M .dP       M  ",10,13, \
                                                                                                                                  "    MM        dM        MM  .V^MM.      MM      Mb MM    M YMb   M dM           ",10,13, \
                                                                                                                                  "    MM        MM        MM .M   MM      MM      MM MM    M   MN. M MM           ",10,13, \
                                                                                                                                  "    MM        MM.       MP AbmmmqMA     MM      MP MM    M    MM.M MM.     7MMF ",10,13, \
                                                                                                                                  "    MM      M  Mb.     dP A      VML    MM     dP  MM    M     YMM  Mb.     MM  ",10,13, \
                                                                                                                                  "  .JMMmmmmMMM    YbmmdY .AMA.   .AMMA..JMMmmmdP  .JMML..JML.    YM    YbmmmdPY  ",27,"[0m",10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,13,0
        begin_str                       db 13,10,10,10,"                          ",27,"[1;4mPRESS [ENTER] KEY TO BEGIN",27,"[0m",13,10,10,10,10,10,10,10,10,0

        ;PLAYER SIZE OPTIONS
        size_1                          db 27,"[31mHatchling",27,"[0m","                       ",0
        size_2                          db 27,"[31mBaby Snek",27,"[0m","                       ",0
        size_3                          db 27,"[91mAdole-snek",27,"[0m","                      ",0
        size_4                          db 27,"[91mSnaky Teen",27,"[0m","                      ",0
        size_5                          db 27,"[33mMid-Sized Vermin",27,"[0m","                ",0
        size_6                          db 27,"[33mLong n' Slender Boi",27,"[0m","             ",0
        size_7                          db 27,"[93mGirthy Serpent",27,"[0m","                  ",0
        size_8                          db 27,"[93mMuscular Snake",27,"[0m","                  ",0
        size_9                          db 27,"[32mAnaconda Shamer",27,"[0m","                 ",0
        size_10                         db 27,"[92mBig Ol' Cuss",27,"[0m","                    ",0

        timer_str                       db "Time left: %d",13,10,0
        you_win                         db "             ",27,"[93;1m:::   :::  ::::::::  :::    :::      :::       :::  ::::::::  ::::    :::",10,13, \
                                                                           "             :+:   :+: :+:    :+: :+:    :+:      :+:       :+: :+:    :+: :+:+:   :+:",10,13, \
                                                                           "              +:+ +:+  +:+    +:+ +:+    +:+      +:+       +:+ +:+    +:+ :+:+:+  +:+",10,13, \
                                                                           "               +#++:   +#+    +:+ +#+    +:+      +#+  +:+  +#+ +#+    +:+ +#+ +:+ +#+",10,13, \
                                                                           "                +#+    +#+    +#+ +#+    +#+      +#+ +#+#+ +#+ +#+    +#+ +#+  +#+#+#",10,13, \
                                                                           "                #+#    #+#    #+# #+#    #+#       #+#+# #+#+#  #+#    #+# #+#   #+#+#",10,13, \
                                                                           "                ###     ########   ########         ###   ###    ########  ###    ####",27,"[0m",13,10,0
        win_over                        db "                                        ,      :      ,                                          ",10,13, \
                                                   "                              ___  .     ;     :     ;     .                                     ",10,13, \
                           "                            _/XXX\  '.    ;    :    ;    .'                                      ",10,13, \
                           "            __             /XXXXXX\_  '.   ;   :   ;   .'   .-          __                       ",10,13, \
                           "           /XX\__    __   /X XXXX XX\   '.  ;  :  ;  .'  .-'   _       /XX\__      ___      _    ",10,13, \
                           "          / /   X\__/XX\_/__       \ \-.  '. ' , ' .' .-' ..._/X\__   /XX XXX\____/XXX\        /X\   ",10,13, \
                           "\     ___/ /   \  ___   \/  \_      \ \ '-. '     '.- __'' _/      \_/  _/  -   __  -  \__/   \  ",10,13, \
                           " \___/ __     ___/   \__/   \ \__     \\__  .:::::.  /  \_/   _ _ \  \     __  /  \____/       \ ",10,13, \
                           "_ \ /    \   /  __    \  /     \ \_   _/ _\;:::::::;/    /            \___/  \/     __/         \",10,13, \
                           "___\________/__/_______\________\__\_/________\:::/_____/_____________/_______\____/_____________",10,13, \
                           "                                               /|\                                               ",10,13, \
                           "                                              / | \                                              ",10,13, \
                           "                                             /  |  \                                             ",10,13, \
                           "                                            /   |   \                                            ",10,13, \
                           "                                           /    |    \                                           ",10,13, \
                           "                                          /     |     \                                          ",10,13, \
                           "                                         /      |      \                                         ",10,13, \
                           "                                        /       |       \                                        ",10,13, \
                           "                                       /        |        \                                       ",10,13, \
                           "                                      /         |         \                                      ",13,10,0
        high_score                      db 13,10,10,"                                           ",27,"[1;4mHIGH SCORE : %d",27,"[0m",13,10,10,10,0
        win_high_score          db 13,10,"                                           ",27,"[1;4mHIGH SCORE : %d",27,"[0m",13,10,10,0
        game_over                       db 13,10,10,10,10,10,27,"[91;1m ::::::::      :::     ::::    ::::  ::::::::::       ::::::::  :::     ::: :::::::::: ::::::::: ",10,13, \
                                                                                                          ":+:    :+:   :+: :+:   +:+:+: :+:+:+ :+:             :+:    :+: :+:     :+: :+:        :+:    :+:",10,13, \
                                                                                                          "+:+         +:+   +:+  +:+ +:+:+ +:+ +:+             +:+    +:+ +:+     +:+ +:+        +:+    +:+",10,13, \
                                                                                                          ":#:        +#++:++#++: +#+  +:+  +#+ +#++:++#        +#+    +:+ +#+     +:+ +#++:++#   +#++:++#: ",10,13, \
                                                                                                          "+#+   +#+# +#+     +#+ +#+       +#+ +#+             +#+    +#+  +#+   +#+  +#+        +#+    +#+",10,13, \
                                                                                                          "#+#    #+# #+#     #+# #+#       #+# #+#             #+#    #+#   #+#+#+#   #+#        #+#    #+#",10,13, \
                                                                                                          " ########  ###     ### ###       ### ##########       ########      ###     ########## ###    ###",27,"[0m",13,10,10,10,0
        credits_str                     db "                                         ",27,"[91;1m|||GAME CREDITS|||",10,13, \
                                                   "                      | Large amount of 'Boilerplate' Courtesy of Andrew Kramer |",10,13, \
                                                   "                            | Original Snake Game Creator Taneli Armanto |",10,13, \
                                                   "                              | Snake ASCII art made by Marcin Glinski |",10,13, \
                                                   "                        | Assembly Snake Game Programming by Keinen Bousquet |",27,"[0m",13,10,10,0
        win_credits_str         db "                                         ",27,"[93;1m|||GAME CREDITS|||",10,13, \
                                                   "                      | Large amount of 'Boilerplate' Courtesy of Andrew Kramer |",10,13, \
                                                   "                            | Original Snake Game Creator Taneli Armanto |",10,13, \
                                                   "                              | Snake ASCII art made by Marcin Glinski |",10,13, \
                                                   "                        | Assembly Snake Game Programming by Keinen Bousquet |",27,"[0m",13,10,0
        play_again                      db 13,10,10,10,10,10,"                                  ",27,"[1;4mDo You Want To Play Again? (Y/N)",27,"[0m",13,10,0
        snake_art                       db 13,10,10,10,27,"[32;1m                                /^\/^\                                      ",13,10, \
                                                                        "                              _|__|  O|                                     ",13,10, \
                                                                        "                     \/     /~     \_/ \                                    ",13,10, \
                                                                        "                      \____|__________/  \                                  ",13,10, \
                                                                        "                             \_______      \                                ",13,10, \
                                                                        "                                     `\     \                 \             ",13,10, \
                                                                        "                                       |     |                  \           ",13,10, \
                                                                        "                                      /      /                    \         ",13,10, \
                                                                        "                                     /     /                       \\       ",13,10, \
                                                                        "                                   /      /                         \ \     ",13,10, \
                                                                        "                                  /     /                            \  \   ",13,10, \
                                                                        "                                /     /             _----_            \   \ ",13,10, \
                                                                        "                               /     /           _-~      ~-_         |   | ",13,10, \
                                                                        "                              (      (        _-~    _--_    ~-_     _/   | ",13,10, \
                                                                        "                               \      ~-____-~    _-~    ~-_    ~-_-~    /  ",13,10, \
                                                                        "                                 ~-_           _-~          ~-_       _-~   ",13,10, \
                                                                        "                                    ~--______-~                ~-___-~      ",27,"[0m",13,10,10,0
        start_snake_art         db 13,10,10,10,10,27,"[32;1m                       /^\/^\                                      ",13,10, \
                                                                           "                     _|__|  O|                                     ",13,10, \
                                                                           "            \/     /~     \_/ \                                    ",13,10, \
                                                                           "             \____|__________/  \                                  ",13,10, \
                                                                           "                    \_______      \                                ",13,10, \
                                                                           "                            `\     \                 \             ",13,10, \
                                                                           "                              |     |                  \           ",13,10, \
                                                                           "                             /      /                    \         ",13,10, \
                                                                           "                            /     /                       \\       ",13,10, \
                                                                           "                          /      /                         \ \     ",13,10, \
                                                                           "                         /     /                            \  \   ",13,10, \
                                                                   "                       /     /             _----_            \   \ ",13,10, \
                                                                           "                      /     /           _-~      ~-_         |   | ",13,10, \
                                                                           "                     (      (        _-~    _--_    ~-_     _/   | ",13,10, \
                                                                           "                      \      ~-____-~    _-~    ~-_    ~-_-~    /  ",13,10, \
                                                                           "                        ~-_           _-~          ~-_       _-~   ",13,10, \
                                                                           "                           ~--______-~                ~-___-~      ",13,10,10, \
                                                                           "                                                                   ",27,"[0m",13,10,0
        loading_tip1            db 13,10,27,"[93m          TIP: Don't hold down the move key, it may send you into a wall",27,"[0m",13,10,0
        loading_tip2            db 13,10,27,"[93m     TIP: There are hidden cheat codes for this game. Find the README.txt file.",27,"[0m",13,10,0
        loading_tip3            db 13,10,27,"[93m           TIP: If you suddenly die, you accidentally went backwards.",27,"[0m",13,10,0
        loading_tip4            db 13,10,27,"[93m              TIP: If you eat 150 pieces of food, you win the game!",27,"[0m",13,10,0
        loading_tip5            db 13,10,27,"[93m           TIP: You recieve 45 seconds for every piece of food you eat!",27,"[0m",13,10,0

segment .bss

        ;ARRAY TO STORE CURRENT GAMEBOARD
        board   resb    (HEIGHT * WIDTH)

        ;STORE THE PLAYER HEAD AND TAIL POSITIONS
        xpos    resd    1
        ypos    resd    1

        ;STORE THE FOOD X AND Y POSITIONS
        xfood   resd    1
        yfood   resd    1

        ;STORE THE LENGTH OF THE SNAKE AND TAIL BOOLEAN
        length  resd    1
        tail    resd    1
        invincibility   resd    1
        last_x  resd    1
        last_y  resd    1

        ;STORE THE NUMBER OF FOOD EATEN AND RANDOM NUMBER GENERATOR
        ate             resd    1
        rand_n  resd    1

        ;STORE THE TIMER VALUE
        timer   resd    1

        ;STORE THE DIRECTION OF THE SNAKE HEAD
        direc   resd    1

segment .text

        global  asm_main
        global  raw_mode_on
        global  raw_mode_off
        global  init_board
        global  render

        ;USEFUL FUNCTIONS AND FEATURES
        extern  system
        extern  putchar
        extern  getchar
        extern  printf
        extern  fopen
        extern  fread
        extern  fgetc
        extern  fclose
        extern  usleep
        extern  fcntl

asm_main:
        enter   0,0
        pusha
        ;***************CODE STARTS HERE***************************

        RESTART:
        ;CLEAR THE SCREEN
        push    clear_screen_cmd
        call    system
        add             esp, 4

        ;PRINT SNAKE ART
        push    start_snake_art
        call    printf
        add             esp, 4

        ;PRINT THE TITLE
        push    title_str
        call    printf
        add             esp, 4

        ;PRINT CONTROLS
        push    help_str
        call    printf
        add             esp, 4

        ;PRESS ENTER KEY TO BEGIN
        start_screen:
        push    begin_str
        call    printf
        add             esp, 4
        call    getchar
        cmp             eax, RESTARTCHAR
        je              start_next
        start_next:


        mov             ebx, 0
        begin_load:
        cmp             ebx, 3
        jge             end_of_load

                ;CLEAR THE SCREEN
                push    clear_screen_cmd
                call    system
                add             esp, 4

                ;PRINT THE TITLE
                push    title_str
                call    printf
                add             esp, 4

                ;PRINT CONTROLS
                push    help_str
                call    printf
                add             esp, 4

                ;PRINT RANDOM LOADING TIP
                RANDOMIZER_TIPS:
                rdtsc
                mov     edx, 0
                mov             edx, eax
                mov             eax, 0
                mov             al, dl
                cmp             eax, 6
                jge             RANDOMIZER_TIPS
                cmp             eax, 0
                jle             RANDOMIZER_TIPS
                        cmp             eax, 1
                        jne             next1
                                push    loading_tip1
                                call    printf
                                add             esp, 4
                                jmp             no_tips_left
                        next1:
                        cmp             eax, 2
                        jne             next2
                                push    loading_tip2
                                call    printf
                                add             esp, 4
                                jmp             no_tips_left
                        next2:
                        cmp             eax, 3
                        jne             next3
                                push    loading_tip3
                                call    printf
                                add             esp, 4
                                jmp             no_tips_left
                        next3:
                        cmp             eax, 4
                        jne             next4
                                push    loading_tip4
                                call    printf
                                add             esp, 4
                                jmp             no_tips_left
                        next4:
                        push    loading_tip5
                        call    printf
                        add             esp, 4
                no_tips_left:

                cmp             ebx, 0
                jne             next_color
                        ;PRINT LOADING SYMBOL
                        push    load_scr
                        call    printf
                        add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                        jmp             end_color
                next_color:
                cmp             ebx, 1
                jne             next_color2
                        ;PRINT LOADING SYMBOL
                        push    load_scr2
                        call    printf
                        add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                        jmp             end_color
                next_color2:
                        ;PRINT LOADING SYMBOL
                        push    load_scr3
                        call    printf
                        add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                                push    LOADWAIT
                                call    usleep
                                add             esp, 4
                end_color:

        inc             ebx
        jmp             begin_load
        end_of_load:

        ;ENABLE RAW
        call    raw_mode_on

        ;INITIALIZE BOARD TO BEGIN
        call    init_board

        ;SET GAME PIECES
        mov             DWORD [xpos], STARTX
        mov             DWORD [ypos], STARTY
        mov             DWORD [xfood], FOODX
        mov             DWORD [yfood], FOODY
        mov             DWORD [tail], 0
        mov             DWORD [invincibility], 0
        mov             DWORD [last_x], 0
        mov             DWORD [last_y], 0

        ;SET GAME STATISTICS
        mov             DWORD [ate], TOTALFOOD
        mov             DWORD [length], 0
        mov             DWORD [timer], STARTTIME
        mov             DWORD [direc], 2

                mov             ecx, 149
                initialize:
                cmp             ecx, 1
                jle             end_initialize
                        mov             DWORD [xtail + ecx * 4], 0
                        mov             DWORD [ytail + ecx * 4], 0
                dec             ecx
                jmp             initialize
                end_initialize:

        ;MAIN GAME LOOP
        game_loop:

                ;DECREMENT TIMER AND QUIT ON OVERTIME
                dec             DWORD [timer]
                cmp             DWORD [invincibility], 1
                je              invince_one
                        cmp             DWORD [timer], 0
                        jle             game_loop_end
                invince_one:

                ;WIN SCREEN
                cmp             DWORD [length], 150
                jge             win_screen

                ;DRAW THE GAME BOARD
                call    render

                ;KEEP THE SCREEN FLICKERING
                push    TICK
                call    usleep
                add             esp, 4

                ;GET ACTION FROM USER
                call    nonblocking_getchar

                ;STORE CURRENT HEAD POSITION
                mov             esi, [xpos]
                mov             edi, [ypos]

                ;ADJUST COURSE TO USER INPUT
                move_snek:
                cmp             eax, EXITCHAR
                je              game_loop_end
                cmp             eax, UPCHAR
                je              move_up
                cmp             eax, LEFTCHAR
                je              move_left
                cmp             eax, DOWNCHAR
                je              move_down
                cmp             eax, RIGHTCHAR
                je              move_right
                ;RESTART THE GAME
                cmp             eax, RESTARTCHAR
                je              RESTART
                ;RESTART THE GAME
                cmp             eax, PAUSE_CHAR
                je              game_pause
                ;CHEAT CODE TO AUTO WIN
                cmp             eax, AUTO_WIN
                je              win_screen
                ;CHEAT CODE FOR INVINCIBILITY
                cmp             eax, INVIN_CHAR
                jne             no_invince
                        mov             DWORD [invincibility], 1
                no_invince:

                ;IF NO USER INPUT KEEP SNAKE GOING IN LAST DIRECTION
                mov             eax, DWORD [direc]
                cmp             eax, 1
                je              move_up
                cmp             eax, 2
                je              move_right
                cmp             eax, 3
                je              move_down
                cmp             eax, 4
                je              move_left

                ;CATCHALL IN CASE PROGRAMMING DOESNT WORK GOOD
                jmp             input_end
                game_pause:
                        mov             eax, 0
                        call    getchar
                        cmp             eax, PAUSE_CHAR
                        je              game_loop
                jmp             game_pause


                ;MOVE SNAKE HEAD ACCORDING TO INPUT AND SET DIRECTION FLAG
                move_up:
                        cmp             DWORD [direc], 3
                        je              input_end
                        mov             DWORD [direc], 1
                        dec             DWORD [ypos]
                        jmp             input_end
                move_left:
                        cmp             DWORD [direc], 2
                        je              input_end
                        mov             DWORD [direc], 4
                        dec             DWORD [xpos]
                        jmp             input_end
                move_down:
                        cmp             DWORD [direc], 1
                        je              input_end
                        mov             DWORD [direc], 3
                        inc             DWORD [ypos]
                        jmp             input_end
                move_right:
                        cmp             DWORD [direc], 4
                        je              input_end
                        mov             DWORD [direc], 2
                        inc             DWORD [xpos]
                input_end:

                ;CHECK IF THERE IS TAIL TO MOVE WITH HEAD
                cmp             DWORD [tail], 1
                jne             no_tail1

                        ;MOVE ALL TAIL PIECES TO THE NEXT INDEX OVER
                        mov             ecx, DWORD [length]
                        start_x:
                        cmp             ecx, 1
                        jle             end_x

                                mov             ebx, DWORD [xtail + ecx * 4 - 4]
                                mov             DWORD [xtail + ecx * 4], ebx

                                mov             ebx, DWORD [ytail + ecx * 4 - 4]
                                mov             DWORD [ytail + ecx * 4], ebx

                        dec             ecx
                        jmp             start_x
                        end_x:

                        ;SET LAST HEAD POSITION AS NEW TAIL POSITION
                        mov             eax, DWORD [last_x]
                        mov             DWORD [xtail + 4], eax
                        mov             eax, DWORD [last_y]
                        mov             DWORD [ytail + 4], eax

                no_tail1:

                ;COMPARE HEAD TO WALL CHARACTER
                mov             eax, WIDTH
                mul             DWORD [ypos]
                add             eax, [xpos]
                lea             eax, [board + eax]
                cmp             BYTE [eax], WALL_CHAR
                jne             valid_move
                        cmp             DWORD [invincibility], 1
                        je              not_today
                                jmp             game_loop_end
                        not_today:
                                mov             DWORD [xpos], esi
                                mov             DWORD [ypos], edi
                valid_move:

                ;CHECK INVINCIBLE
                cmp             DWORD [invincibility], 1
                je              end_x8

                ;COMPARE HEAD TO TAIL CHARACTER
                mov             ecx, DWORD [length]
                start_x8:
                cmp             ecx, 1
                jle             end_x8
                        mov             ebx, DWORD [xpos]
                        cmp             DWORD [xtail + ecx * 4], ebx
                        jne             not_yet
                        mov             ebx, DWORD [ypos]
                        cmp             DWORD [ytail + ecx * 4], ebx
                        jne             not_yet
                                jmp             game_loop_end
                        not_yet:
                dec             ecx
                jmp             start_x8
                end_x8:

                ;COMPARE HEAD TO FOOD CHARACTER
                mov             eax, DWORD [xfood]
                cmp             eax, DWORD [xpos]
                jne             dont_eat
                mov             ebx, DWORD [yfood]
                cmp             ebx, DWORD [ypos]
                jne             dont_eat
                        mov             DWORD [tail], 1
                        inc             DWORD [ate]
                        inc             DWORD [length]
                        add             DWORD [timer], 45

                        ;UPON EATING RANDOMIZE FOOD X POSITION
                        RANDOMIZER_ONE:
                        rdtsc
                        mov     edx, 0
                        mov             edx, eax
                        mov             eax, 0
                        mov             al, dl
                        cmp             eax, 79
                        jge             RANDOMIZER_ONE
                        cmp             eax, 1
                        jle             RANDOMIZER_ONE
                                mov     DWORD [xfood], eax

                        ;UPON EATING RANDOMIZE FOOD Y POSITION
                        RANDOMIZER_TWO:
                        rdtsc
                        mov     edx, 0
                        mov             edx, eax
                        mov             eax, 0
                        mov             al, dl
                        cmp             eax, 39
                        jge             RANDOMIZER_TWO
                        cmp             eax, 1
                        jle             RANDOMIZER_TWO
                                mov             DWORD [yfood], eax
                dont_eat:

                ;STORE CURRENT HEAD POSITION
                mov             esi, [xpos]
                mov             edi, [ypos]
                mov             DWORD [last_x], esi
                mov             DWORD [last_y], edi

        jmp             game_loop
        game_loop_end:

        jmp             lose_screen
        win_screen:

                ;CLEAR THE SCREEN
                push    clear_screen_cmd
                call    system
                add             esp, 4

                ;PRINT SNAKE ART
                push    snake_art
                call    printf
                add             esp, 4

                ;PRINT GAME OVER
                push    you_win
                call    printf
                add     esp, 4
                push    win_over
                call    printf
                add     esp, 4

                ;PRINT HIGH SCORE
                push    DWORD [length]
                push    win_high_score
                call    printf
                add     esp, 8

                ;PRINT GAME CREDITS
                push    win_credits_str
                call    printf
                add     esp, 4

                ;PLAY AGAIN
                push    play_again
                call    printf
                add     esp, 4
                call    getchar
                cmp             eax, 'y'
                je              RESTART

        jmp             GAME_END
        lose_screen:

        ;CLEAR THE SCREEN
        push    clear_screen_cmd
        call    system
        add             esp, 4

        ;PRINT SNAKE ART
        push    snake_art
        call    printf
        add             esp, 4

        ;PRINT GAME OVER
        push    game_over
        call    printf
        add     esp, 4

        ;PRINT HIGH SCORE
        push    DWORD [length]
        push    high_score
        call    printf
        add     esp, 8

        ;PRINT GAME CREDITS
        push    credits_str
        call    printf
        add     esp, 4

        ;PLAY AGAIN
        push    play_again
        call    printf
        add     esp, 4

        play_again_loop:
        call    getchar
        cmp             eax, 'y'
        je              RESTART
        cmp             eax, 'n'
        je              GAME_END
        jmp             play_again_loop

        GAME_END:

        ;RESTORE OLD TERMINAL FUNCTIONALITY
        call raw_mode_off

        ;***************CODE ENDS HERE*****************************
        popa
        mov             eax, 0
        leave
        ret

; === FUNCTION ===
raw_mode_on:

        push    ebp
        mov             ebp, esp

        push    raw_mode_on_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
raw_mode_off:

        push    ebp
        mov             ebp, esp

        push    raw_mode_off_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
init_board:

        push    ebp
        mov             ebp, esp

        ;FILE OPEN AND COUNTER
        sub             esp, 8

        ;OPEN THE FILE
        push    mode_r
        push    board_file
        call    fopen
        add             esp, 8
        mov             DWORD [ebp-4], eax

        ;PRINT THE BOARD LINE BY LINE
        mov             DWORD [ebp-8], 0
        read_loop:
        cmp             DWORD [ebp-8], HEIGHT
        je              read_loop_end

                ;FIND THE OFFSET
                mov             eax, WIDTH
                mul             DWORD [ebp-8]
                lea             ebx, [board + eax]

                ;READ BYTES INTO THE BUFFER
                push    DWORD [ebp-4]
                push    WIDTH
                push    1
                push    ebx
                call    fread
                add             esp, 16

                ;SLURP THE NEW LINE
                push    DWORD [ebp-4]
                call    fgetc
                add             esp, 4

        inc             DWORD [ebp-8]
        jmp             read_loop
        read_loop_end:

        ;CLOSE THE FILE
        push    DWORD [ebp-4]
        call    fclose
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
render:

        push    ebp
        mov             ebp, esp
        sub             esp, 8

        ;CLEAR THE SCREEN
        push    clear_screen_cmd
        call    system
        add             esp, 4

        ;PRINT THE TITLE
        push    title_str
        call    printf
        add             esp, 4

        ;PRINT CONTROLS
        push    help_str
        call    printf
        add             esp, 4

        ;PRINT FOOD EATEN
        push    DWORD [ate]
        push    score_tracker
        call    printf
        add             esp, 8

        ;PRINT PLAYER SIZE
        cmp             DWORD [length], 1
        jge             next_size
                push    size_1
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size:
        cmp             DWORD [length], 3
        jge             next_size2
                push    size_2
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size2:
        cmp             DWORD [length], 5
        jge             next_size3
                push    size_3
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size3:
        cmp             DWORD [length], 8
        jge             next_size4
                push    size_4
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size4:
        cmp             DWORD [length], 13
        jge             next_size5
                push    size_5
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size5:
        cmp             DWORD [length], 21
        jge             next_size6
                push    size_6
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size6:
        cmp             DWORD [length], 34
        jge             next_size7
                push    size_7
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size7:
        cmp             DWORD [length], 55
        jge             next_size8
                push    size_8
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size8:
        cmp             DWORD [length], 89
        jge             next_size9
                push    size_9
                call    printf
                add             esp, 4
                jmp             render_continue
        next_size9:
                push    size_10
                call    printf
                add             esp, 4
        render_continue:

        ;PRINT TIMER INFORMATION
        push    DWORD [timer]
        push    timer_str
        call    printf
        add             esp, 8

        ;OUTSIDE LOOP BY HEIGHT
        mov             DWORD [ebp-4], 0
        y_loop_start:
        cmp             DWORD [ebp-4], HEIGHT
        je              y_loop_end

                ;INSIDE LOOP BY WIDTH
                mov             DWORD [ebp-8], 0
                x_loop_start:
                cmp             DWORD [ebp-8], WIDTH
                je              x_loop_end

                        ;PRINT THE PLAYER, FOOD, TAIL, OR SPACE
                        mov             eax, [xpos]
                        cmp             eax, DWORD [ebp-8]
                        jne             no_player
                        mov             eax, [ypos]
                        cmp             eax, DWORD [ebp-4]
                        jne             no_player
                                push    PLAYER_CHAR
                                jmp             print_end
                        no_player:

                        mov             ebx, 1
                        tail_loop:
                        cmp             ebx, WIDTH
                        jge             tail_loop_end

                                ;PRINT THE FOOD, TAIL, OR SPACE
                                mov             eax, [xtail + ebx * 4]
                                cmp             eax, DWORD [ebp-8]
                                jne             no_tail
                                mov             eax, [ytail + ebx * 4]
                                cmp             eax, DWORD [ebp-4]
                                jne             no_tail
                                        push    TAIL_CHAR
                                        jmp             print_end
                                no_tail:

                        inc             ebx
                        jmp             tail_loop
                        tail_loop_end:

                        ;PRINT THE FOOD OR SPACE
                        mov             eax, [xfood]
                        cmp             eax, DWORD [ebp-8]
                        jne             print_board
                        mov             eax, [yfood]
                        cmp             eax, DWORD [ebp-4]
                        jne             print_board
                                push    FOOD_CHAR
                                jmp             print_end
                        ;PRINT THE SPACE
                        print_board:
                                mov             eax, [ebp-4]
                                mov             ebx, WIDTH
                                mul             ebx
                                add             eax, [ebp-8]
                                mov             ebx, 0
                                mov             bl, BYTE [board + eax]
                                push    ebx
                        print_end:
                        call    putchar
                        add             esp, 4


                inc             DWORD [ebp-8]
                jmp             x_loop_start
                x_loop_end:

                ;WRITE THE CARRIAGE RETURN
                push    0x0d
                call    putchar
                add             esp, 4

                ;WRITE THE NEW LINE
                push    0x0a
                call    putchar
                add             esp, 4

        inc             DWORD [ebp-4]
        jmp             y_loop_start
        y_loop_end:

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
nonblocking_getchar:

        ;RETURNS -1 ON NO VALUE AND CHAR ON VALUE
        %define F_GETFL 3
        %define F_SETFL 4
        %define O_NONBLOCK 2048
        %define STDIN 0

        push ebp
        mov ebp, esp

        ;FLAG HOLDER
        sub esp, 8

        ;GET CURRENT FLAGS
        push 0
        push F_GETFL
        push STDIN
        call fcntl
        add esp, 12
        mov DWORD [ebp-4], eax

        ;SET NONBLOCKING MODE
        or DWORD [ebp-4], O_NONBLOCK
        push DWORD [ebp-4]
        push F_SETFL
        push STDIN
        call fcntl
        add esp, 12

        call getchar
        mov DWORD [ebp-8], eax

        ;RESTORE BLOCKING MODE
        xor DWORD [ebp-4], O_NONBLOCK
        push DWORD [ebp-4]
        push F_SETFL
        push STDIN
        call fcntl
        add esp, 12

        mov eax, DWORD [ebp-8]

        mov esp, ebp
        pop ebp
        ret

;END OF CODE

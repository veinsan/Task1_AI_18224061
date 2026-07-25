:- include('facts.pl').
:- include('state.pl').
:- include('commands.pl').
:- include('file_io.pl').

play :-
    start,
    nl,
    game_loop.

% Main loop permainan pakai pola repeat/fail (menunjukkan konsep Loop)
game_loop :-
    repeat,
    turn_cycle,
    game_state(ended),
    !.

turn_cycle :-
    game_state(ended), !.
turn_cycle :-
    write('Command: '),
    read(Perintah),
    nl,
    proses(Perintah),
    nl.

proses(help) :- !, help.
proses(status) :- !, status.
proses(look) :- !, look.
proses(inventory) :- !, inventory.
proses(move(X)) :- !, ( move(X) -> true ; true ).
proses(take(X)) :- !, ( take(X) -> true ; true ).
proses(attack) :- !, ( attack -> true ; true ).
proses(bench) :- !, ( bench -> true ; true ).
proses(saveGame(F)) :- !, ( saveGame(F) -> true ; true ).
proses(quit) :- !, quit.
proses(_) :-
    write('Command tidak dikenali. Ketik help. untuk melihat daftar command.'), nl.
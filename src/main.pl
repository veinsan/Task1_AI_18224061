% ================================================================
% main.pl
% Entry point dan loop utama permainan.
% Jalankan dari folder src dengan:
%   gprolog --consult-file main.pl
% Kemudian ketik:
%   | ?- play.
% ================================================================

:- include('facts.pl').
:- include('state.pl').
:- include('commands.pl').
:- include('file_io.pl').

% Memulai permainan baru lalu masuk ke loop command.
play :-
    start,
    nl,
    gameLoop.

% Loop utama menggunakan repeat dan cut. Setiap turn_cycle/0 selalu
% diselesaikan, kemudian loop berhenti ketika game_state(ended) tercapai.
gameLoop :-
    repeat,
    turn_cycle,
    game_state(ended), !.

turn_cycle :-
    game_state(ended), !.
turn_cycle :-
    write('Command: '),
    read(Command),
    nl,
    process_command(Command),
    nl.

% Dispatch command. Cut memastikan hanya satu handler yang dijalankan.
process_command(end_of_file) :- !, quit.
process_command(start) :- !, start.
process_command(help) :- !, help.
process_command(status) :- !, ignore_failure(status).
process_command(look) :- !, ignore_failure(look).
process_command(inventory) :- !, ignore_failure(inventory).
process_command(move(Target)) :- !, ignore_failure(move(Target)).
process_command(take(Item)) :- !, ignore_failure(take(Item)).
process_command(attack) :- !, ignore_failure(attack).
process_command(bench) :- !, ignore_failure(bench).
process_command(saveGame(Filename)) :- !, ignore_failure(saveGame(Filename)).
process_command(loadGame(Filename)) :- !, ignore_failure(loadGame(Filename)).
process_command(quit) :- !, quit.
process_command(play) :- !,
    write('Permainan sudah berjalan. Gunakan start. untuk memulai ulang.'), nl.
process_command(_) :-
    write('Command tidak dikenali. Ketik help. untuk melihat daftar command.'), nl.

% Command yang gagal tetap dikonsumsi oleh loop agar pemain dapat memasukkan
% command berikutnya. Fail tetap terjadi di predicate command aslinya.
ignore_failure(Goal) :-
    ( call(Goal) -> true ; true ).

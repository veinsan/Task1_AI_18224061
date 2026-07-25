% ================================================================
% state.pl
% Dynamic predicate dan pengelolaan kondisi permainan.
% ================================================================

:- dynamic(player_position/1).
:- dynamic(player_mask/1).
:- dynamic(inventory/1).
:- dynamic(game_state/1).
:- dynamic(game_result/1).
:- dynamic(turn_left/1).
:- dynamic(bench_used/1).
:- dynamic(item_in_area/2).
:- dynamic(enemy_in_area/2).
:- dynamic(current_enemy/1).
:- dynamic(enemy_hp/2).

% Menghapus seluruh state runtime agar start/load selalu menghasilkan
% tepat satu fakta untuk setiap state tunggal.
clear_runtime_state :-
    retractall(player_position(_)),
    retractall(player_mask(_)),
    retractall(inventory(_)),
    retractall(game_state(_)),
    retractall(game_result(_)),
    retractall(turn_left(_)),
    retractall(bench_used(_)),
    retractall(item_in_area(_, _)),
    retractall(enemy_in_area(_, _)),
    retractall(current_enemy(_)),
    retractall(enemy_hp(_, _)).

% Memulai atau mengulang permainan dari awal.
start :-
    clear_runtime_state,
    start_area(Area),
    max_mask(MaxMask),
    initial_turns(Turns),
    assertz(player_position(Area)),
    assertz(player_mask(MaxMask)),
    assertz(inventory([])),
    assertz(game_state(exploration)),
    assertz(game_result(none)),
    assertz(turn_left(Turns)),
    assertz(bench_used(false)),
    init_items,
    init_enemies,
    area_display_name(Area, AreaName),
    nl,
    format('Vessel terbangun di ~w.~n', [AreaName]),
    format('Mask: ~w/~w~n', [MaxMask, MaxMask]),
    format('Giliran tersisa: ~w~n', [Turns]),
    write('Fase permainan: exploration'), nl.

% Fail-driven loop untuk menyalin fakta template menjadi state dinamis.
% Predicate pertama terus gagal agar Prolog melakukan backtracking dan
% mengambil seluruh solusi. Clause kedua menghentikan loop dengan sukses.
init_items :-
    initial_item_in_area(Area, Item),
    assertz(item_in_area(Area, Item)),
    fail.
init_items.

init_enemies :-
    initial_enemy_in_area(Area, Enemy),
    assertz(enemy_in_area(Area, Enemy)),
    fail.
init_enemies.

% Mengurangi giliran sebanyak satu dan mencegah nilainya menjadi negatif.
decrease_turn :-
    turn_left(Current),
    Raw is Current - 1,
    ( Raw < 0 -> NewTurn = 0 ; NewTurn = Raw ),
    retractall(turn_left(_)),
    assertz(turn_left(NewTurn)).

print_turn_left :-
    turn_left(Turns),
    format('Giliran tersisa: ~w~n', [Turns]).

% Pemeriksaan tiga fragmen menggunakan list dan rekurens.
has_all_fragments :-
    required_fragments(Required),
    inventory(Owned),
    contains_all_fragments(Required, Owned).

contains_all_fragments([], _).
contains_all_fragments([Fragment|Remaining], Owned) :-
    member(Fragment, Owned),
    contains_all_fragments(Remaining, Owned).

% Mengakhiri permainan karena giliran habis.
check_turns_after_action :-
    turn_left(Turns),
    Turns =< 0,
    \+ game_state(ended), !,
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(lose)),
    retractall(current_enemy(_)),
    retractall(enemy_hp(_, _)),
    nl,
    write('Giliran telah habis. Vessel tidak berhasil keluar dari Hallownest tepat waktu.'), nl,
    write('Permainan berakhir dengan kekalahan.'), nl.
check_turns_after_action.

% Mengakhiri permainan karena Mask pemain habis.
check_mask_after_action :-
    player_mask(Mask),
    Mask =< 0,
    \+ game_state(ended), !,
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(lose)),
    retractall(current_enemy(_)),
    retractall(enemy_hp(_, _)),
    nl,
    write('Mask Vessel telah habis.'), nl,
    write('Permainan berakhir dengan kekalahan.'), nl.
check_mask_after_action.

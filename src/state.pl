% Dynamic predicate dan inisialisasi kondisi permainan

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

start :-
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
    retractall(enemy_hp(_, _)),
    start_area(Area),
    assertz(player_position(Area)),
    max_mask(MaxMask),
    assertz(player_mask(MaxMask)),
    assertz(inventory([])),
    assertz(game_state(exploration)),
    assertz(game_result(none)),
    initial_turns(Turns),
    assertz(turn_left(Turns)),
    assertz(bench_used(false)),
    init_items,
    init_enemies,
    area_display_name(Area, AreaName),
    nl,
    format("Vessel terbangun di ~w.~n", [AreaName]),
    format("Mask: ~w/~w~n", [MaxMask, MaxMask]),
    format("Giliran tersisa: ~w~n", [Turns]),
    write('Fase permainan: exploration'), nl.

% Loop assert menggunakan pola fail-driven, menyalin template statis
% menjadi fakta dinamis (menunjukkan konsep Fail sekaligus Loop).
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

decrease_turn :-
    turn_left(T),
    NewT is T - 1,
    retractall(turn_left(_)),
    assertz(turn_left(NewT)).

print_turn_left :-
    turn_left(T),
    format("Giliran tersisa: ~w~n", [T]).

has_all_fragments :-
    inventory(Daftar),
    forall(required_fragment(F), member(F, Daftar)).

check_turns_after_action :-
    turn_left(T),
    T =< 0,
    game_state(State),
    State \= ended, !,
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(lose)),
    nl,
    write('Giliran telah habis. Vessel tidak berhasil keluar dari Hallownest tepat waktu.'), nl,
    write('Permainan berakhir dengan kekalahan.'), nl.
check_turns_after_action.

check_mask_after_action :-
    player_mask(Mask),
    Mask =< 0,
    game_state(State),
    State \= ended, !,
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(lose)),
    nl,
    write('Mask Vessel telah habis.'), nl,
    write('Permainan berakhir dengan kekalahan.'), nl.
check_mask_after_action.
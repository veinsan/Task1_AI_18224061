% File processing : saveGame/1 dan loadGame/1

saveGame(_) :-
    \+ game_state(exploration), !,
    write('Permainan hanya dapat disimpan selama fase eksplorasi.'), nl,
    fail.
saveGame(Filename) :-
    player_position(Area),
    player_mask(Mask),
    inventory(Daftar),
    turn_left(Turns),
    game_state(State),
    bench_used(BenchUsed),
    findall(A-I, item_in_area(A, I), DaftarItemArea),
    findall(A-E, enemy_in_area(A, E), DaftarEnemyArea),
    Data = game_data(Area, Mask, Daftar, Turns, State, BenchUsed, DaftarItemArea, DaftarEnemyArea),
    open(Filename, write, Stream),
    writeq(Stream, Data),
    write(Stream, '.'),
    nl(Stream),
    close(Stream),
    format("Kondisi permainan berhasil disimpan ke dalam file ~w.~n", [Filename]).

loadGame(Filename) :-
    catch(open(Filename, read, Stream), _, fail), !,
    read(Stream, Data),
    close(Stream),
    apply_loaded_data(Data),
    format("Kondisi permainan berhasil dimuat dari ~w.~n", [Filename]),
    player_position(Area),
    area_display_name(Area, NamaArea),
    player_mask(Mask),
    max_mask(MaxMask),
    turn_left(Turns),
    game_state(State),
    inventory(Daftar),
    format("Area: ~w~n", [NamaArea]),
    format("Mask: ~w/~w~n", [Mask, MaxMask]),
    format("Giliran tersisa: ~w~n", [Turns]),
    format("Fase permainan: ~w~n", [State]),
    format("Fragmen segel:~n~w~n", [Daftar]).
loadGame(_) :-
    write('Berkas penyimpanan tidak ditemukan atau tidak valid.'), nl,
    fail.

apply_loaded_data(game_data(Area, Mask, Daftar, Turns, State, BenchUsed, DaftarItemArea, DaftarEnemyArea)) :-
    retractall(player_position(_)),
    retractall(player_mask(_)),
    retractall(inventory(_)),
    retractall(turn_left(_)),
    retractall(game_state(_)),
    retractall(bench_used(_)),
    retractall(item_in_area(_, _)),
    retractall(enemy_in_area(_, _)),
    retractall(current_enemy(_)),
    retractall(enemy_hp(_, _)),
    assertz(player_position(Area)),
    assertz(player_mask(Mask)),
    assertz(inventory(Daftar)),
    assertz(turn_left(Turns)),
    assertz(game_state(State)),
    assertz(bench_used(BenchUsed)),
    assert_item_area_list(DaftarItemArea),
    assert_enemy_area_list(DaftarEnemyArea).

assert_item_area_list([]).
assert_item_area_list([Area-Item|Sisa]) :-
    assertz(item_in_area(Area, Item)),
    assert_item_area_list(Sisa).

assert_enemy_area_list([]).
assert_enemy_area_list([Area-Enemy|Sisa]) :-
    assertz(enemy_in_area(Area, Enemy)),
    assert_enemy_area_list(Sisa).
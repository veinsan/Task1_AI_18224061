% ================================================================
% file_io.pl
% File processing untuk saveGame/1 dan loadGame/1.
% ================================================================

% Save hanya diizinkan pada fase exploration.
saveGame(_) :-
    \+ game_state(exploration), !,
    write('Permainan hanya dapat disimpan selama fase eksplorasi.'), nl,
    fail.
saveGame(Filename) :-
    build_game_data(Data),
    catch(write_save_file(Filename, Data), _, fail), !,
    format('Kondisi permainan berhasil disimpan ke dalam file ~w.~n', [Filename]).
saveGame(_) :-
    write('Kondisi permainan gagal disimpan. Periksa nama atau lokasi file.'), nl,
    fail.

build_game_data(Data) :-
    player_position(Area),
    player_mask(Mask),
    inventory(Items),
    turn_left(Turns),
    game_state(State),
    game_result(Result),
    bench_used(BenchUsed),
    findall(A-I, item_in_area(A, I), ItemsInAreas),
    findall(A-E, enemy_in_area(A, E), EnemiesInAreas),
    Data = game_data(
        v1,
        Area,
        Mask,
        Items,
        Turns,
        State,
        Result,
        BenchUsed,
        ItemsInAreas,
        EnemiesInAreas
    ).

write_save_file(Filename, Data) :-
    open(Filename, write, Stream),
    writeq(Stream, Data),
    write(Stream, '.'),
    nl(Stream),
    close(Stream).

% Load menerima hanya data dengan struktur dan nilai yang valid.
loadGame(Filename) :-
    catch(read_save_file(Filename, Data), _, fail),
    valid_game_data(Data), !,
    apply_loaded_data(Data),
    format('Kondisi permainan berhasil dimuat dari ~w.~n', [Filename]),
    show_loaded_summary.
loadGame(_) :-
    write('Berkas penyimpanan tidak ditemukan atau tidak valid.'), nl,
    fail.

read_save_file(Filename, Data) :-
    open(Filename, read, Stream),
    catch(
        read(Stream, Data),
        Error,
        (
            close(Stream),
            throw(Error)
        )
    ),
    close(Stream).

valid_game_data(game_data(
    v1,
    Area,
    Mask,
    Items,
    Turns,
    exploration,
    none,
    BenchUsed,
    ItemsInAreas,
    EnemiesInAreas
)) :-
    area(Area),
    integer(Mask),
    max_mask(MaxMask),
    Mask >= 0,
    Mask =< MaxMask,
    is_list(Items),
    valid_inventory_items(Items),
    integer(Turns),
    Turns > 0,
    valid_boolean(BenchUsed),
    is_list(ItemsInAreas),
    valid_item_area_pairs(ItemsInAreas),
    is_list(EnemiesInAreas),
    valid_enemy_area_pairs(EnemiesInAreas).

valid_boolean(true).
valid_boolean(false).

valid_inventory_items([]).
valid_inventory_items([Item|Remaining]) :-
    initial_item_in_area(_, Item),
    valid_inventory_items(Remaining).

valid_item_area_pairs([]).
valid_item_area_pairs([Area-Item|Remaining]) :-
    area(Area),
    initial_item_in_area(_, Item),
    valid_item_area_pairs(Remaining).

valid_enemy_area_pairs([]).
valid_enemy_area_pairs([Area-Enemy|Remaining]) :-
    area(Area),
    enemy_template(Enemy, _, _),
    valid_enemy_area_pairs(Remaining).

apply_loaded_data(game_data(
    v1,
    Area,
    Mask,
    Items,
    Turns,
    State,
    Result,
    BenchUsed,
    ItemsInAreas,
    EnemiesInAreas
)) :-
    clear_runtime_state,
    assertz(player_position(Area)),
    assertz(player_mask(Mask)),
    assertz(inventory(Items)),
    assertz(turn_left(Turns)),
    assertz(game_state(State)),
    assertz(game_result(Result)),
    assertz(bench_used(BenchUsed)),
    assert_item_area_list(ItemsInAreas),
    assert_enemy_area_list(EnemiesInAreas).

assert_item_area_list([]).
assert_item_area_list([Area-Item|Remaining]) :-
    assertz(item_in_area(Area, Item)),
    assert_item_area_list(Remaining).

assert_enemy_area_list([]).
assert_enemy_area_list([Area-Enemy|Remaining]) :-
    assertz(enemy_in_area(Area, Enemy)),
    assert_enemy_area_list(Remaining).

show_loaded_summary :-
    player_position(Area),
    player_mask(Mask),
    max_mask(MaxMask),
    turn_left(Turns),
    game_state(State),
    inventory(Items),
    format('Area: ~w~n', [Area]),
    format('Mask: ~w/~w~n', [Mask, MaxMask]),
    format('Giliran tersisa: ~w~n', [Turns]),
    format('Fase permainan: ~w~n', [State]),
    format('Fragmen segel:~n~w~n', [Items]).

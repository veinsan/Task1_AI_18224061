% ================================================================
% commands.pl
% Command informasi, eksplorasi, pertarungan, Bench, dan keluar.
% ================================================================

help :-
    nl,
    write('Daftar command yang tersedia:'), nl,
    write('start.                  memulai ulang permainan dari awal.'), nl,
    write('help.                   menampilkan daftar command ini.'), nl,
    write('status.                 menampilkan kondisi permainan saat ini.'), nl,
    write('look.                   menampilkan informasi area saat ini.'), nl,
    write('inventory.              menampilkan fragmen segel yang dimiliki.'), nl,
    write('move(Tujuan).           berpindah menuju area tujuan.'), nl,
    write('take(Item).             mengambil fragmen segel pada area saat ini.'), nl,
    write('attack.                 menyerang musuh selama fase pertarungan.'), nl,
    write('bench.                  menggunakan Bench untuk memulihkan Mask.'), nl,
    write('saveGame(NamaFile).     menyimpan kondisi permainan ke file.'), nl,
    write('loadGame(NamaFile).     memuat kondisi permainan dari file.'), nl,
    write('quit.                   mengakhiri sesi permainan.'), nl,
    nl.

% ----------------------------------------------------------------
% Command informasi
% ----------------------------------------------------------------

status :-
    \+ player_position(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
status :-
    player_position(Area),
    area_display_name(Area, AreaName),
    player_mask(Mask),
    max_mask(MaxMask),
    turn_left(Turns),
    game_state(State),
    game_result(Result),
    inventory(Items),
    length(Items, Count),
    nl,
    format('Area saat ini: ~w~n', [AreaName]),
    format('Mask: ~w/~w~n', [Mask, MaxMask]),
    format('Giliran tersisa: ~w~n', [Turns]),
    format('Fase permainan: ~w~n', [State]),
    format('Hasil permainan: ~w~n', [Result]),
    format('Fragmen segel yang dikumpulkan: ~w/3~n', [Count]),
    nl.

look :-
    \+ player_position(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
look :-
    player_position(Area),
    area_display_name(Area, AreaName),
    nl,
    format('Vessel berada di ~w.~n', [AreaName]),
    findall(Destination, connected(Area, Destination), Destinations),
    format('Area yang terhubung: ~w~n', [Destinations]),
    look_item(Area),
    look_enemy(Area),
    look_bench(Area),
    nl.

look_item(Area) :-
    item_in_area(Area, Item), !,
    format('Objek pada area ini: ~w~n', [Item]).
look_item(_) :-
    write('Tidak ada objek pada area ini.'), nl.

look_enemy(Area) :-
    enemy_in_area(Area, Enemy), !,
    enemy_display_name(Enemy, Name),
    format('Terdapat musuh pada area ini: ~w~n', [Name]).
look_enemy(_).

look_bench(Area) :-
    bench_area(Area), !,
    write('Terdapat Bench pada area ini.'), nl.
look_bench(_).

inventory :-
    \+ inventory(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
inventory :-
    inventory(Items),
    nl,
    write('Fragmen segel yang dimiliki:'), nl,
    print_inventory_contents(Items),
    nl.

print_inventory_contents([]) :-
    write('(belum ada fragmen yang dikumpulkan)'), nl.
print_inventory_contents([Fragment|Remaining]) :-
    item_display_name(Fragment, Name),
    format('- ~w~n', [Name]),
    print_remaining_fragments(Remaining).

% Base case ini tidak mencetak pesan kosong agar pesan tersebut hanya muncul
% saat inventory benar-benar kosong.
print_remaining_fragments([]).
print_remaining_fragments([Fragment|Remaining]) :-
    item_display_name(Fragment, Name),
    format('- ~w~n', [Name]),
    print_remaining_fragments(Remaining).

% ----------------------------------------------------------------
% move/1: perpindahan antararea menggunakan cut dan fail.
% ----------------------------------------------------------------

move(_) :-
    game_state(ended), !,
    write('Permainan telah berakhir. Jalankan start. untuk memulai permainan baru.'), nl,
    fail.
move(_) :-
    \+ player_position(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
move(_) :-
    game_state(battle), !,
    write('Tidak dapat berpindah area selama pertarungan berlangsung.'), nl,
    fail.
move(Target) :-
    player_position(Current),
    connected(Current, Target),
    exit_area(Target),
    \+ has_all_fragments, !,
    write('Perpindahan gagal.'), nl,
    write('Gerbang Black Egg Temple masih terkunci karena ketiga segel belum terkumpul.'), nl,
    write('Posisi dan giliran pemain tidak berubah.'), nl,
    fail.
move(Target) :-
    player_position(Current),
    connected(Current, Target),
    exit_area(Target),
    has_all_fragments, !,
    write('Ketiga segel telah terkumpul.'), nl,
    write('Gerbang Black Egg Temple berhasil dibuka.'), nl,
    retract(player_position(Current)),
    assertz(player_position(Target)),
    decrease_turn,
    area_display_name(Target, TargetName),
    format('Vessel berpindah ke ~w.~n', [TargetName]),
    start_battle(Target),
    print_turn_left,
    check_turns_after_action.
move(Target) :-
    player_position(Current),
    connected(Current, Target), !,
    retract(player_position(Current)),
    assertz(player_position(Target)),
    decrease_turn,
    area_display_name(Target, TargetName),
    format('Vessel berpindah ke ~w.~n', [TargetName]),
    handle_normal_arrival(Target),
    print_turn_left,
    check_turns_after_action.
move(Target) :-
    player_position(Current),
    display_area_name(Target, TargetName),
    display_area_name(Current, CurrentName),
    write('Perpindahan gagal.'), nl,
    format('~w tidak terhubung langsung dengan ~w.~n', [TargetName, CurrentName]),
    write('Posisi dan giliran pemain tidak berubah.'), nl,
    fail.

display_area_name(Area, Name) :-
    area_display_name(Area, Name), !.
display_area_name(Area, Area).

handle_normal_arrival(Area) :-
    enemy_in_area(Area, _), !,
    start_battle(Area).
handle_normal_arrival(_).

start_battle(Area) :-
    enemy_in_area(Area, Enemy),
    enemy_template(Enemy, HP, _),
    retractall(current_enemy(_)),
    assertz(current_enemy(Enemy)),
    retractall(enemy_hp(_, _)),
    assertz(enemy_hp(Enemy, HP)),
    retractall(game_state(_)),
    assertz(game_state(battle)),
    enemy_display_name(Enemy, Name),
    ( exit_area(Area) ->
        format('~w bangkit dan menghalangi jalan.~n', [Name]),
        write('Fase pertarungan terakhir dimulai.'), nl
    ;
        format('Seekor ~w menghalangi perjalanan.~n', [Name]),
        write('Fase pertarungan dimulai.'), nl
    ).

% ----------------------------------------------------------------
% take/1: mengambil fragmen dan menyimpannya dalam list inventory.
% ----------------------------------------------------------------

take(_) :-
    game_state(ended), !,
    write('Permainan telah berakhir. Fragmen tidak dapat diambil.'), nl,
    fail.
take(_) :-
    \+ player_position(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
take(_) :-
    \+ game_state(exploration), !,
    write('Pengambilan fragmen hanya dapat dilakukan selama fase eksplorasi.'), nl,
    fail.
take(Item) :-
    player_position(Area),
    item_in_area(Area, Item), !,
    retract(item_in_area(Area, Item)),
    inventory(OldItems),
    append(OldItems, [Item], NewItems),
    retract(inventory(OldItems)),
    assertz(inventory(NewItems)),
    item_display_name(Item, Name),
    format('Vessel mengambil ~w.~n', [Name]),
    format('Fragmen segel yang dimiliki: ~w~n', [NewItems]).
take(_) :-
    write('Tidak ada fragmen tersebut pada area ini.'), nl,
    fail.

% ----------------------------------------------------------------
% attack/0: pertarungan satu lawan satu.
% ----------------------------------------------------------------

attack :-
    game_state(ended), !,
    write('Permainan telah berakhir. Serangan tidak dapat dilakukan.'), nl,
    fail.
attack :-
    \+ game_state(battle), !,
    write('Serangan hanya dapat dilakukan selama fase pertarungan.'), nl,
    fail.
attack :-
    current_enemy(Enemy),
    enemy_hp(Enemy, CurrentHP),
    player_damage(Damage),
    RemainingHP is CurrentHP - Damage,
    enemy_display_name(Enemy, Name),
    format('Vessel menyerang ~w menggunakan Nail.~n', [Name]),
    format('Damage yang dihasilkan: ~w.~n', [Damage]),
    resolve_attack(Enemy, Name, RemainingHP).

resolve_attack(Enemy, Name, RemainingHP) :-
    RemainingHP =< 0, !,
    retractall(enemy_hp(_, _)),
    retractall(current_enemy(_)),
    player_position(Area),
    retractall(enemy_in_area(Area, Enemy)),
    format('~w berhasil dikalahkan.~n', [Name]),
    decrease_turn,
    finish_battle(Area).
resolve_attack(Enemy, Name, RemainingHP) :-
    enemy_template(Enemy, MaxHP, EnemyDamage),
    retractall(enemy_hp(_, _)),
    assertz(enemy_hp(Enemy, RemainingHP)),
    format('Mask ~w tersisa: ~w/~w.~n', [Name, RemainingHP, MaxHP]),
    nl,
    player_mask(CurrentMask),
    RawMask is CurrentMask - EnemyDamage,
    ( RawMask < 0 -> NewMask = 0 ; NewMask = RawMask ),
    retractall(player_mask(_)),
    assertz(player_mask(NewMask)),
    format('~w membalas menyerang.~n', [Name]),
    max_mask(MaxMask),
    format('Mask Vessel tersisa: ~w/~w.~n', [NewMask, MaxMask]),
    decrease_turn,
    print_turn_left,
    check_mask_after_action,
    check_turns_after_action.

% Mengalahkan boss pada giliran terakhir tetap dianggap menang karena boss
% telah dikalahkan sebelum pemeriksaan kondisi kalah dilakukan.
finish_battle(Area) :-
    exit_area(Area), !,
    print_turn_left,
    nl,
    write('Gerbang terakhir terbuka.'), nl,
    write('Vessel berhasil keluar dari reruntuhan Hallownest.'), nl,
    write('Permainan berakhir dengan kemenangan.'), nl,
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(win)).
finish_battle(_) :-
    retractall(game_state(_)),
    assertz(game_state(exploration)),
    write('Fase permainan kembali ke exploration.'), nl,
    print_turn_left,
    check_turns_after_action.

% ----------------------------------------------------------------
% bench/0: pemulihan satu kali pada area tertentu.
% ----------------------------------------------------------------

bench :-
    game_state(ended), !,
    write('Permainan telah berakhir. Bench tidak dapat digunakan.'), nl,
    fail.
bench :-
    \+ player_position(_), !,
    write('Permainan belum dimulai. Jalankan play. atau start.'), nl,
    fail.
bench :-
    \+ game_state(exploration), !,
    write('Bench hanya dapat digunakan selama fase eksplorasi.'), nl,
    fail.
bench :-
    player_position(Area),
    \+ bench_area(Area), !,
    write('Tidak ada Bench pada area ini.'), nl,
    fail.
bench :-
    bench_used(true), !,
    write('Bench pada reruntuhan ini sudah pernah digunakan.'), nl,
    fail.
bench :-
    max_mask(MaxMask),
    retractall(player_mask(_)),
    assertz(player_mask(MaxMask)),
    retractall(bench_used(_)),
    assertz(bench_used(true)),
    write('Vessel beristirahat pada Bench.'), nl,
    write('Mask Vessel dipulihkan hingga penuh.'), nl,
    format('Mask: ~w/~w~n', [MaxMask, MaxMask]).

% ----------------------------------------------------------------
% quit/0
% ----------------------------------------------------------------

quit :-
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(quit)),
    retractall(current_enemy(_)),
    retractall(enemy_hp(_, _)),
    write('Sesi permainan diakhiri tanpa menetapkan kondisi menang atau kalah.'), nl.

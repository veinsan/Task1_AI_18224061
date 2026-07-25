% Command permainan: eksplorasi, pertarungan, dan informasi

help :-
    nl,
    write('Daftar command yang tersedia:'), nl,
    write('play.              memulai permainan dan menjalankan loop utama.'), nl,
    write('help.              menampilkan daftar command ini.'), nl,
    write('status.            menampilkan kondisi permainan saat ini.'), nl,
    write('look.              menampilkan informasi area saat ini.'), nl,
    write('inventory.         menampilkan fragmen segel yang dimiliki.'), nl,
    write('move(Tujuan).      berpindah menuju area tujuan.'), nl,
    write('take(Item).        mengambil fragmen segel pada area saat ini.'), nl,
    write('attack.            menyerang musuh selama fase pertarungan.'), nl,
    write('bench.             menggunakan Bench untuk memulihkan Mask.'), nl,
    write('saveGame(Nama).    menyimpan kondisi permainan ke file.'), nl,
    write('loadGame(Nama).    memuat kondisi permainan dari file (dijalankan di luar play).'), nl,
    write('quit.              mengakhiri sesi permainan.'), nl,
    nl.

status :-
    player_position(Area),
    area_display_name(Area, AreaName),
    player_mask(Mask),
    max_mask(MaxMask),
    turn_left(Turns),
    game_state(State),
    inventory(Daftar),
    length(Daftar, Jumlah),
    nl,
    format("Area saat ini: ~w~n", [AreaName]),
    format("Mask: ~w/~w~n", [Mask, MaxMask]),
    format("Giliran tersisa: ~w~n", [Turns]),
    format("Fase permainan: ~w~n", [State]),
    format("Fragmen segel yang dikumpulkan: ~w/3~n", [Jumlah]),
    nl.

look :-
    player_position(Area),
    area_display_name(Area, AreaName),
    nl,
    format("Vessel berada di ~w.~n", [AreaName]),
    findall(Tujuan, connected(Area, Tujuan), DaftarTujuan),
    format("Area yang terhubung: ~w~n", [DaftarTujuan]),
    look_item(Area),
    look_enemy(Area),
    look_bench(Area),
    nl.

look_item(Area) :-
    item_in_area(Area, Item), !,
    item_display_name(Item, Nama),
    format("Objek pada area ini: ~w~n", [Nama]).
look_item(_) :-
    write('Tidak ada objek pada area ini.'), nl.

look_enemy(Area) :-
    enemy_in_area(Area, Enemy), !,
    enemy_display_name(Enemy, Nama),
    format("Terdapat musuh pada area ini: ~w~n", [Nama]).
look_enemy(_).

look_bench(Area) :-
    bench_area(Area), !,
    write('Terdapat Bench pada area ini.'), nl.
look_bench(_).

inventory :-
    inventory(Daftar),
    nl,
    write('Fragmen segel yang dimiliki:'), nl,
    print_fragments(Daftar),
    nl.

print_fragments([]) :-
    !,
    write('(belum ada fragmen yang dikumpulkan)'), nl.
print_fragments([Fragmen|Sisa]) :-
    item_display_name(Fragmen, Nama),
    format("- ~w~n", [Nama]),
    print_fragments(Sisa).

% move/1 : perpindahan antar area (menunjukkan Cut dan Fail)

move(_) :-
    game_state(battle), !,
    write('Tidak dapat berpindah area selama pertarungan berlangsung.'), nl,
    fail.
move(Tujuan) :-
    player_position(Sekarang),
    connected(Sekarang, Tujuan),
    exit_area(Tujuan),
    \+ has_all_fragments, !,
    write('Perpindahan gagal.'), nl,
    write('Gerbang Black Egg Temple masih terkunci karena ketiga segel belum terkumpul.'), nl,
    write('Posisi dan giliran pemain tidak berubah.'), nl,
    fail.
move(Tujuan) :-
    player_position(Sekarang),
    connected(Sekarang, Tujuan),
    exit_area(Tujuan),
    has_all_fragments, !,
    write('Ketiga segel telah terkumpul.'), nl,
    write('Gerbang Black Egg Temple berhasil dibuka.'), nl,
    retract(player_position(Sekarang)),
    assertz(player_position(Tujuan)),
    decrease_turn,
    area_display_name(Tujuan, NamaTujuan),
    format("Vessel berpindah ke ~w.~n", [NamaTujuan]),
    nl,
    start_battle(Tujuan),
    print_turn_left,
    check_turns_after_action.
move(Tujuan) :-
    player_position(Sekarang),
    connected(Sekarang, Tujuan), !,
    retract(player_position(Sekarang)),
    assertz(player_position(Tujuan)),
    decrease_turn,
    area_display_name(Tujuan, NamaTujuan),
    format("Vessel berpindah ke ~w.~n", [NamaTujuan]),
    handle_arrival_normal(Tujuan),
    print_turn_left,
    check_turns_after_action.
move(Tujuan) :-
    player_position(Sekarang),
    area_display_name(Sekarang, NamaSekarang),
    write('Perpindahan gagal.'), nl,
    format("~w tidak terhubung langsung dengan ~w.~n", [Tujuan, NamaSekarang]),
    write('Posisi dan giliran pemain tidak berubah.'), nl,
    fail.

handle_arrival_normal(Tujuan) :-
    enemy_in_area(Tujuan, _), !,
    start_battle(Tujuan).
handle_arrival_normal(_).

start_battle(Area) :-
    enemy_in_area(Area, Enemy),
    enemy_template(Enemy, HP, _),
    retractall(current_enemy(_)),
    assertz(current_enemy(Enemy)),
    retractall(enemy_hp(Enemy, _)),
    assertz(enemy_hp(Enemy, HP)),
    retractall(game_state(_)),
    assertz(game_state(battle)),
    enemy_display_name(Enemy, Nama),
    ( exit_area(Area) ->
        format("~w bangkit dan menghalangi jalan.~n", [Nama]),
        write('Fase pertarungan terakhir dimulai.'), nl
    ;
        format("Seekor ~w menghalangi perjalanan.~n", [Nama]),
        write('Fase pertarungan dimulai.'), nl
    ).

% take/1 : mengambil fragmen segel

take(_) :-
    \+ game_state(exploration), !,
    write('Pengambilan fragmen hanya dapat dilakukan selama fase eksplorasi.'), nl,
    fail.
take(Item) :-
    player_position(Area),
    item_in_area(Area, Item), !,
    retract(item_in_area(Area, Item)),
    inventory(Daftar),
    retract(inventory(Daftar)),
    assertz(inventory([Item|Daftar])),
    item_display_name(Item, Nama),
    format("Vessel mengambil ~w.~n", [Nama]),
    inventory(DaftarBaru),
    format("Fragmen segel yang dimiliki: ~w~n", [DaftarBaru]).
take(_) :-
    write('Tidak ada fragmen tersebut pada area ini.'), nl,
    fail.

% attack/0 : pertarungan

attack :-
    \+ game_state(battle), !,
    write('Serangan hanya dapat dilakukan selama fase pertarungan.'), nl,
    fail.
attack :-
    current_enemy(Enemy),
    enemy_hp(Enemy, HP),
    player_damage(Dmg),
    Sisa is HP - Dmg,
    enemy_display_name(Enemy, Nama),
    format("Vessel menyerang ~w menggunakan Nail.~n", [Nama]),
    format("Damage yang dihasilkan: ~w.~n", [Dmg]),
    resolve_attack(Enemy, Nama, Sisa).

resolve_attack(Enemy, Nama, Sisa) :-
    Sisa =< 0, !,
    retractall(enemy_hp(Enemy, _)),
    retractall(current_enemy(_)),
    player_position(Area),
    retractall(enemy_in_area(Area, Enemy)),
    format("~w berhasil dikalahkan.~n", [Nama]),
    decrease_turn,
    finish_battle(Area).
resolve_attack(Enemy, Nama, Sisa) :-
    enemy_template(Enemy, MaxHP, DmgMusuh),
    retractall(enemy_hp(Enemy, _)),
    assertz(enemy_hp(Enemy, Sisa)),
    format("Mask ~w tersisa: ~w/~w.~n", [Nama, Sisa, MaxHP]),
    nl,
    player_mask(MaskSekarang),
    MaskBaru is MaskSekarang - DmgMusuh,
    retractall(player_mask(_)),
    assertz(player_mask(MaskBaru)),
    format("~w membalas menyerang.~n", [Nama]),
    max_mask(MaxMask),
    format("Mask Vessel tersisa: ~w/~w.~n", [MaskBaru, MaxMask]),
    decrease_turn,
    print_turn_left,
    check_mask_after_action,
    check_turns_after_action.

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
    print_turn_left.

% bench/0 : memulihkan Mask

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
    format("Mask: ~w/~w~n", [MaxMask, MaxMask]).

% quit/0

quit :-
    retractall(game_state(_)),
    assertz(game_state(ended)),
    retractall(game_result(_)),
    assertz(game_result(quit)),
    write('Sesi permainan diakhiri tanpa menetapkan kondisi menang atau kalah.'), nl.
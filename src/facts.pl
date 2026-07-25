% ================================================================
% facts.pl
% Fakta statis dunia permainan Hollow Knight.
% ================================================================

% Area permainan.
area(forgotten_crossroads).
area(greenpath).
area(fungal_wastes).
area(black_egg_temple).

% Hubungan antardaerah bersifat dua arah dan dituliskan eksplisit.
connected(forgotten_crossroads, greenpath).
connected(greenpath, forgotten_crossroads).
connected(forgotten_crossroads, fungal_wastes).
connected(fungal_wastes, forgotten_crossroads).
connected(fungal_wastes, black_egg_temple).
connected(black_egg_temple, fungal_wastes).

% Nama yang ditampilkan kepada pemain.
area_display_name(forgotten_crossroads, 'Forgotten Crossroads').
area_display_name(greenpath, 'Greenpath').
area_display_name(fungal_wastes, 'Fungal Wastes').
area_display_name(black_egg_temple, 'Black Egg Temple').

% Area khusus.
start_area(forgotten_crossroads).
exit_area(black_egg_temple).
bench_area(fungal_wastes).

% Template item awal. Fakta ini disalin menjadi item_in_area/2 saat start/0.
initial_item_in_area(forgotten_crossroads, segel_lurien).
initial_item_in_area(greenpath, segel_herrah).
initial_item_in_area(fungal_wastes, segel_monomon).

item_display_name(segel_lurien, 'Segel Lurien').
item_display_name(segel_herrah, 'Segel Herrah').
item_display_name(segel_monomon, 'Segel Monomon').

% Ketiga fragmen yang wajib dimiliki sebelum gerbang terakhir dibuka.
required_fragments([segel_lurien, segel_herrah, segel_monomon]).

% Template musuh awal. Fakta ini disalin menjadi enemy_in_area/2 saat start/0.
initial_enemy_in_area(greenpath, husk).
initial_enemy_in_area(black_egg_temple, the_hollow_knight).

% enemy_template(Nama, MaskMaksimum, Damage).
enemy_template(husk, 2, 1).
enemy_template(the_hollow_knight, 5, 1).

enemy_display_name(husk, 'Husk').
enemy_display_name(the_hollow_knight, 'The Hollow Knight').

% Konfigurasi pemain.
max_mask(5).
initial_turns(30).
player_damage(1).

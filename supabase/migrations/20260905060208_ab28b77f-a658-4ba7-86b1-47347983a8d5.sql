INSERT INTO public.rod_tiers (id, name, max_catch_weight_kg, luck_percent, speed_percent, price_coins, sort_order) VALUES
  ('starter',   'Starter Rod',   10,   0,   0, 0,       0),
  ('uncommon',  'Uncommon Rod',  40,  10,   5, 1000,    1),
  ('rare',      'Rare Rod',      100, 25,  12, 10000,   2),
  ('epic',      'Epic Rod',      250, 50,  22, 60000,   3),
  ('legendary', 'Legendary Rod', 600, 80,  35, 250000,  4),
  ('mythic',    'Mythic Rod',    1500,130, 50, 1000000, 5)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, max_catch_weight_kg = EXCLUDED.max_catch_weight_kg,
  luck_percent = EXCLUDED.luck_percent, speed_percent = EXCLUDED.speed_percent,
  price_coins = EXCLUDED.price_coins, sort_order = EXCLUDED.sort_order;

INSERT INTO public.bait_tiers (id, name, rarity_multiplier, luck_percent, price_coins, sort_order) VALUES
  ('basic_bait',     'Basic Bait',     '{}'::jsonb, 0, 0, 0),
  ('uncommon_bait',  'Uncommon Bait',  '{"rare":1.3,"epic":1.1}'::jsonb, 20, 1000, 1),
  ('rare_bait',      'Rare Bait',      '{"rare":1.6,"epic":1.4,"legendary":1.1}'::jsonb, 50, 15000, 2),
  ('epic_bait',      'Epic Bait',      '{"rare":1.8,"epic":1.9,"legendary":1.5,"mythic":1.2}'::jsonb, 95, 120000, 3),
  ('legendary_bait', 'Legendary Bait', '{"rare":2.0,"epic":2.4,"legendary":2.2,"mythic":1.6}'::jsonb, 160, 600000, 4),
  ('mythic_bait',    'Mythic Bait',    '{"rare":2.2,"epic":3.0,"legendary":3.2,"mythic":2.8}'::jsonb, 250, 2000000, 5)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, rarity_multiplier = EXCLUDED.rarity_multiplier,
  luck_percent = EXCLUDED.luck_percent, price_coins = EXCLUDED.price_coins, sort_order = EXCLUDED.sort_order;

INSERT INTO public.fish_species (id, name, color, rarity, min_weight_kg, max_weight_kg, is_monster, base_price_per_kg) VALUES
  ('clownfish',         'Clownfish',         '#f5a623', 'common',    5,    40,   false, 4),
  ('mackerel',          'Mackerel',          '#8fd0e8', 'rare',      35,   120,  false, 6),
  ('scad',              'Scad',              '#a7e0b0', 'epic',      100,  300,  false, 9),
  ('red_snapper',       'Red Snapper',       '#e8734a', 'legendary', 280,  650,  false, 14),
  ('baby_tuna',         'Baby Tuna',         '#5b7fa6', 'mythic',    600,  1300, false, 22),
  ('ancient_leviathan', 'Ancient Leviathan', '#1e46b4', 'mythic',    1200, 3000, true,  40)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, color = EXCLUDED.color, rarity = EXCLUDED.rarity,
  min_weight_kg = EXCLUDED.min_weight_kg, max_weight_kg = EXCLUDED.max_weight_kg,
  is_monster = EXCLUDED.is_monster, base_price_per_kg = EXCLUDED.base_price_per_kg;

INSERT INTO public.rarity_base_weights (rarity, base_weight) VALUES
  ('common', 100), ('rare', 45), ('epic', 18), ('legendary', 6), ('mythic', 2)
ON CONFLICT (rarity) DO UPDATE SET base_weight = EXCLUDED.base_weight;

INSERT INTO public.mutations (key, label, multiplier, drop_weight) VALUES
  ('none', 'Normal', 1, 55), ('big', 'Big', 1.2, 15), ('dark', 'Dark', 1.3, 10),
  ('albino', 'Albino', 1.4, 7), ('sparkling', 'Sparkling', 1.5, 5)
ON CONFLICT (key) DO UPDATE SET label = EXCLUDED.label, multiplier = EXCLUDED.multiplier, drop_weight = EXCLUDED.drop_weight;

INSERT INTO public.weather_effects (weather_kind, bite_window_seconds, rarity_multiplier) VALUES
  ('cerah',    1.6, '{}'::jsonb),
  ('berawan',  1.6, '{}'::jsonb),
  ('berkabut', 1.3, '{"epic":1.3,"legendary":1.3,"mythic":1.3}'::jsonb),
  ('hujan',    1.1, '{"epic":1.3,"legendary":1.5,"mythic":1.5}'::jsonb),
  ('badai',    0.9, '{"legendary":1.8,"mythic":2.5}'::jsonb)
ON CONFLICT (weather_kind) DO UPDATE SET bite_window_seconds = EXCLUDED.bite_window_seconds, rarity_multiplier = EXCLUDED.rarity_multiplier;

INSERT INTO public.weather_cycle_config (id, change_interval_seconds, weights) VALUES
  ('default', 240, '{"cerah":40,"berawan":25,"berkabut":15,"hujan":12,"badai":8}'::jsonb)
ON CONFLICT (id) DO UPDATE SET change_interval_seconds = EXCLUDED.change_interval_seconds, weights = EXCLUDED.weights;

INSERT INTO public.game_config (key, value) VALUES
  ('monster_catch_chance', 0.02), ('day_length_seconds', 720)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
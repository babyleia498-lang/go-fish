CREATE OR REPLACE FUNCTION public.ensure_starter_gear(_wallet text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF _wallet IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.profiles WHERE wallet_address = _wallet
  ) THEN
    RETURN;
  END IF;

  INSERT INTO public.player_rods (wallet_address, rod_id, equipped)
  VALUES (_wallet, 'starter', true)
  ON CONFLICT (wallet_address, rod_id) DO NOTHING;

  INSERT INTO public.player_baits (wallet_address, bait_id, equipped)
  VALUES (_wallet, 'basic_bait', true)
  ON CONFLICT (wallet_address, bait_id) DO NOTHING;

  IF NOT EXISTS (SELECT 1 FROM public.player_rods WHERE wallet_address = _wallet AND equipped) THEN
    UPDATE public.player_rods SET equipped = true WHERE wallet_address = _wallet AND rod_id = 'starter';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.player_baits WHERE wallet_address = _wallet AND equipped) THEN
    UPDATE public.player_baits SET equipped = true WHERE wallet_address = _wallet AND bait_id = 'basic_bait';
  END IF;
END;
$function$;

REVOKE EXECUTE ON FUNCTION public.ensure_starter_gear(text) FROM anon, authenticated, public;
GRANT EXECUTE ON FUNCTION public.ensure_starter_gear(text) TO service_role;

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

DELETE FROM public.rod_tiers WHERE id = 'common';

INSERT INTO public.bait_tiers (id, name, rarity_multiplier, luck_percent, price_coins, sort_order) VALUES
  ('basic_bait',     'Basic Bait',     '{}'::jsonb, 0, 0, 0),
  ('uncommon_bait',  'Uncommon Bait',  '{"rare":1.3,"epic":1.1}'::jsonb, 20, 1000, 1),
  ('rare_bait',      'Rare Bait',      '{"rare":1.6,"epic":1.4,"legendary":1.1}'::jsonb, 50, 15000, 2),
  ('epic_bait',      'Epic Bait',      '{"rare":1.8,"epic":1.9,"legendary":1.5,"mythic":1.2}'::jsonb, 95, 120000, 3),
  ('legendary_bait', 'Legendary Bait', '{"rare":2.0,"epic":2.4,"legendary":2.2,"mythic":1.6}'::jsonb, 160, 600000, 4),
  ('mythic_bait',    'Mythic Bait',    '{"rare":2.2,"epic":3.0,"legendary":3.2,"mythic":2.8}'::jsonb, 250, 2000000, 5)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, rarity_multiplier = EXCLUDED.rarity_multiplier,
  luck_percent = EXCLUDED.luck_percent, price_coins = EXCLUDED.price_coins, sort_order = EXCLUDED.sort_order;
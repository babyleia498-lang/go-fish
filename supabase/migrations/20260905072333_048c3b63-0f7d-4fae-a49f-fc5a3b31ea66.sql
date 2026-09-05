CREATE TABLE public.boat_tiers (
  id text PRIMARY KEY,
  name text NOT NULL,
  speed_percent numeric NOT NULL DEFAULT 100,
  price_coins numeric NOT NULL DEFAULT 0,
  sort_order integer NOT NULL DEFAULT 0
);

GRANT SELECT ON public.boat_tiers TO anon;
GRANT SELECT ON public.boat_tiers TO authenticated;
GRANT ALL ON public.boat_tiers TO service_role;

ALTER TABLE public.boat_tiers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read" ON public.boat_tiers FOR SELECT TO anon, authenticated USING (true);

CREATE TABLE public.player_boats (
  wallet_address text NOT NULL REFERENCES public.profiles(wallet_address) ON DELETE CASCADE,
  boat_id text NOT NULL REFERENCES public.boat_tiers(id),
  equipped boolean NOT NULL DEFAULT false,
  purchased_at timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY (wallet_address, boat_id)
);

GRANT ALL ON public.player_boats TO service_role;

ALTER TABLE public.player_boats ENABLE ROW LEVEL SECURITY;

INSERT INTO public.boat_tiers (id, name, speed_percent, price_coins, sort_order) VALUES
  ('wooden_dinghy', 'Wooden Dinghy', 100, 0, 0),
  ('minnow', 'Minnow', 120, 100000, 1),
  ('reef_runner', 'Reef Runner', 150, 250000, 2),
  ('bow_raider', 'Bow Raider', 200, 500000, 3),
  ('sea_marshal', 'Sea Marshal', 250, 1000000, 4),
  ('vex_yacht', 'Vex Yacht', 300, 2500000, 5);

CREATE OR REPLACE FUNCTION public.get_player_boats(_wallet text)
RETURNS TABLE(boat_id text, name text, speed_percent numeric, price_coins numeric, equipped boolean, purchased_at timestamp with time zone)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT t.id, t.name, t.speed_percent, t.price_coins,
         coalesce(p.equipped, false), p.purchased_at
  FROM public.boat_tiers t
  LEFT JOIN public.player_boats p ON p.boat_id = t.id AND p.wallet_address = _wallet
  ORDER BY t.sort_order, t.price_coins;
$$;

CREATE OR REPLACE FUNCTION public.buy_boat(_wallet text, _boat_id text)
RETURNS profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  result public.profiles;
  cost numeric;
BEGIN
  SELECT price_coins INTO cost FROM public.boat_tiers WHERE id = _boat_id;
  IF cost IS NULL THEN
    RAISE EXCEPTION 'Unknown boat';
  END IF;

  IF EXISTS (SELECT 1 FROM public.player_boats WHERE wallet_address = _wallet AND boat_id = _boat_id) THEN
    SELECT * INTO result FROM public.profiles WHERE wallet_address = _wallet;
    RETURN result;
  END IF;

  UPDATE public.profiles SET coins = coins - cost, updated_at = now()
   WHERE wallet_address = _wallet AND coins >= cost
  RETURNING * INTO result;

  IF result IS NULL THEN
    RAISE EXCEPTION 'Not enough coins';
  END IF;

  INSERT INTO public.player_boats (wallet_address, boat_id, equipped)
  VALUES (_wallet, _boat_id, false)
  ON CONFLICT (wallet_address, boat_id) DO NOTHING;

  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.equip_boat(_wallet text, _boat_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.player_boats WHERE wallet_address = _wallet AND boat_id = _boat_id) THEN
    RAISE EXCEPTION 'Boat not owned';
  END IF;
  UPDATE public.player_boats SET equipped = (boat_id = _boat_id) WHERE wallet_address = _wallet;
END;
$$;

CREATE OR REPLACE FUNCTION public.ensure_starter_gear(_wallet text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
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

  INSERT INTO public.player_boats (wallet_address, boat_id, equipped)
  VALUES (_wallet, 'wooden_dinghy', true)
  ON CONFLICT (wallet_address, boat_id) DO NOTHING;

  IF NOT EXISTS (SELECT 1 FROM public.player_rods WHERE wallet_address = _wallet AND equipped) THEN
    UPDATE public.player_rods SET equipped = true WHERE wallet_address = _wallet AND rod_id = 'starter';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.player_baits WHERE wallet_address = _wallet AND equipped) THEN
    UPDATE public.player_baits SET equipped = true WHERE wallet_address = _wallet AND bait_id = 'basic_bait';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.player_boats WHERE wallet_address = _wallet AND equipped) THEN
    UPDATE public.player_boats SET equipped = true WHERE wallet_address = _wallet AND boat_id = 'wooden_dinghy';
  END IF;
END;
$$;

INSERT INTO public.player_boats (wallet_address, boat_id, equipped)
SELECT wallet_address, 'wooden_dinghy', true FROM public.profiles
ON CONFLICT (wallet_address, boat_id) DO NOTHING;
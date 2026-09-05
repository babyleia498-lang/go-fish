ALTER TABLE public.rod_tiers
  ADD COLUMN IF NOT EXISTS luck_percent numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS speed_percent numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS price_coins numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0;

ALTER TABLE public.bait_tiers
  ADD COLUMN IF NOT EXISTS luck_percent numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS price_coins numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS public.player_rods (
  wallet_address text NOT NULL REFERENCES public.profiles(wallet_address) ON DELETE CASCADE,
  rod_id text NOT NULL REFERENCES public.rod_tiers(id) ON DELETE CASCADE,
  equipped boolean NOT NULL DEFAULT false,
  purchased_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (wallet_address, rod_id)
);

CREATE TABLE IF NOT EXISTS public.player_baits (
  wallet_address text NOT NULL REFERENCES public.profiles(wallet_address) ON DELETE CASCADE,
  bait_id text NOT NULL REFERENCES public.bait_tiers(id) ON DELETE CASCADE,
  equipped boolean NOT NULL DEFAULT false,
  purchased_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (wallet_address, bait_id)
);

GRANT ALL ON public.player_rods, public.player_baits TO service_role;
ALTER TABLE public.player_rods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_baits ENABLE ROW LEVEL SECURITY;
-- No anon/authenticated policies: all access goes through verified server code.

CREATE OR REPLACE FUNCTION public.get_player_rods(_wallet text)
RETURNS TABLE (
  rod_id text,
  name text,
  max_catch_weight_kg numeric,
  luck_percent numeric,
  speed_percent numeric,
  price_coins numeric,
  equipped boolean,
  purchased_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT t.id, t.name, t.max_catch_weight_kg, t.luck_percent, t.speed_percent, t.price_coins,
         coalesce(p.equipped, false), p.purchased_at
  FROM public.rod_tiers t
  LEFT JOIN public.player_rods p ON p.rod_id = t.id AND p.wallet_address = _wallet
  ORDER BY t.sort_order, t.price_coins;
$$;

CREATE OR REPLACE FUNCTION public.get_player_baits(_wallet text)
RETURNS TABLE (
  bait_id text,
  name text,
  luck_percent numeric,
  price_coins numeric,
  equipped boolean,
  purchased_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT t.id, t.name, t.luck_percent, t.price_coins,
         coalesce(p.equipped, false), p.purchased_at
  FROM public.bait_tiers t
  LEFT JOIN public.player_baits p ON p.bait_id = t.id AND p.wallet_address = _wallet
  ORDER BY t.sort_order, t.price_coins;
$$;

CREATE OR REPLACE FUNCTION public.buy_rod(_wallet text, _rod_id text)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  result public.profiles;
  cost numeric;
BEGIN
  SELECT price_coins INTO cost FROM public.rod_tiers WHERE id = _rod_id;
  IF cost IS NULL THEN
    RAISE EXCEPTION 'Unknown rod';
  END IF;

  IF EXISTS (SELECT 1 FROM public.player_rods WHERE wallet_address = _wallet AND rod_id = _rod_id) THEN
    SELECT * INTO result FROM public.profiles WHERE wallet_address = _wallet;
    RETURN result;
  END IF;

  UPDATE public.profiles SET coins = coins - cost, updated_at = now()
   WHERE wallet_address = _wallet AND coins >= cost
  RETURNING * INTO result;

  IF result IS NULL THEN
    RAISE EXCEPTION 'Not enough coins';
  END IF;

  INSERT INTO public.player_rods (wallet_address, rod_id, equipped)
  VALUES (_wallet, _rod_id, false)
  ON CONFLICT (wallet_address, rod_id) DO NOTHING;

  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.buy_bait(_wallet text, _bait_id text)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  result public.profiles;
  cost numeric;
BEGIN
  SELECT price_coins INTO cost FROM public.bait_tiers WHERE id = _bait_id;
  IF cost IS NULL THEN
    RAISE EXCEPTION 'Unknown bait';
  END IF;

  IF EXISTS (SELECT 1 FROM public.player_baits WHERE wallet_address = _wallet AND bait_id = _bait_id) THEN
    SELECT * INTO result FROM public.profiles WHERE wallet_address = _wallet;
    RETURN result;
  END IF;

  UPDATE public.profiles SET coins = coins - cost, updated_at = now()
   WHERE wallet_address = _wallet AND coins >= cost
  RETURNING * INTO result;

  IF result IS NULL THEN
    RAISE EXCEPTION 'Not enough coins';
  END IF;

  INSERT INTO public.player_baits (wallet_address, bait_id, equipped)
  VALUES (_wallet, _bait_id, false)
  ON CONFLICT (wallet_address, bait_id) DO NOTHING;

  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.equip_rod(_wallet text, _rod_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.player_rods WHERE wallet_address = _wallet AND rod_id = _rod_id) THEN
    RAISE EXCEPTION 'Rod not owned';
  END IF;
  UPDATE public.player_rods SET equipped = (rod_id = _rod_id) WHERE wallet_address = _wallet;
END;
$$;

CREATE OR REPLACE FUNCTION public.equip_bait(_wallet text, _bait_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.player_baits WHERE wallet_address = _wallet AND bait_id = _bait_id) THEN
    RAISE EXCEPTION 'Bait not owned';
  END IF;
  UPDATE public.player_baits SET equipped = (bait_id = _bait_id) WHERE wallet_address = _wallet;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_player_rods(text) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.get_player_baits(text) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.buy_rod(text, text) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.buy_bait(text, text) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.equip_rod(text, text) FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.equip_bait(text, text) FROM anon, authenticated, public;
GRANT EXECUTE ON FUNCTION public.get_player_rods(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_player_baits(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.buy_rod(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.buy_bait(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.equip_rod(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.equip_bait(text, text) TO service_role;
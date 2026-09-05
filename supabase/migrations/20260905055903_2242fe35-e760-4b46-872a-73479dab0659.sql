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
REVOKE EXECUTE ON FUNCTION public.buy_bait(text, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.buy_rod(text, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.ensure_starter_gear(text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.equip_bait(text, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.equip_rod(text, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_player_baits(text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_player_rods(text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.record_catch(text, text, text, numeric, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.sell_fish(text, uuid, text, boolean) FROM anon, authenticated;
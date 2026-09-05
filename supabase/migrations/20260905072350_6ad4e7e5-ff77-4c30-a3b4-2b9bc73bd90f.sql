REVOKE ALL ON FUNCTION public.get_player_boats(text) FROM anon, authenticated;
REVOKE ALL ON FUNCTION public.buy_boat(text, text) FROM anon, authenticated;
REVOKE ALL ON FUNCTION public.equip_boat(text, text) FROM anon, authenticated;
REVOKE ALL ON FUNCTION public.ensure_starter_gear(text) FROM anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_player_boats(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.buy_boat(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.equip_boat(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.ensure_starter_gear(text) TO service_role;
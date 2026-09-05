import bowRaider from "@/assets/220__bow__raider_power_boat_ss.glb.asset.json";
import motorBoat from "@/assets/motor_boat_iii_empty.glb.asset.json";
import minnowIii from "@/assets/ss_minnow_iii.glb.asset.json";
import minnowIv from "@/assets/ss_minnow_iv.glb.asset.json";
import yachtIi from "@/assets/yacht_ii.glb.asset.json";
// the CDN pointer for the starter dinghy is stale, so ship the bundled file
import woodenDinghyUrl from "@/assets/boat.glb?url";

export interface BoatLook {
  id: string;
  /** GLB url (CDN asset pointer). */
  url: string;
  /** Target hull length in local units before BOAT_SCALE. */
  targetLength: number;
}

export const DEFAULT_BOAT_ID = "wooden_dinghy";

export const BOAT_LOOKS: Record<string, BoatLook> = {
  wooden_dinghy: { id: "wooden_dinghy", url: woodenDinghyUrl, targetLength: 7.4 },
  minnow: { id: "minnow", url: minnowIii.url, targetLength: 8.2 },
  reef_runner: { id: "reef_runner", url: minnowIv.url, targetLength: 8.8 },
  bow_raider: { id: "bow_raider", url: bowRaider.url, targetLength: 9.6 },
  sea_marshal: { id: "sea_marshal", url: motorBoat.url, targetLength: 10.4 },
  vex_yacht: { id: "vex_yacht", url: yachtIi.url, targetLength: 12.5 },
};

export function boatLook(id: string | null | undefined): BoatLook {
  return BOAT_LOOKS[id ?? ""] ?? BOAT_LOOKS[DEFAULT_BOAT_ID]!;
}

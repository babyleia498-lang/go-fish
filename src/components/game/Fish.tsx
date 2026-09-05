import { useFrame } from "@react-three/fiber";
import { useGLTF } from "@react-three/drei";
import { Suspense, useMemo, useRef } from "react";
import * as THREE from "three";
import { useHookedFish } from "@/hooks/useHookedFish";
import {
  ALL_FISH_MODEL_URLS,
  pickFishModel,
  weightScale,
  type FishModelDef,
} from "@/lib/fishModels";

/** Blocky low-poly fish: body + wagging tail + fins. Fallback while loading. */
export function FishFallback({
  color = "#7fc7e8",
  scale = 1,
  wagSpeed = 12,
}: {
  color?: string;
  scale?: number;
  wagSpeed?: number;
}) {
  const tail = useRef<THREE.Group>(null);
  const fin = useRef<THREE.Group>(null);

  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (tail.current) tail.current.rotation.y = Math.sin(t * wagSpeed) * 0.7;
    if (fin.current) fin.current.rotation.x = Math.sin(t * wagSpeed * 0.7) * 0.5;
  });

  return (
    <group scale={scale}>
      <mesh castShadow>
        <sphereGeometry args={[0.5, 12, 10]} />
        <meshStandardMaterial color={color} roughness={0.35} metalness={0.15} />
      </mesh>
      <mesh scale={[1.7, 0.85, 0.55]} castShadow>
        <sphereGeometry args={[0.5, 12, 10]} />
        <meshStandardMaterial color={color} roughness={0.35} metalness={0.15} />
      </mesh>
      {/* belly */}
      <mesh position={[0.05, -0.14, 0]} scale={[1.35, 0.5, 0.42]}>
        <sphereGeometry args={[0.5, 10, 8]} />
        <meshStandardMaterial color="#f3f0e6" roughness={0.5} />
      </mesh>
      {/* eyes */}
      {[-1, 1].map((s) => (
        <mesh key={s} position={[0.62, 0.12, s * 0.18]}>
          <sphereGeometry args={[0.09, 8, 8]} />
          <meshStandardMaterial color="#12161c" />
        </mesh>
      ))}
      {/* dorsal fin */}
      <group ref={fin} position={[-0.05, 0.34, 0]}>
        <mesh castShadow>
          <coneGeometry args={[0.22, 0.42, 4]} />
          <meshStandardMaterial color={color} roughness={0.5} />
        </mesh>
      </group>
      {/* tail */}
      <group ref={tail} position={[-0.82, 0, 0]}>
        <mesh rotation={[0, 0, Math.PI / 2]} castShadow>
          <coneGeometry args={[0.34, 0.6, 3]} />
          <meshStandardMaterial color={color} roughness={0.5} />
        </mesh>
      </group>
    </group>
  );
}

/** Loads one GLB, centres it, and normalises it to the requested length. */
function FishModel({ def, size }: { def: FishModelDef; size: number }) {
  const { scene } = useGLTF(def.url, "/draco/");
  const model = useMemo(() => {
    const root = scene.clone(true);
    root.traverse((o) => {
      const mesh = o as THREE.Mesh;
      if (mesh.isMesh) {
        mesh.castShadow = true;
        mesh.receiveShadow = true;
      }
    });
    const box = new THREE.Box3().setFromObject(root);
    const dim = box.getSize(new THREE.Vector3());
    const centre = box.getCenter(new THREE.Vector3());
    root.position.sub(centre);
    // longest axis = the body length; lay it along local +x like the old mesh
    const longest = Math.max(dim.x, dim.y, dim.z) || 1;
    const wrap = new THREE.Group();
    wrap.add(root);
    if (dim.z > dim.x && dim.z >= dim.y) wrap.rotation.y = Math.PI / 2;
    const s = def.length / longest;
    wrap.scale.setScalar(s);
    const holder = new THREE.Group();
    holder.add(wrap);
    return holder;
  }, [scene, def.length, def.url]);

  const swim = useRef<THREE.Group>(null);
  useFrame((state) => {
    const t = state.clock.elapsedTime;
    if (swim.current) {
      swim.current.rotation.z = Math.sin(t * 9) * 0.14;
      swim.current.rotation.y = Math.sin(t * 6) * 0.1;
    }
  });

  return (
    <group ref={swim} scale={size}>
      <primitive object={model} />
    </group>
  );
}

/**
 * The fish hanging on the line. Uses the rarity model locked in when the fish
 * bit; falls back to the procedural mesh until the GLB is decoded.
 */
export function FishMesh({
  color = "#e8a04a",
  scale = 1,
  wagSpeed = 18,
}: {
  color?: string;
  scale?: number;
  wagSpeed?: number;
}) {
  const model = useHookedFish((s) => s.model);
  const rarity = useHookedFish((s) => s.rarity);
  const weight = useHookedFish((s) => s.weight);
  const def = model ?? pickFishModel(rarity);
  const size = scale * weightScale(weight, rarity);

  return (
    <Suspense fallback={<FishFallback color={color} scale={scale} wagSpeed={wagSpeed} />}>
      <FishModel def={def} size={size} />
    </Suspense>
  );
}

ALL_FISH_MODEL_URLS.forEach((u) => useGLTF.preload(u, "/draco/"));

/** Ambient surface fish removed — no fish may leap out of the water. */
export function FishSchool() {
  return null;
}

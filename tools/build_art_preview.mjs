import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve(import.meta.dirname, "..");
const game = path.join(root, "assets/game");
const regions = JSON.parse(fs.readFileSync(path.join(game, "atlas_regions.json"), "utf8"));
const outDir = path.join(game, "previews");
fs.mkdirSync(outDir, { recursive: true });

const files = {
  environment_tiles: path.join(game, "atlases/environment_tiles.png"),
  props_atlas: path.join(game, "atlases/props_atlas.png"),
  qin_zheng_spritesheet: path.join(game, "characters/qin_zheng_spritesheet.png"),
};

const regionMaps = {};
for (const [atlasName, atlas] of Object.entries(regions.atlases)) {
  regionMaps[atlasName] = new Map((atlas.regions ?? []).map((region) => [region.id, region]));
}

async function extract(atlasName, id) {
  const region = regionMaps[atlasName].get(id);
  if (!region) throw new Error(`Unknown ${atlasName} region: ${id}`);
  return sharp(files[atlasName])
    .extract({ left: region.x, top: region.y, width: region.w, height: region.h })
    .png()
    .toBuffer();
}

const layers = [];
const place = async (atlasName, id, left, top) => layers.push({ input: await extract(atlasName, id), left, top });

// Native 640×360 composition preview. It deliberately uses only exported runtime
// atlases; lighting is a separate engine-like overlay rather than baked asset detail.
for (let row = 0; row < 7; row++) {
  for (let col = 0; col < 10; col++) {
    await place("environment_tiles", `floor_wood_${((row * 3 + col) % 4) + 1}`, 144 + col * 32, 64 + row * 32);
  }
}

for (let col = 0; col < 10; col++) {
  await place("environment_tiles", `wall_cold_${(col % 4) + 1}`, 144 + col * 32, 32);
}
for (let row = 0; row < 7; row++) {
  await place("environment_tiles", row === 0 ? "wall_corner_left" : "wall_side_left", 112, 64 + row * 32);
  await place("environment_tiles", row === 0 ? "wall_corner_right" : "wall_side_right", 464, 64 + row * 32);
}

await place("environment_tiles", "front_wall", 112, 288);
await place("environment_tiles", "front_wall", 400, 288);
await place("environment_tiles", "doorway_open", 288, 272);

// A short slice of hallway preserves the bedroom's role as negative space and
// demonstrates that the open doorway stays readable without a glow outline.
for (let row = 0; row < 2; row++) {
  for (let col = 0; col < 4; col++) {
    await place("environment_tiles", `floor_wood_${((row + col * 2) % 4) + 1}`, 256 + col * 32, 320 + row * 32);
  }
}
await place("environment_tiles", "carpet_hall", 304, 320);

await place("props_atlas", "bedroom_rug", 256, 176);
await place("props_atlas", "bedroom_window", 288, 64);
await place("props_atlas", "bed_loop1", 160, 96);
await place("props_atlas", "bedside_table", 256, 112);
await place("props_atlas", "bedroom_lamp", 256, 96);
await place("props_atlas", "wardrobe_closed", 384, 64);
await place("props_atlas", "wedding_photo_loop1", 320, 48);
const characterFrame = await sharp(files.qin_zheng_spritesheet)
  .extract({ left: 0, top: 0, width: 32, height: 48 })
  .png()
  .toBuffer();
layers.push({ input: characterFrame, left: 304, top: 224 });

const lighting = Buffer.from(`
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="360">
  <defs>
    <radialGradient id="lamp" cx="50%" cy="40%" r="50%">
      <stop offset="0" stop-color="#C29A5B" stop-opacity="0.24"/>
      <stop offset="0.38" stop-color="#C29A5B" stop-opacity="0.09"/>
      <stop offset="1" stop-color="#0B0C14" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="sight" cx="50%" cy="50%" r="50%">
      <stop offset="0" stop-color="#40525A" stop-opacity="0.12"/>
      <stop offset="1" stop-color="#0B0C14" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <ellipse cx="256" cy="132" rx="156" ry="112" fill="url(#lamp)"/>
  <ellipse cx="320" cy="248" rx="112" ry="86" fill="url(#sight)"/>
</svg>`);

const vignette = Buffer.from(`
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="360">
  <defs>
    <radialGradient id="vignette" cx="50%" cy="48%" r="64%">
      <stop offset="0.42" stop-color="#030407" stop-opacity="0"/>
      <stop offset="0.72" stop-color="#030407" stop-opacity="0.28"/>
      <stop offset="1" stop-color="#030407" stop-opacity="0.94"/>
    </radialGradient>
  </defs>
  <rect width="640" height="360" fill="url(#vignette)"/>
</svg>`);

const target = path.join(outDir, "bedroom_benchmark.png");
await sharp({ create: { width: 640, height: 360, channels: 4, background: "#030407" } })
  .composite([...layers, { input: lighting, left: 0, top: 0, blend: "screen" }, { input: vignette, left: 0, top: 0, blend: "over" }])
  .png({ compressionLevel: 9 })
  .toFile(`${target}.next`);
fs.renameSync(`${target}.next`, target);

console.log(`Wrote native-resolution art preview to ${target}`);

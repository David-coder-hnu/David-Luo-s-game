import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve(import.meta.dirname, "..");
const source = path.join(root, "assets/game/source");

const jobs = [
  ["environment_tiles.svg", "assets/game/atlases/environment_tiles.png"],
  ["props_atlas.svg", "assets/game/atlases/props_atlas.png"],
  ["qin_zheng_spritesheet.svg", "assets/game/characters/qin_zheng_spritesheet.png"],
  ["ui_atlas.svg", "assets/game/ui/ui_atlas.png"],
  ["wordmark.svg", "assets/game/ui/wordmark.png"],
  ["fx_patterns.svg", "assets/game/fx/fx_patterns.png"],
];

for (const [input, output] of jobs) {
  const target = path.join(root, output);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  await sharp(path.join(source, input), { density: 72 }).png({ compressionLevel: 9 }).toFile(`${target}.next`);
  fs.renameSync(`${target}.next`, target);
}

fs.copyFileSync(path.join(source, "atlas_regions.json"), path.join(root, "assets/game/atlas_regions.json"));
console.log(`Exported ${jobs.length} deterministic SVG sources to runtime PNG assets.`);

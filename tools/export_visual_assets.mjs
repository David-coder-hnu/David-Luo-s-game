import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve(import.meta.dirname, "..");
const source = path.join(root, "assets/game/source");

const jobs = [
  ["environment_tiles.svg", "assets/game/atlases/environment_tiles.png", 2, "environment_details.svg"],
  ["props_atlas.svg", "assets/game/atlases/props_atlas.png", 2, "props_details.svg"],
  ["qin_zheng_spritesheet.svg", "assets/game/characters/qin_zheng_spritesheet.png", 2, "qin_zheng_details.svg"],
  ["ui_atlas.svg", "assets/game/ui/ui_atlas.png", 1],
  ["wordmark.svg", "assets/game/ui/wordmark.png", 1],
  ["fx_patterns.svg", "assets/game/fx/fx_patterns.png", 1],
];

for (const [input, output, scale, details] of jobs) {
  const target = path.join(root, output);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  const base = sharp(path.join(source, input), { density: 72 });
  const metadata = await base.metadata();
  let pipeline = base.resize(metadata.width * scale, metadata.height * scale, { kernel: "nearest" });
  if (details) pipeline = pipeline.composite([{ input: path.join(source, details), left: 0, top: 0 }]);
  await pipeline.png({ compressionLevel: 9 }).toFile(`${target}.next`);
  fs.renameSync(`${target}.next`, target);
}

fs.copyFileSync(path.join(source, "atlas_regions.json"), path.join(root, "assets/game/atlas_regions.json"));
console.log(`Exported ${jobs.length} deterministic SVG sources to runtime PNG assets.`);

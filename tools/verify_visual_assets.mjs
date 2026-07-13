import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve(import.meta.dirname, "..");
const game = path.join(root, "assets/game");
const regions = JSON.parse(fs.readFileSync(path.join(game, "atlas_regions.json"), "utf8"));

const expected = new Map([
  ["atlases/environment_tiles.png", [512, 256]],
  ["atlases/props_atlas.png", [1024, 512]],
  ["characters/qin_zheng_spritesheet.png", [128, 192]],
  ["ui/ui_atlas.png", [256, 128]],
  ["ui/wordmark.png", [640, 180]],
  ["ui/title_background.png", [640, 360]],
  ["fx/fx_patterns.png", [256, 256]],
  ["previews/bedroom_benchmark.png", [640, 360]],
  ["closeups/kitchen_receipt.png", [320, 180]],
  ["closeups/child_drawing_loop1.png", [320, 180]],
  ["closeups/child_drawing_loop2.png", [320, 180]],
  ["closeups/wedding_photo_loop1.png", [320, 180]],
  ["closeups/wedding_photo_loop2.png", [320, 180]],
  ["closeups/memory_tape.png", [320, 180]],
]);

function dimensions(file) {
  const out = execFileSync("/usr/bin/sips", ["-g", "pixelWidth", "-g", "pixelHeight", file], { encoding: "utf8" });
  const w = Number(out.match(/pixelWidth:\s*(\d+)/)?.[1]);
  const h = Number(out.match(/pixelHeight:\s*(\d+)/)?.[1]);
  return [w, h];
}

const errors = [];
for (const [rel, size] of expected) {
  const file = path.join(game, rel);
  if (!fs.existsSync(file)) {
    errors.push(`missing ${rel}`);
    continue;
  }
  const actual = dimensions(file);
  if (actual[0] !== size[0] || actual[1] !== size[1]) errors.push(`${rel}: expected ${size.join("x")}, got ${actual.join("x")}`);
}

for (const rel of [...expected.keys()].filter((name) => name.startsWith("closeups/"))) {
  const { data, info } = await sharp(path.join(game, rel)).raw().toBuffer({ resolveWithObject: true });
  const colors = new Set();
  for (let i = 0; i < data.length; i += info.channels) {
    colors.add(`${data[i]},${data[i + 1]},${data[i + 2]},${info.channels === 4 ? data[i + 3] : 255}`);
    if (colors.size > 32) break;
  }
  if (colors.size > 32) errors.push(`${rel}: exceeds 32 runtime colors`);
}

const ids = new Set();
for (const [atlasName, atlas] of Object.entries(regions.atlases)) {
  const [aw, ah] = atlas.size;
  for (const region of atlas.regions ?? []) {
    if (ids.has(region.id)) errors.push(`duplicate region id ${region.id}`);
    ids.add(region.id);
    if (region.x < 0 || region.y < 0 || region.w <= 0 || region.h <= 0 || region.x + region.w > aw || region.y + region.h > ah) {
      errors.push(`${atlasName}/${region.id}: out of bounds`);
    }
  }
}

const allowedColors = new Set(Object.values(regions.palette).map((value) => value.toUpperCase()));
for (const file of fs.readdirSync(path.join(game, "source")).filter((name) => name.endsWith(".svg"))) {
  const body = fs.readFileSync(path.join(game, "source", file), "utf8");
  for (const match of body.matchAll(/#[0-9A-Fa-f]{6}/g)) {
    if (!allowedColors.has(match[0].toUpperCase())) errors.push(`${file}: non-bible color ${match[0]}`);
  }
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}

console.log(`PASS ${expected.size} raster dimensions`);
console.log(`PASS ${ids.size} unique atlas regions within bounds`);
console.log("PASS deterministic SVG sources use only the art-bible palette");
console.log("PASS generated runtime close-ups use no more than 32 colors each");

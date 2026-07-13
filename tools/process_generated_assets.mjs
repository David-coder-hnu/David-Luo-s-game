import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve(import.meta.dirname, "..");
const source = path.join(root, "assets/game/source/generated");
const closeups = path.join(root, "assets/game/closeups");
fs.mkdirSync(closeups, { recursive: true });

const jobs = [
  ["kitchen_receipt_source.png", "kitchen_receipt.png"],
  ["child_drawing_loop1_source.png", "child_drawing_loop1.png"],
  ["child_drawing_loop2_source.png", "child_drawing_loop2.png"],
  ["wedding_photo_loop1_source.png", "wedding_photo_loop1.png"],
  ["wedding_photo_loop2_source.png", "wedding_photo_loop2.png"],
  ["memory_tape_source.png", "memory_tape.png"],
];

for (const [input, output] of jobs) {
  await sharp(path.join(source, input))
    .resize(320, 180, { fit: "fill", kernel: sharp.kernel.nearest })
    .png({ palette: true, colors: 32, dither: 0, compressionLevel: 9 })
    .toFile(path.join(closeups, `${output}.next`));
  fs.renameSync(path.join(closeups, `${output}.next`), path.join(closeups, output));
}

console.log(`Processed ${jobs.length} generated masters into 320x180 limited-palette runtime art.`);

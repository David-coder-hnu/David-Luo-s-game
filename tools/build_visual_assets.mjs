import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const sourceDir = path.join(root, "assets/game/source");
fs.mkdirSync(sourceDir, { recursive: true });

const C = {
  ink: "#0B0C14",
  black: "#030407",
  wall: "#242936",
  teal: "#40525A",
  paper: "#C8BFAE",
  light: "#C29A5B",
  red: "#8D3035",
  ash: "#69656A",
  navy: "#151923",
  slate: "#303746",
  mist: "#52666C",
  paperShadow: "#9B9182",
  glow: "#DFC487",
  ember: "#5B2028",
  wood: "#3A3030",
  fabric: "#2F4652",
};

const rect = (x, y, w, h, fill, extra = "") => `<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${fill}" ${extra}/>`;
const line = (x1, y1, x2, y2, stroke, width = 1, extra = "") => `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="${width}" ${extra}/>`;
const poly = (points, fill, extra = "") => `<polygon points="${points}" fill="${fill}" ${extra}/>`;
const circle = (cx, cy, r, fill, extra = "") => `<circle cx="${cx}" cy="${cy}" r="${r}" fill="${fill}" ${extra}/>`;
const group = (body, extra = "") => `<g ${extra}>${body}</g>`;
const svg = (w, h, body, defs = "") => `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" shape-rendering="crispEdges">
${defs ? `<defs>${defs}</defs>` : ""}${body}
</svg>\n`;

function write(name, content) {
  fs.writeFileSync(path.join(sourceDir, name), content);
}

function woodTile(x, y, variant = 0) {
  let b = rect(x, y, 16, 16, C.wood);
  b += rect(x + 5, y, 1, 16, C.navy) + rect(x + 11, y, 1, 16, C.navy);
  b += rect(x + 6, y, 1, 16, C.slate) + rect(x + 12, y, 1, 16, C.slate);
  b += rect(x + 1, y + 3 + variant * 3, 4, 1, C.navy);
  b += rect(x + 7, y + 12 - variant * 2, 4, 1, C.navy);
  b += rect(x + 13, y + 5 + (variant % 2) * 5, 3, 1, C.navy);
  b += rect(x + 2 + variant, y + 1, 2, 1, C.slate) + rect(x + 8, y + 7 + (variant % 2) * 3, 2, 1, C.slate);
  if (variant === 2) b += rect(x + 2, y + 11, 1, 1, C.ash);
  return b;
}

function tileFloor(x, y, variant = 0) {
  let b = rect(x, y, 16, 16, C.ink);
  b += rect(x + 1, y + 1, 6, 6, variant % 2 ? C.wall : C.teal);
  b += rect(x + 9, y + 1, 6, 6, variant % 2 ? C.teal : C.wall);
  b += rect(x + 1, y + 9, 6, 6, variant % 2 ? C.teal : C.wall);
  b += rect(x + 9, y + 9, 6, 6, variant % 2 ? C.wall : C.teal);
  b += rect(x + 2, y + 2, 4, 1, C.ash, `opacity="0.45"`) + rect(x + 10, y + 10, 4, 1, C.ash, `opacity="0.35"`);
  if (variant === 2) b += line(x + 10, y + 9, x + 14, y + 13, C.ash) + rect(x + 13, y + 13, 2, 1, C.wall);
  if (variant === 3) b += rect(x + 3, y + 11, 2, 2, C.ash) + rect(x + 11, y + 3, 1, 2, C.ink);
  return b;
}

const envRegions = [];
let env = "";
for (let i = 0; i < 4; i++) {
  env += woodTile(i * 16, 0, i);
  envRegions.push({ id: `floor_wood_${i + 1}`, x: i * 16, y: 0, w: 16, h: 16 });
  env += tileFloor(64 + i * 16, 0, i);
  envRegions.push({ id: `floor_kitchen_${i + 1}`, x: 64 + i * 16, y: 0, w: 16, h: 16 });
}
env += rect(128, 0, 16, 16, C.ink) + rect(129, 1, 14, 14, C.red) + rect(131, 3, 10, 10, C.wall) + rect(132, 4, 8, 1, C.light) + rect(132, 11, 8, 1, C.ink);
env += rect(144, 0, 16, 16, C.ink) + rect(145, 1, 14, 14, C.ash) + rect(147, 3, 10, 10, C.wall) + rect(148, 4, 8, 1, C.teal) + rect(148, 11, 8, 1, C.ink);
envRegions.push({ id: "carpet_living", x: 128, y: 0, w: 16, h: 16 }, { id: "carpet_hall", x: 144, y: 0, w: 16, h: 16 });

for (let i = 0; i < 4; i++) {
  const x = i * 16;
  env += rect(x, 16, 16, 16, C.ink) + rect(x + 1, 16, 14, 12, C.wall);
  env += rect(x + 1, 16, 14, 2, C.teal) + rect(x + 1, 27, 14, 2, C.ash) + rect(x + 1, 29, 14, 3, C.wall);
  env += rect(x + 4 + (i % 2) * 5, 19, 1, 1, C.teal) + rect(x + 11 - (i % 2) * 6, 23, 1, 1, C.teal);
  if (i === 1) env += line(x + 6, 19, x + 9, 23, C.ash) + line(x + 9, 23, x + 7, 27, C.ash);
  if (i === 2) env += rect(x + 2, 20, 2, 1, C.ash) + rect(x + 12, 25, 2, 1, C.teal);
  if (i === 3) env += rect(x + 2, 19, 12, 1, C.ash) + rect(x + 2, 24, 12, 1, C.teal);
  envRegions.push({ id: `wall_cold_${i + 1}`, x, y: 16, w: 16, h: 16 });
}
env += rect(64, 16, 16, 16, C.ink) + rect(68, 16, 12, 16, C.wall) + rect(68, 16, 12, 2, C.teal) + rect(68, 27, 12, 2, C.ash) + rect(64, 16, 4, 16, C.teal) + rect(67, 18, 1, 10, C.ash);
env += rect(80, 16, 16, 16, C.ink) + rect(80, 16, 12, 16, C.wall) + rect(80, 16, 12, 2, C.teal) + rect(80, 27, 12, 2, C.ash) + rect(92, 16, 4, 16, C.teal) + rect(91, 18, 1, 10, C.ash);
envRegions.push({ id: "wall_corner_left", x: 64, y: 16, w: 16, h: 16 }, { id: "wall_corner_right", x: 80, y: 16, w: 16, h: 16 });

env += rect(96, 16, 16, 16, C.ink) + rect(100, 16, 12, 16, C.wall) + rect(100, 16, 3, 16, C.slate) + rect(103, 18, 1, 10, C.teal) + rect(103, 28, 9, 3, C.ash);
env += rect(112, 16, 16, 16, C.ink) + rect(112, 16, 12, 16, C.wall) + rect(121, 16, 3, 16, C.slate) + rect(120, 18, 1, 10, C.teal) + rect(112, 28, 9, 3, C.ash);
envRegions.push({ id: "wall_side_left", x: 96, y: 16, w: 16, h: 16 }, { id: "wall_side_right", x: 112, y: 16, w: 16, h: 16 });

for (let i = 0; i < 3; i++) {
  const x = i * 32;
  env += rect(x, 32, 32, 32, C.black) + rect(x + 2, 33, 28, 30, C.ink);
  env += rect(x + 4, 35, 24, 27, C.ash) + rect(x + 6, 37, 20, 25, i === 2 ? C.ink : C.wall);
  env += rect(x + 8, 39, 16, 7, i === 2 ? C.wall : C.teal) + rect(x + 9, 40, 14, 1, C.ash);
  env += rect(x + 8, 48, 16, 11, i === 2 ? C.wall : C.teal) + rect(x + 9, 49, 14, 1, C.ash);
  env += rect(x + 3, 61, 26, 2, C.teal) + circle(x + 22, 53, 1, i === 2 ? C.red : C.light);
  envRegions.push({ id: ["door_bedroom", "door_interior", "door_exit"][i], x, y: 32, w: 32, h: 32 });
}
env += rect(96, 32, 32, 32, C.black) + rect(98, 33, 28, 31, C.ink) + rect(101, 35, 22, 29, C.black) + rect(99, 33, 26, 3, C.ash) + rect(99, 36, 3, 26, C.teal) + rect(122, 36, 3, 26, C.teal) + rect(100, 62, 24, 2, C.wall);
envRegions.push({ id: "doorway_open", x: 96, y: 32, w: 32, h: 32 });

for (let i = 0; i < 6; i++) {
  const x = i * 16;
  env += rect(x, 64, 16, 16, "none");
  const severe = i >= 3;
  const phase = i % 3;
  env += poly(`${x},${68 + phase} ${x + 2},${66 + phase} ${x + 5},${67 - phase} ${x + 7},${65 + phase} ${x + 10},${68 - phase} ${x + 13},${66 + phase} ${x + 16},${69 + phase} ${x + 16},80 ${x},80`, severe ? C.red : C.ash, `opacity="${severe ? 0.72 : 0.5}"`);
  env += poly(`${x},${74 + phase} ${x + 4},${70 + phase} ${x + 8},${73 - phase} ${x + 11},${69 + phase} ${x + 14},${72 + phase} ${x + 16},${71 + phase} ${x + 16},80 ${x},80`, C.ink, `opacity="0.82"`);
  if (severe) env += rect(x + 2 + phase * 3, 76, 3, 1, C.light) + rect(x + 11 - phase * 2, 72, 2, 1, C.red);
  envRegions.push({ id: `${i < 3 ? "scorch_v1" : "scorch_v3"}_${(i % 3) + 1}`, x, y: 64, w: 16, h: 16 });
}

env += rect(0, 80, 64, 16, C.ink) + rect(0, 80, 64, 3, C.ash) + rect(3, 83, 58, 11, C.wall) + rect(4, 84, 56, 2, C.teal) + rect(4, 93, 56, 2, C.black);
env += rect(64, 80, 64, 16, C.black) + rect(67, 81, 58, 14, C.wall) + rect(68, 82, 56, 3, C.ash) + rect(69, 86, 54, 8, C.ink) + rect(72, 88, 48, 1, C.teal);
envRegions.push({ id: "front_wall", x: 0, y: 80, w: 64, h: 16 }, { id: "cabinet_top", x: 64, y: 80, w: 64, h: 16 });
write("environment_tiles.svg", svg(256, 128, env));

let envDetails = "";
for (let i = 0; i < 4; i++) {
  const x = i * 32;
  envDetails += rect(x + 5 + i * 3, 6, 5, 1, C.ash, `opacity="0.45"`) + rect(x + 20 - i * 2, 17, 7, 1, C.teal, `opacity="0.55"`) + rect(x + 10 + i, 27, 3, 1, C.ash, `opacity="0.35"`);
  const tileX = 128 + i * 32;
  envDetails += rect(tileX + 5, 5, 6, 1, C.paper, `opacity="0.18"`) + rect(tileX + 20, 20, 4, 1, C.ash, `opacity="0.32"`);
  const wallX = i * 32;
  envDetails += rect(wallX + 7 + i * 4, 39, 2, 1, C.ash, `opacity="0.4"`) + rect(wallX + 22 - i * 2, 49, 3, 1, C.teal, `opacity="0.38"`);
}
for (let i = 0; i < 3; i++) {
  const x = i * 64;
  envDetails += rect(x + 17, 82, 27, 1, C.ash, `opacity="0.5"`) + rect(x + 18, 96, 25, 1, C.teal, `opacity="0.42"`) + rect(x + 20, 110, 18, 1, C.ash, `opacity="0.35"`);
}
for (let i = 0; i < 6; i++) {
  const x = i * 32;
  envDetails += rect(x + 4 + (i % 3) * 7, 147, 5, 1, i < 3 ? C.ash : C.red, `opacity="0.5"`) + rect(x + 20 - (i % 2) * 8, 153, 2, 1, i < 3 ? C.wall : C.light, `opacity="0.55"`);
}
write("environment_details.svg", svg(512, 256, envDetails));

const props = [];
let p = "";
function addProp(id, x, y, w, h, body) {
  p += group(body, `data-id="${id}"`);
  props.push({ id, x, y, w, h });
}

function bed(x, y, child = false, pressed = false) {
  let b = rect(x + 2, y + 5, 44, 25, C.black) + rect(x + 3, y + 3, 42, 25, C.ink);
  b += rect(x + 4, y + 3, 40, 4, C.ash) + rect(x + 5, y + 7, 38, 20, C.wall);
  b += rect(x + 6, y + 8, 36, 6, child ? C.paperShadow : C.ash);
  b += rect(x + 7, y + 9, 12, 4, child ? C.glow : C.paper) + rect(x + 20, y + 9, 1, 4, C.mist);
  b += rect(x + 6, y + 15, 36, 11, child ? C.mist : C.fabric) + rect(x + 7, y + 16, 34, 2, child ? C.fabric : C.mist);
  b += line(x + 9, y + 20, x + 38, y + 20, child ? C.glow : C.ash);
  b += rect(x + 3, y + 28, 4, 3, C.ink) + rect(x + 41, y + 28, 4, 3, C.ink);
  if (child) b += rect(x + 31, y + 22, 3, 2, C.light) + rect(x + 34, y + 23, 2, 1, C.paper);
  if (pressed) b += poly(`${x + 23},${y + 17} ${x + 29},${y + 15} ${x + 36},${y + 18} ${x + 34},${y + 23} ${x + 25},${y + 23}`, C.ink, `opacity="0.7"`);
  return b;
}
addProp("bed_loop1", 0, 0, 48, 32, bed(0, 0));
addProp("bed_loop2", 48, 0, 48, 32, bed(48, 0, false, true));
addProp("bedside_table", 96, 0, 16, 16, rect(98, 3, 12, 12, C.ink) + rect(99, 2, 10, 3, C.ash) + rect(100, 6, 8, 3, C.wall) + rect(100, 10, 8, 4, C.wall) + circle(106, 7, 1, C.light) + rect(99, 15, 2, 1, C.black) + rect(107, 15, 2, 1, C.black));
addProp("wardrobe_closed", 112, 0, 32, 32, rect(114, 2, 28, 30, C.black) + rect(116, 1, 24, 29, C.ink) + rect(118, 3, 20, 26, C.wall) + rect(119, 4, 8, 23, C.teal) + rect(129, 4, 8, 23, C.teal) + rect(120, 5, 6, 2, C.ash) + rect(130, 5, 6, 2, C.ash) + circle(125, 16, 1, C.light) + circle(131, 16, 1, C.light));
addProp("wardrobe_open", 144, 0, 32, 32, rect(146, 2, 28, 30, C.black) + rect(148, 1, 24, 29, C.ink) + rect(150, 4, 9, 24, C.black) + rect(151, 6, 7, 1, C.ash) + line(154, 7, 154, 23, C.teal) + poly("161,3 172,6 172,28 161,29", C.teal) + poly("163,5 170,7 170,26 163,27", C.wall) + circle(164, 16, 1, C.light));

let counter = rect(176, 5, 96, 27, C.black) + rect(178, 4, 92, 26, C.ink) + rect(178, 4, 92, 5, C.ash) + rect(179, 5, 90, 2, C.paper, `opacity="0.4"`);
for (let i = 0; i < 5; i++) {
  counter += rect(180 + i * 18, 12, 15, 16, C.wall) + rect(181 + i * 18, 13, 13, 2, C.teal);
  counter += rect(182 + i * 18, 17, 11, 9, C.teal) + circle(191 + i * 18, 20, 1, C.light);
}
counter += rect(212, 5, 26, 10, C.ink) + rect(215, 7, 20, 6, C.teal) + rect(217, 8, 16, 3, C.black) + line(225, 6, 225, 2, C.ash) + line(225, 2, 229, 2, C.ash) + line(229, 2, 229, 6, C.ash);
counter += rect(247, 5, 18, 3, C.wall) + circle(251, 6, 1, C.light) + circle(260, 6, 1, C.light);
addProp("kitchen_counter", 176, 0, 96, 32, counter);

addProp("glass_single", 272, 0, 16, 16, rect(277, 4, 6, 9, C.ink) + rect(278, 5, 4, 7, C.teal) + rect(279, 6, 2, 1, C.paper) + rect(276, 13, 8, 1, C.ash));
addProp("glass_double", 288, 0, 16, 16, rect(290, 5, 5, 8, C.ink) + rect(291, 6, 3, 6, C.teal) + rect(297, 4, 5, 9, C.ink) + rect(298, 5, 3, 7, C.teal) + rect(289, 13, 14, 1, C.ash) + rect(299, 5, 1, 1, C.paper));
addProp("kitchen_stain", 304, 0, 32, 16, poly("306,11 309,7 314,6 318,3 322,6 327,5 333,9 334,12 329,14 321,13 316,15 310,13", C.ash, `opacity="0.5"`) + rect(318, 8, 3, 2, C.wall));
addProp("receipt_world", 336, 0, 16, 16, poly("339,3 350,2 349,14 338,13", C.paper) + rect(340, 5, 8, 1, C.ash) + rect(340, 8, 6, 1, C.red) + rect(339, 12, 2, 1, C.ink) + rect(347, 11, 2, 2, C.ink));

addProp("child_bed_loop1", 0, 32, 48, 32, bed(0, 32, true));
addProp("child_bed_loop2", 48, 32, 48, 32, bed(48, 32, true, false) + rect(55, 50, 34, 1, C.paper));
addProp("height_marks", 96, 32, 16, 32, rect(102, 34, 2, 28, C.ash) + [0, 1, 2, 3, 4].map((i) => line(104, 39 + i * 5, 108 + (i % 2) * 2, 39 + i * 5, C.paper)).join("") + rect(106, 51, 3, 1, C.light));
addProp("music_box", 112, 32, 16, 16, rect(114, 39, 12, 8, C.ink) + rect(115, 40, 10, 6, C.teal) + rect(116, 37, 8, 3, C.wall) + rect(117, 38, 6, 1, C.ash) + circle(120, 43, 2, C.light) + circle(120, 43, 1, C.red));
addProp("drawing_hidden", 128, 32, 16, 16, rect(130, 42, 12, 4, C.paper) + rect(133, 41, 9, 1, C.red));
addProp("drawing_revealed", 144, 32, 16, 16, rect(146, 34, 12, 12, C.paper) + poly("148,42 151,38 154,42", C.light) + rect(153, 38, 2, 6, C.ink));

let sofa = rect(2, 71, 44, 23, C.black) + rect(4, 67, 40, 22, C.ink) + rect(6, 69, 36, 17, C.navy);
sofa += rect(7, 70, 16, 13, C.fabric) + rect(25, 70, 16, 13, C.fabric) + rect(8, 71, 14, 2, C.mist) + rect(26, 71, 14, 2, C.mist);
sofa += rect(3, 74, 5, 15, C.wall) + rect(40, 74, 5, 15, C.wall) + rect(4, 89, 4, 4, C.ink) + rect(40, 89, 4, 4, C.ink);
sofa += rect(23, 72, 2, 11, C.ink) + rect(10, 81, 9, 1, C.wall) + rect(29, 80, 8, 1, C.wall);
addProp("sofa", 0, 64, 48, 32, sofa);
let table = rect(55, 76, 34, 22, C.black) + rect(53, 72, 38, 24, C.ink) + rect(55, 73, 34, 20, C.wall) + rect(56, 74, 32, 2, C.ash);
table += rect(58, 77, 10, 1, C.teal) + rect(76, 88, 9, 1, C.teal) + rect(57, 94, 4, 14, C.ink) + rect(84, 94, 4, 14, C.ink);
table += rect(65, 65, 14, 6, C.ink) + rect(67, 66, 10, 4, C.teal) + rect(49, 80, 6, 14, C.ink) + rect(50, 82, 4, 10, C.teal) + rect(90, 80, 6, 14, C.ink) + rect(91, 82, 4, 10, C.teal);
table += circle(63, 82, 4, C.paper) + circle(73, 84, 4, C.paper) + circle(83, 81, 4, C.paper) + circle(63, 82, 2, C.wall) + circle(73, 84, 2, C.wall) + circle(83, 81, 2, C.wall);
addProp("family_table", 48, 64, 48, 48, table);
addProp("wedding_photo_loop1", 96, 64, 16, 16, rect(97, 65, 14, 14, C.ink) + rect(98, 66, 12, 12, C.ash) + rect(100, 68, 8, 8, C.paper) + rect(100, 69, 3, 7, C.light) + rect(104, 68, 4, 8, C.ink) + rect(105, 68, 3, 2, C.black));
addProp("wedding_photo_loop2", 112, 64, 16, 16, rect(113, 65, 14, 14, C.ink) + rect(114, 66, 12, 12, C.ash) + rect(116, 68, 8, 8, C.paper) + rect(116, 69, 3, 7, C.light) + rect(120, 68, 4, 8, C.wall) + rect(121, 68, 2, 2, C.ink));

let clock = circle(136, 80, 13, C.black) + circle(136, 80, 11, C.ash) + circle(136, 80, 9, C.paper) + rect(135, 71, 2, 2, C.ink) + rect(135, 87, 2, 2, C.ink) + rect(127, 79, 2, 2, C.ink) + rect(143, 79, 2, 2, C.ink) + line(136, 80, 136, 73, C.ink) + line(136, 80, 142, 83, C.red) + circle(136, 80, 1, C.ink);
addProp("living_clock", 128, 64, 16, 32, clock);
addProp("compartment_closed", 144, 64, 32, 32, rect(146, 66, 28, 28, C.ink) + rect(148, 68, 24, 24, C.wall) + rect(150, 70, 20, 20, C.teal) + rect(151, 71, 18, 18, C.wall) + rect(159, 80, 2, 2, C.ash));
addProp("compartment_open", 176, 64, 32, 32, rect(178, 66, 28, 28, C.ink) + rect(180, 68, 24, 24, C.wall) + rect(182, 70, 20, 20, C.black) + poly("180,68 204,65 206,72 182,76", C.teal) + rect(184, 74, 16, 2, C.ash));
addProp("memory_tape", 208, 64, 16, 16, rect(210, 68, 12, 8, C.ash) + circle(213, 72, 2, C.ink) + circle(219, 72, 2, C.ink) + rect(214, 74, 4, 1, C.paper));
addProp("hall_light_on", 224, 64, 16, 16, line(232, 65, 232, 69, C.ash) + poly("227,69 237,69 239,75 225,75", C.light) + rect(229, 75, 6, 2, C.paper));
addProp("hall_light_off", 240, 64, 16, 16, line(248, 65, 248, 69, C.ash) + poly("243,69 253,69 255,75 241,75", C.wall));

let door = rect(258, 66, 28, 46, C.black) + rect(260, 67, 24, 44, C.ink) + rect(262, 69, 20, 40, C.wall) + rect(264, 72, 16, 12, C.teal) + rect(265, 73, 14, 2, C.ash) + rect(264, 87, 16, 18, C.teal) + rect(265, 88, 14, 2, C.ash) + circle(278, 94, 1, C.red) + rect(260, 109, 24, 3, C.teal);
addProp("exit_door", 256, 64, 32, 48, door);

let rug = rect(290, 66, 60, 28, C.ink) + rect(292, 68, 56, 24, C.ash) + rect(294, 70, 52, 20, C.fabric) + rect(297, 73, 46, 14, C.wall);
rug += rect(300, 76, 40, 1, C.mist) + rect(300, 84, 40, 1, C.mist) + poly("310,80 316,75 322,80 316,85", C.ash) + poly("326,80 332,75 338,80 332,85", C.ash);
addProp("bedroom_rug", 288, 64, 64, 32, rug);

let lamp = rect(355, 76, 10, 3, C.ink) + rect(358, 70, 4, 7, C.ash) + poly("353,68 367,68 364,61 356,61", C.light) + rect(357, 62, 6, 2, C.glow);
addProp("bedroom_lamp", 352, 64, 16, 16, lamp);

let bedroomWindow = rect(370, 66, 44, 28, C.ink) + rect(372, 68, 40, 24, C.ash) + rect(375, 71, 34, 18, C.black);
bedroomWindow += rect(391, 71, 2, 18, C.slate) + rect(375, 79, 34, 2, C.slate) + rect(374, 69, 3, 22, C.fabric) + rect(407, 69, 3, 22, C.fabric) + rect(376, 72, 5, 1, C.teal);
addProp("bedroom_window", 368, 64, 48, 32, bedroomWindow);

const small = [
  ["sock", poly("2,132 8,132 8,138 12,138 12,142 4,142 4,137 2,137", C.teal)],
  ["medicine_box", rect(18, 130, 12, 12, C.paper) + rect(22, 132, 4, 8, C.red) + rect(20, 135, 8, 2, C.red)],
  ["envelope", rect(34, 132, 14, 9, C.paper) + poly("34,132 41,137 48,132", C.ash)],
  ["phone", rect(52, 130, 12, 14, C.wall) + rect(54, 132, 8, 8, C.ink) + circle(58, 142, 1, C.light)],
  ["calendar", rect(68, 129, 14, 15, C.paper) + rect(68, 129, 14, 4, C.red) + line(71, 136, 79, 141, C.ash)],
  ["letter", rect(86, 130, 12, 14, C.paper) + rect(88, 133, 8, 1, C.ash) + rect(88, 136, 6, 1, C.ash)],
  ["shirt_patch", rect(102, 130, 12, 14, C.teal) + rect(105, 135, 5, 5, C.ash)],
  ["shopping_list", rect(118, 129, 12, 15, C.paper) + rect(120, 132, 7, 1, C.ash) + rect(120, 136, 8, 1, C.ash) + rect(120, 140, 5, 1, C.red)],
  ["school_form", rect(134, 129, 13, 15, C.paper) + rect(136, 132, 9, 2, C.teal) + rect(136, 136, 7, 1, C.ash)],
  ["door_chain", line(152, 132, 161, 141, C.ash, 2) + circle(153, 132, 2, C.wall) + circle(162, 142, 2, C.wall)],
  ["plates_three", circle(174, 137, 4, C.paper) + circle(183, 137, 4, C.paper) + circle(192, 137, 4, C.paper)],
  ["album_empty", rect(202, 129, 14, 15, C.wall) + rect(204, 131, 10, 11, C.paper) + rect(208, 133, 2, 7, C.ash)],
];
small.forEach(([id, body], i) => addProp(id, i * 18, 128, 16, 16, body));

write("props_atlas.svg", svg(512, 256, p));

let propDetails = "";
const propScratch = (x, y, w, color = C.ash) => rect(x, y, w, 1, color, `opacity="0.42"`);
propDetails += propScratch(17, 23, 24) + propScratch(113, 18, 12, C.paper) + propScratch(245, 18, 22) + propScratch(396, 13, 48, C.paper);
propDetails += propScratch(18, 86, 30, C.light) + propScratch(112, 91, 34, C.paper) + propScratch(212, 86, 11, C.light);
propDetails += propScratch(17, 159, 50) + propScratch(119, 156, 36, C.paper) + propScratch(202, 168, 26, C.teal);
propDetails += rect(257, 152, 2, 2, C.paper) + rect(271, 166, 2, 2, C.red) + rect(465, 151, 2, 3, C.light);
write("props_details.svg", svg(1024, 512, propDetails));

function person(frameX, frameY, direction, step) {
  const x = frameX * 16;
  const y = frameY * 24;
  const phase = [0, -1, 0, 1][step];
  const bob = step === 0 || step === 2 ? 0 : 1;
  let b = "";

  if (direction === 0) {
    b += rect(x + 5, y + 1 + bob, 7, 2, C.ink) + rect(x + 4, y + 3 + bob, 8, 4, C.ink);
    b += rect(x + 6, y + 3 + bob, 5, 4, C.paper) + rect(x + 9, y + 5 + bob, 1, 1, C.ash);
    b += rect(x + 4, y + 7 + bob, 8, 10, C.fabric) + rect(x + 5, y + 8 + bob, 2, 7, C.light) + rect(x + 7, y + 8 + bob, 4, 2, C.mist);
    b += rect(x + 2, y + 9 + bob + Math.max(phase, 0), 2, 7, C.mist) + rect(x + 12, y + 9 + bob + Math.max(-phase, 0), 2, 7, C.fabric);
    b += rect(x + 5 + Math.max(phase, 0), y + 17, 3, 6, C.ink) + rect(x + 9 + Math.min(phase, 0), y + 17, 3, 6, C.ink);
  } else if (direction === 1) {
    b += rect(x + 5, y + 1 + bob, 7, 6, C.ink) + rect(x + 6, y + 2 + bob, 5, 1, C.teal);
    b += rect(x + 4, y + 7 + bob, 8, 10, C.fabric) + rect(x + 5, y + 8 + bob, 6, 2, C.mist) + rect(x + 10, y + 9 + bob, 1, 7, C.light);
    b += rect(x + 2, y + 9 + bob + Math.max(-phase, 0), 2, 7, C.fabric) + rect(x + 12, y + 9 + bob + Math.max(phase, 0), 2, 7, C.mist);
    b += rect(x + 5 + Math.max(-phase, 0), y + 17, 3, 6, C.ink) + rect(x + 9 + Math.min(-phase, 0), y + 17, 3, 6, C.ink);
  } else {
    const right = direction === 3;
    const faceX = right ? x + 7 : x + 4;
    b += rect(faceX, y + 1 + bob, 6, 2, C.ink) + rect(faceX, y + 3 + bob, 7, 4, C.ink);
    b += rect(right ? x + 9 : x + 5, y + 3 + bob, 3, 4, C.paper) + rect(right ? x + 11 : x + 5, y + 5 + bob, 1, 1, C.ash);
    b += rect(x + 5, y + 7 + bob, 7, 10, C.fabric) + rect(right ? x + 6 : x + 10, y + 8 + bob, 1, 7, C.light);
    b += rect(right ? x + 11 : x + 3, y + 9 + bob - phase, 2, 7, C.mist) + rect(right ? x + 4 : x + 12, y + 10 + bob + phase, 2, 6, C.fabric);
    b += rect(x + 5 + Math.max(phase, 0), y + 17, 3, 6, C.ink) + rect(x + 9 + Math.min(phase, 0), y + 17, 3, 6, C.ink);
  }
  b += rect(x + 4 + Math.max(phase, 0), y + 22, 4, 2, C.black) + rect(x + 9 + Math.min(phase, 0), y + 22, 4, 2, C.black);
  return b;
}
let character = "";
for (let dir = 0; dir < 4; dir++) for (let frame = 0; frame < 4; frame++) character += person(frame, dir, dir, frame);
write("qin_zheng_spritesheet.svg", svg(64, 96, character));

let characterDetails = "";
for (let dir = 0; dir < 4; dir++) {
  for (let frame = 0; frame < 4; frame++) {
    const x = frame * 32;
    const y = dir * 48;
    characterDetails += rect(x + 12, y + 7, 1, 1, dir === 1 ? C.teal : C.ash);
    characterDetails += rect(x + 11, y + 21, 1, 5, C.ash, `opacity="0.65"`) + rect(x + 19, y + 22, 1, 4, C.teal, `opacity="0.65"`);
    characterDetails += rect(x + 9 + (frame % 2), y + 45, 5, 1, C.teal, `opacity="0.5"`) + rect(x + 19 - (frame % 2), y + 45, 5, 1, C.teal, `opacity="0.5"`);
  }
}
write("qin_zheng_details.svg", svg(128, 192, characterDetails));

let ui = "";
ui += rect(0, 0, 128, 48, C.black, `opacity="0.96"`) + rect(1, 1, 126, 46, C.teal) + rect(2, 2, 124, 44, C.ink) + rect(5, 5, 118, 38, C.wall, `opacity="0.35"`);
ui += rect(1, 1, 5, 1, C.ash) + rect(1, 1, 1, 5, C.ash) + rect(122, 46, 5, 1, C.ash) + rect(126, 42, 1, 5, C.ash);
const keycap = (x, w, label, fontSize) => rect(x, 4, w, 16, C.black) + rect(x + 1, 3, w - 2, 15, C.ash) + rect(x + 2, 4, w - 4, 12, C.ink) + rect(x + 3, 5, w - 6, 1, C.wall) + `<text x="${x + w / 2}" y="14" fill="${C.paper}" font-size="${fontSize}" text-anchor="middle" font-family="monospace">${label}</text>`;
ui += keycap(136, 20, "E", 10) + keycap(160, 38, "ENTER", 8) + keycap(202, 30, "ESC", 8);
ui += poly("140,30 146,24 152,30 146,36", C.light) + rect(145, 26, 2, 2, C.paper) + poly("160,30 166,24 172,30 166,36", C.red) + rect(165, 27, 2, 2, C.light);
ui += circle(205, 31, 13, C.black) + circle(205, 31, 11, "none", `stroke="${C.ash}" stroke-width="1"`) + `<path d="M205 20 A11 11 0 0 1 216 31" fill="none" stroke="${C.red}" stroke-width="2"/>` + rect(204, 19, 2, 2, C.paper);
ui += poly("232,20 244,20 248,25 248,37 244,42 232,42 228,37 228,25", C.ink) + poly("233,22 243,22 246,26 246,36 243,40 233,40 230,36 230,26", C.wall) + rect(235, 24, 6, 10, C.red) + rect(237, 36, 2, 2, C.paper);
ui += rect(0, 56, 160, 56, C.black) + rect(1, 57, 158, 54, C.teal) + rect(3, 59, 154, 50, C.ink) + rect(8, 65, 144, 38, C.wall, `opacity="0.25"`) + `<text x="80" y="92" fill="${C.paper}" font-size="24" text-anchor="middle" font-family="monospace">02 : 17</text>` + rect(49, 98, 62, 1, C.red);
ui += rect(168, 56, 80, 24, C.black) + rect(169, 57, 78, 22, C.teal) + rect(171, 59, 74, 18, C.ink) + `<text x="208" y="72" fill="${C.paper}" font-size="9" text-anchor="middle" font-family="sans-serif">降低闪烁</text>`;
write("ui_atlas.svg", svg(256, 128, ui));

const wordmarkDefs = `<linearGradient id="ember" x1="0" x2="1"><stop stop-color="${C.paper}"/><stop offset="0.7" stop-color="${C.light}"/><stop offset="1" stop-color="${C.red}"/></linearGradient>`;
const wordmark = `<rect width="640" height="180" fill="${C.ink}"/><text x="320" y="88" fill="url(#ember)" font-family="PingFang SC, Heiti SC, sans-serif" font-size="58" font-weight="700" text-anchor="middle" letter-spacing="10">地狱轮回</text><text x="320" y="128" fill="${C.ash}" font-family="Georgia, serif" font-size="18" text-anchor="middle" letter-spacing="9">HELL CYCLE</text><path d="M176 146 H464" stroke="${C.wall}"/><path d="M278 146 H362" stroke="${C.red}"/>`;
write("wordmark.svg", svg(640, 180, wordmark, wordmarkDefs));

const fxDefs = "";
let vignette = "";
for (let i = 0; i < 8; i++) {
  const inset = i * 4;
  const alpha = (0.78 - i * 0.075).toFixed(2);
  vignette += rect(inset, inset, 256 - inset * 2, 4, C.black, `opacity="${alpha}"`);
  vignette += rect(inset, 124 - inset, 256 - inset * 2, 4, C.black, `opacity="${alpha}"`);
  vignette += rect(inset, inset + 4, 4, 120 - inset * 2, C.black, `opacity="${alpha}"`);
  vignette += rect(252 - inset, inset + 4, 4, 120 - inset * 2, C.black, `opacity="${alpha}"`);
}
let emberNoise = rect(0, 128, 256, 128, C.black, `opacity="0.18"`);
const burnTop = [18, 16, 20, 14, 22, 17, 25, 15, 19, 13, 23, 18, 26, 16, 21, 14, 24, 17, 20, 15, 27, 18, 23, 16, 20, 14, 22, 17, 25, 19, 23, 15];
for (let i = 0; i < burnTop.length; i++) {
  const x = i * 8;
  const h = burnTop[i];
  emberNoise += rect(x, 128, 8, h, C.ink, `opacity="0.94"`);
  if (i % 3 === 0) emberNoise += rect(x + 2, 128 + h - 2, 3, 1, C.red, `opacity="0.65"`);
  if (i % 7 === 0) emberNoise += rect(x + 4, 128 + h + 2, 2, 2, C.light, `opacity="0.52"`);
}
const sideY = [154, 167, 181, 196, 212, 229, 243];
for (const [index, y] of sideY.entries()) {
  const depth = 12 + (index % 3) * 5;
  emberNoise += poly(`0,${y - 7} ${depth},${y - 3} ${depth + 5},${y} ${depth - 2},${y + 5} 0,${y + 8}`, C.ink, `opacity="0.9"`);
  emberNoise += poly(`256,${y - 8} ${256 - depth},${y - 4} ${251 - depth},${y + 1} ${258 - depth},${y + 5} 256,${y + 8}`, C.ink, `opacity="0.9"`);
  emberNoise += rect(3 + index, y, 3, 1, C.red, `opacity="0.6"`) + rect(248 - index, y - 2, 3, 1, C.red, `opacity="0.6"`);
}
emberNoise += rect(24, 236, 208, 20, C.ink, `opacity="0.92"`) + rect(42, 231, 172, 8, C.ink, `opacity="0.76"`) + rect(74, 229, 4, 1, C.light, `opacity="0.5"`) + rect(181, 234, 6, 1, C.red, `opacity="0.6"`);
const fx = vignette + emberNoise;
write("fx_patterns.svg", svg(256, 256, fx, fxDefs));

const scale2 = (region) => ({ id: region.id, x: region.x * 2, y: region.y * 2, w: region.w * 2, h: region.h * 2 });
const regions = {
  version: 2,
  palette: C,
  atlases: {
    environment_tiles: { size: [512, 256], cell: [32, 32], regions: envRegions.map(scale2) },
    props_atlas: { size: [1024, 512], regions: props.map(scale2) },
    qin_zheng_spritesheet: {
      size: [128, 192],
      frame: [32, 48],
      rows: ["down", "up", "left", "right"],
      columns: ["idle", "step_a", "idle_b", "step_b"],
    },
    ui_atlas: {
      size: [256, 128],
      regions: [
        { id: "dialogue_box", x: 0, y: 0, w: 128, h: 48 },
        { id: "key_e", x: 136, y: 4, w: 20, h: 16 },
        { id: "key_enter", x: 160, y: 4, w: 38, h: 16 },
        { id: "key_esc", x: 202, y: 4, w: 30, h: 16 },
        { id: "focus_diamond", x: 140, y: 24, w: 12, h: 12 },
        { id: "danger_diamond", x: 160, y: 24, w: 12, h: 12 },
        { id: "hold_ring", x: 192, y: 18, w: 26, h: 26 },
        { id: "content_warning", x: 228, y: 20, w: 20, h: 22 },
        { id: "clock_panel", x: 0, y: 56, w: 160, h: 56 },
      ],
    },
    fx_patterns: {
      size: [256, 256],
      regions: [
        { id: "vignette", x: 0, y: 0, w: 256, h: 128 },
        { id: "ember_noise", x: 0, y: 128, w: 256, h: 128 },
      ],
    },
  },
};
fs.writeFileSync(path.join(sourceDir, "atlas_regions.json"), `${JSON.stringify(regions, null, 2)}\n`);

console.log(`Wrote deterministic visual sources to ${sourceDir}`);

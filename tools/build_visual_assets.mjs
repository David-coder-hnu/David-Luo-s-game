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
  let b = rect(x, y, 16, 16, C.wall);
  b += line(x, y + 5, x + 16, y + 5, C.ink);
  b += line(x, y + 11, x + 16, y + 11, C.ink);
  b += line(x + 7 + variant, y, x + 7 + variant, y + 5, C.teal);
  b += line(x + 3 + variant, y + 6, x + 3 + variant, y + 11, C.teal);
  b += line(x + 11 - variant, y + 12, x + 11 - variant, y + 16, C.teal);
  return b;
}

function tileFloor(x, y, variant = 0) {
  let b = rect(x, y, 16, 16, C.teal);
  b += line(x + 8, y, x + 8, y + 16, C.wall);
  b += line(x, y + 8, x + 16, y + 8, C.wall);
  if (variant % 2) b += rect(x + 2, y + 2, 2, 1, C.ash);
  if (variant > 1) b += line(x + 10, y + 9, x + 14, y + 13, C.wall);
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
env += rect(128, 0, 16, 16, C.red) + rect(130, 2, 12, 12, C.wall) + line(130, 8, 142, 8, C.ash);
env += rect(144, 0, 16, 16, C.ash) + rect(146, 2, 12, 12, C.wall);
envRegions.push({ id: "carpet_living", x: 128, y: 0, w: 16, h: 16 }, { id: "carpet_hall", x: 144, y: 0, w: 16, h: 16 });

for (let i = 0; i < 4; i++) {
  const x = i * 16;
  env += rect(x, 16, 16, 16, C.wall) + rect(x, 16, 16, 3, C.teal) + rect(x, 29, 16, 3, C.ink);
  if (i === 1) env += line(x + 5, 19, x + 9, 24, C.ash) + line(x + 9, 24, x + 7, 28, C.ash);
  if (i === 2) env += rect(x + 2, 20, 2, 2, C.ash) + rect(x + 11, 24, 2, 1, C.teal);
  if (i === 3) env += rect(x + 1, 18, 14, 1, C.ash) + rect(x + 1, 25, 14, 1, C.ash);
  envRegions.push({ id: `wall_cold_${i + 1}`, x, y: 16, w: 16, h: 16 });
}
env += rect(64, 16, 16, 16, C.wall) + rect(64, 16, 4, 16, C.teal) + rect(68, 16, 12, 3, C.ash);
env += rect(80, 16, 16, 16, C.wall) + rect(92, 16, 4, 16, C.teal) + rect(80, 16, 12, 3, C.ash);
envRegions.push({ id: "wall_corner_left", x: 64, y: 16, w: 16, h: 16 }, { id: "wall_corner_right", x: 80, y: 16, w: 16, h: 16 });

for (let i = 0; i < 3; i++) {
  const x = i * 32;
  env += rect(x, 32, 32, 32, C.ink) + rect(x + 3, 34, 26, 28, C.wall) + rect(x + 6, 37, 20, 24, i === 2 ? C.ink : C.teal);
  env += rect(x + 8, 39, 16, 2, C.ash) + rect(x + 8, 44, 16, 1, C.ash) + circle(x + 23, 49, 1, i === 2 ? C.red : C.light);
  envRegions.push({ id: ["door_bedroom", "door_interior", "door_exit"][i], x, y: 32, w: 32, h: 32 });
}
env += rect(96, 32, 32, 32, "none", `stroke="${C.teal}" stroke-width="3"`) + rect(101, 32, 22, 4, C.ash);
envRegions.push({ id: "doorway_open", x: 96, y: 32, w: 32, h: 32 });

for (let i = 0; i < 6; i++) {
  const x = i * 16;
  env += rect(x, 64, 16, 16, "none");
  env += poly(`${x},${64 + (i % 3) * 3} ${x + 5},68 ${x + 8},65 ${x + 12},72 ${x + 16},${64 + ((i + 1) % 3) * 3}`, i < 3 ? C.ash : C.red, `opacity="${i < 3 ? 0.65 : 0.75}"`);
  env += rect(x + (i * 3) % 11, 75, 4, 2, C.ink);
  envRegions.push({ id: `${i < 3 ? "scorch_v1" : "scorch_v3"}_${(i % 3) + 1}`, x, y: 64, w: 16, h: 16 });
}

env += rect(0, 80, 64, 16, C.wall) + rect(0, 80, 64, 4, C.teal) + rect(4, 85, 56, 9, C.ink);
env += rect(64, 80, 64, 16, C.ink) + rect(68, 82, 56, 12, C.wall);
envRegions.push({ id: "front_wall", x: 0, y: 80, w: 64, h: 16 }, { id: "cabinet_top", x: 64, y: 80, w: 64, h: 16 });
write("environment_tiles.svg", svg(256, 128, env));

const props = [];
let p = "";
function addProp(id, x, y, w, h, body) {
  p += group(body, `data-id="${id}"`);
  props.push({ id, x, y, w, h });
}

function bed(x, y, child = false, pressed = false) {
  let b = rect(x + 2, y + 5, 44, 25, C.ink) + rect(x + 4, y + 3, 40, 25, C.wall);
  b += rect(x + 6, y + 5, 36, 7, child ? C.teal : C.ash) + rect(x + 6, y + 13, 36, 13, child ? C.wall : C.teal);
  b += rect(x + 7, y + 6, 12, 5, C.paper);
  if (pressed) b += rect(x + 24, y + 15, 11, 4, C.ink, `opacity="0.55"`);
  b += rect(x + 3, y + 28, 3, 3, C.ink) + rect(x + 42, y + 28, 3, 3, C.ink);
  return b;
}
addProp("bed_loop1", 0, 0, 48, 32, bed(0, 0));
addProp("bed_loop2", 48, 0, 48, 32, bed(48, 0, false, true));
addProp("bedside_table", 96, 0, 16, 16, rect(98, 3, 12, 12, C.wall) + rect(99, 4, 10, 3, C.teal) + circle(106, 9, 1, C.light));
addProp("wardrobe_closed", 112, 0, 32, 32, rect(114, 1, 28, 30, C.ink) + rect(116, 2, 24, 28, C.wall) + line(128, 3, 128, 29, C.teal) + circle(125, 16, 1, C.light) + circle(131, 16, 1, C.light));
addProp("wardrobe_open", 144, 0, 32, 32, rect(146, 1, 28, 30, C.ink) + rect(148, 3, 10, 26, C.wall) + poly("160,3 172,6 172,28 160,29", C.teal) + rect(150, 6, 5, 18, C.black));

let counter = rect(176, 4, 96, 28, C.ink) + rect(178, 6, 92, 24, C.wall) + rect(178, 6, 92, 4, C.ash);
for (let i = 0; i < 5; i++) counter += rect(180 + i * 18, 14, 15, 14, C.teal) + circle(191 + i * 18, 19, 1, C.light);
counter += rect(213, 7, 24, 8, C.ink) + rect(216, 8, 18, 5, C.teal) + line(225, 7, 225, 3, C.ash);
addProp("kitchen_counter", 176, 0, 96, 32, counter);

addProp("glass_single", 272, 0, 16, 16, rect(277, 4, 6, 9, C.teal) + rect(278, 5, 4, 2, C.paper) + rect(276, 13, 8, 1, C.ash));
addProp("glass_double", 288, 0, 16, 16, rect(290, 5, 5, 8, C.teal) + rect(297, 4, 5, 9, C.teal) + rect(289, 13, 14, 1, C.ash));
addProp("kitchen_stain", 304, 0, 32, 16, poly("306,11 310,5 318,3 325,6 332,5 334,11 328,14 314,13", C.ash, `opacity="0.55"`));
addProp("receipt_world", 336, 0, 16, 16, poly("339,3 350,2 349,14 338,13", C.paper) + rect(340, 5, 8, 1, C.ash) + rect(340, 8, 6, 1, C.red));

addProp("child_bed_loop1", 0, 32, 48, 32, bed(0, 32, true));
addProp("child_bed_loop2", 48, 32, 48, 32, bed(48, 32, true, false) + rect(60, 48, 24, 1, C.paper));
addProp("height_marks", 96, 32, 16, 32, rect(102, 34, 2, 28, C.ash) + [0, 1, 2, 3, 4].map((i) => line(104, 39 + i * 5, 108 + (i % 2) * 2, 39 + i * 5, C.paper)).join(""));
addProp("music_box", 112, 32, 16, 16, rect(115, 39, 10, 7, C.teal) + rect(116, 37, 8, 2, C.wall) + circle(120, 42, 2, C.light));
addProp("drawing_hidden", 128, 32, 16, 16, rect(130, 42, 12, 4, C.paper) + rect(133, 41, 9, 1, C.red));
addProp("drawing_revealed", 144, 32, 16, 16, rect(146, 34, 12, 12, C.paper) + poly("148,42 151,38 154,42", C.light) + rect(153, 38, 2, 6, C.ink));

let sofa = rect(2, 70, 44, 24, C.ink) + rect(4, 68, 40, 20, C.wall) + rect(6, 70, 18, 14, C.teal) + rect(25, 70, 17, 14, C.teal) + rect(2, 84, 4, 8, C.wall) + rect(42, 84, 4, 8, C.wall);
addProp("sofa", 0, 64, 48, 32, sofa);
let table = rect(55, 75, 34, 22, C.wall) + rect(52, 72, 40, 5, C.ash) + rect(57, 96, 4, 12, C.ink) + rect(84, 96, 4, 12, C.ink);
table += rect(65, 66, 14, 5, C.teal) + rect(50, 80, 5, 14, C.teal) + rect(89, 80, 5, 14, C.teal);
addProp("family_table", 48, 64, 48, 48, table);
addProp("wedding_photo_loop1", 96, 64, 16, 16, rect(98, 66, 12, 12, C.ash) + rect(100, 68, 8, 8, C.paper) + rect(100, 68, 3, 8, C.red) + rect(104, 69, 3, 7, C.ink));
addProp("wedding_photo_loop2", 112, 64, 16, 16, rect(114, 66, 12, 12, C.ash) + rect(116, 68, 8, 8, C.paper) + rect(116, 69, 3, 7, C.teal) + rect(121, 69, 2, 7, C.wall));

let clock = circle(136, 80, 12, C.ink) + circle(136, 80, 10, C.paper) + line(136, 80, 136, 73, C.ink) + line(136, 80, 142, 83, C.red) + circle(136, 80, 1, C.ink);
addProp("living_clock", 128, 64, 16, 32, clock);
addProp("compartment_closed", 144, 64, 32, 32, rect(146, 66, 28, 28, C.wall) + rect(149, 69, 22, 22, C.ink) + rect(151, 71, 18, 18, C.wall));
addProp("compartment_open", 176, 64, 32, 32, rect(178, 66, 28, 28, C.wall) + rect(181, 69, 22, 22, C.black) + poly("180,68 204,65 206,72 182,76", C.teal));
addProp("memory_tape", 208, 64, 16, 16, rect(210, 68, 12, 8, C.ash) + circle(213, 72, 2, C.ink) + circle(219, 72, 2, C.ink) + rect(214, 74, 4, 1, C.paper));
addProp("hall_light_on", 224, 64, 16, 16, line(232, 65, 232, 69, C.ash) + poly("227,69 237,69 239,75 225,75", C.light) + rect(229, 75, 6, 2, C.paper));
addProp("hall_light_off", 240, 64, 16, 16, line(248, 65, 248, 69, C.ash) + poly("243,69 253,69 255,75 241,75", C.wall));

let door = rect(258, 66, 28, 46, C.ink) + rect(261, 68, 22, 42, C.wall) + rect(264, 72, 16, 12, C.teal) + rect(264, 87, 16, 18, C.teal) + circle(278, 90, 1, C.red);
addProp("exit_door", 256, 64, 32, 48, door);

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

function person(frameX, frameY, direction, step) {
  const x = frameX * 16;
  const y = frameY * 24;
  const legShift = [0, -1, 0, 1][step];
  let b = rect(x + 5, y + 2, 6, 5, C.ink) + rect(x + 6, y + 3, 4, 4, C.paper);
  b += rect(x + 4, y + 7, 8, 10, C.wall) + rect(x + 5, y + 8, 2, 6, C.light);
  if (direction === 0) b += rect(x + 6, y + 3, 4, 1, C.ink);
  if (direction === 1) b += rect(x + 5, y + 2, 6, 4, C.ink) + rect(x + 5, y + 6, 6, 1, C.teal);
  if (direction === 2) b += rect(x + 5, y + 2, 3, 5, C.ink);
  if (direction === 3) b += rect(x + 8, y + 2, 3, 5, C.ink);
  b += rect(x + 3, y + 8 + (step === 1 ? 1 : 0), 2, 8, C.teal) + rect(x + 11, y + 8 + (step === 3 ? 1 : 0), 2, 8, C.teal);
  b += rect(x + 5 + Math.max(0, legShift), y + 17, 3, 6, C.ink) + rect(x + 8 + Math.min(0, legShift), y + 17, 3, 6, C.ink);
  return b;
}
let character = "";
for (let dir = 0; dir < 4; dir++) for (let frame = 0; frame < 4; frame++) character += person(frame, dir, dir, frame);
write("qin_zheng_spritesheet.svg", svg(64, 96, character));

let ui = "";
ui += rect(0, 0, 128, 48, C.ink, `opacity="0.94"`) + rect(0, 0, 128, 48, "none", `stroke="${C.teal}" stroke-width="1"`) + rect(4, 4, 120, 40, "none", `stroke="${C.wall}" stroke-width="1"`);
ui += rect(136, 4, 20, 16, C.wall) + rect(137, 5, 18, 14, C.ink) + `<text x="146" y="16" fill="${C.paper}" font-size="10" text-anchor="middle" font-family="monospace">E</text>`;
ui += rect(160, 4, 38, 16, C.wall) + rect(161, 5, 36, 14, C.ink) + `<text x="179" y="16" fill="${C.paper}" font-size="8" text-anchor="middle" font-family="monospace">ENTER</text>`;
ui += rect(202, 4, 30, 16, C.wall) + rect(203, 5, 28, 14, C.ink) + `<text x="217" y="16" fill="${C.paper}" font-size="8" text-anchor="middle" font-family="monospace">ESC</text>`;
ui += poly("140,30 146,24 152,30 146,36", C.light) + poly("160,30 166,24 172,30 166,36", C.red);
ui += circle(205, 31, 12, "none", `stroke="${C.ash}" stroke-width="2"`) + `<path d="M205 19 A12 12 0 0 1 217 31" fill="none" stroke="${C.red}" stroke-width="2"/>`;
ui += poly("232,20 244,20 248,25 248,37 244,42 232,42 228,37 228,25", C.wall) + rect(235, 24, 6, 10, C.red) + rect(237, 36, 2, 2, C.paper);
ui += rect(0, 56, 160, 56, C.ink, `opacity="0.96"`) + rect(0, 56, 160, 56, "none", `stroke="${C.teal}"`) + `<text x="80" y="90" fill="${C.paper}" font-size="24" text-anchor="middle" font-family="monospace">02 : 17</text>`;
ui += rect(168, 56, 80, 24, C.wall) + rect(169, 57, 78, 22, C.ink) + `<text x="208" y="72" fill="${C.paper}" font-size="9" text-anchor="middle" font-family="sans-serif">降低闪烁</text>`;
write("ui_atlas.svg", svg(256, 128, ui));

const wordmarkDefs = `<linearGradient id="ember" x1="0" x2="1"><stop stop-color="${C.paper}"/><stop offset="0.7" stop-color="${C.light}"/><stop offset="1" stop-color="${C.red}"/></linearGradient>`;
const wordmark = `<rect width="640" height="180" fill="${C.ink}"/><text x="320" y="88" fill="url(#ember)" font-family="PingFang SC, Heiti SC, sans-serif" font-size="58" font-weight="700" text-anchor="middle" letter-spacing="10">地狱轮回</text><text x="320" y="128" fill="${C.ash}" font-family="Georgia, serif" font-size="18" text-anchor="middle" letter-spacing="9">HELL CYCLE</text><path d="M176 146 H464" stroke="${C.wall}"/><path d="M278 146 H362" stroke="${C.red}"/>`;
write("wordmark.svg", svg(640, 180, wordmark, wordmarkDefs));

const fxDefs = "";
let vignette = "";
for (let i = 0; i < 4; i++) {
  const inset = i * 8;
  const opacity = (0.82 - i * 0.17).toFixed(2);
  vignette += rect(inset, inset, 256 - inset * 2, 8, C.black, `opacity="${opacity}"`);
  vignette += rect(inset, 120 - inset, 256 - inset * 2, 8, C.black, `opacity="${opacity}"`);
  vignette += rect(inset, inset + 8, 8, 104 - inset * 2, C.black, `opacity="${opacity}"`);
  vignette += rect(248 - inset, inset + 8, 8, 104 - inset * 2, C.black, `opacity="${opacity}"`);
}
let emberNoise = "";
let seed = 27009;
const random = () => {
  seed = (seed * 1664525 + 1013904223) >>> 0;
  return seed / 4294967296;
};
for (let i = 0; i < 180; i++) {
  const x = Math.floor(random() * 256);
  const edge = random() > 0.5;
  const y = edge ? 128 + Math.floor(random() * 28) : 228 + Math.floor(random() * 28);
  const w = 1 + Math.floor(random() * 4);
  const h = 1 + Math.floor(random() * 2);
  emberNoise += rect(x, y, w, h, random() > 0.72 ? C.light : C.red, `opacity="${(0.18 + random() * 0.5).toFixed(2)}"`);
}
for (let i = 0; i < 80; i++) {
  const left = random() > 0.5;
  const x = left ? Math.floor(random() * 28) : 228 + Math.floor(random() * 28);
  const y = 128 + Math.floor(random() * 128);
  emberNoise += rect(x, y, 1 + Math.floor(random() * 3), 1 + Math.floor(random() * 3), C.red, `opacity="${(0.12 + random() * 0.45).toFixed(2)}"`);
}
const fx = vignette + emberNoise + rect(32, 160, 192, 64, C.black, `opacity="0.78"`);
write("fx_patterns.svg", svg(256, 256, fx, fxDefs));

const regions = {
  version: 1,
  palette: C,
  atlases: {
    environment_tiles: { size: [256, 128], cell: [16, 16], regions: envRegions },
    props_atlas: { size: [512, 256], regions: props },
    qin_zheng_spritesheet: {
      size: [64, 96],
      frame: [16, 24],
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

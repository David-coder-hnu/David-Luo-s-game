# Generated close-up provenance

- Date: 2026-07-13
- Mode: OpenAI built-in image generation
- Intended use: high-resolution source masters for in-game 320×180 memory close-ups
- Final game files: `../../../closeups/`
- Disclosure: these images are game art sources, not documentary images or screenshots.

## Shared generation prompt

```text
Use case: stylized-concept
Asset type: in-game memory close-up for a 640x360 2D pixel psychological horror game
Style/medium: original high-craft 16-bit-inspired pixel art, crisp hard pixel clusters, restrained texture, orthographic close-up, no painterly antialiasing
Color palette: only near-black #0B0C14, cold wall #242936, mist teal #40525A, old paper #C8BFAE, sick light #C29A5B, ember red #8D3035, ash #69656A, with small value variations
Composition: 16:9 landscape, one main object centered with generous dark margin for UI cropping
Lighting: one weak sickly tungsten source, quiet domestic dread
Constraints: no gore, no blood, no visible monster, no ghost face, no watermark, no logo, no decorative readable prose, no photorealism, no modern neon color
```

## Per-asset requests

### Kitchen receipt

```text
Primary request: a water-softened convenience-store receipt with slightly scorched edges lying beneath a kitchen cabinet, two bottle-item rows suggested by abstract marks, a clear empty area where localized text will be overlaid later, a tiny red time-stamp zone but do not render letters or numbers. The paper should feel handled and consequential, not magical.
```

SHA-256: `5272a066fb00b425ce157c75aaa256231307a3e36b8e8e17264c42cdcaac2b32`

### Child drawing — loop 1

```text
Primary request: a child's crayon drawing on aged off-white paper. A simple yellow family house, two small figures safely inside the doorway, one much taller faceless figure outside the closed door heavily covered in near-black crayon. Childlike uneven lines, emotionally restrained, no writing or letters, no smiling horror face.
```

SHA-256: `ab6c6318268c430d2bb162b72b04e2af2102c0928295a178ae8d19a5f5acfe51`

### Wedding photo — loop 1

```text
Primary request: a scorched family wedding photograph in a plain worn frame. An adult woman and a young daughter are visible as warm-gray pixel silhouettes with ordinary body language; an adult man's face area is burned away into an irregular dark patch while his body remains. Respectful, distant family portrait, no injuries, no gore, no melodramatic ghost effects.
```

SHA-256: `1c699167ee44725b29f4cb749ded48410f4dbdc9a12271fbaa7e2e612cb0f0e5`

### Memory tape

```text
Primary request: an old compact audio cassette resting inside a shallow wall compartment, ash-gray plastic, two visible reels, a worn blank cream label reserved for localized text overlay, small scratches from repeated rewinding. No readable text, no blood, no supernatural glow.
```

SHA-256: `60cf74c8ad74b3800fde996ff04204b3a4426e1af2ca68967ea3356d3ec0cf35`

## Loop-2 edits

### Child drawing — loop 2

Input: `child_drawing_loop1_source.png`

```text
Use case: precise-object-edit
Asset type: second-loop in-game memory close-up
Input image: edit target and invariant reference
Primary request: Change only the narrative arrangement inside the child's crayon drawing. Move the tall faceless near-black crayon figure from outside the house to just inside the doorway behind the two smaller figures. Recolor the closed door itself to a restrained ember red #8D3035. Keep the two smaller figures, yellow house, sun, cloud, paper texture, exact framing, lighting, pixel-art rendering, margins, and all other marks unchanged.
Constraints: the tall figure remains faceless and non-graphic; no text, no letters, no new figures, no blood, no ghost effects, no watermark.
```

SHA-256: `502153e498508fcda6c600816019ba99d8884a7650e0bcef9565f6d55ad61025`

### Wedding photo — loop 2

Input: `wedding_photo_loop1_source.png`

```text
Use case: precise-object-edit
Asset type: second-loop in-game memory close-up
Input image: edit target and invariant reference
Primary request: Change only the adult man's burned-away face area. Replace the irregular empty burn hole with a restored but deliberately featureless dark pixel-art head silhouette that belongs to the existing man's body and suit. The restored head should have ordinary human proportions, short dark hair, no readable facial details, and no supernatural glow. Preserve the woman, daughter, their poses and expressions, clothing, flowers, frame, sepia paper, scorch marks around the former hole, exact composition, lighting, palette, and pixel rendering unchanged.
Constraints: no gore, no injury, no ghost face, no text, no watermark, do not alter the woman or child.
```

SHA-256: `0bf8f68d548c3ea647ca592d519b238ab6466f4c6a5ff24b01a92cf46443ad15`

## Processing

Each 1672×941 source is processed by `tools/process_generated_assets.mjs` using nearest-neighbor resizing plus 32-color, no-dither PNG quantization. The resulting runtime asset is exactly 320×180 and retains deliberate pixel clusters rather than smooth resampling. No generated pseudo-text carries narrative meaning; localized game text supplies all readable facts.

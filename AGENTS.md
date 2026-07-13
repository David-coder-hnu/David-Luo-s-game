# Repository instructions

## Source of truth

Read `docs/README.md` before making project changes. Resolve conflicts using its authority order. Files under `docs/design/` are archived planning history and are never implementation requirements.

For implementation work, also read the relevant specialist specification and `docs/IMPLEMENTATION_CONTRACTS.md`. Asset-producing work must follow `docs/ASSET_MANIFEST.md` and `docs/ASSET_CREDITS.md`.

## Scope

The current milestone is the two-loop vertical slice in `docs/VERTICAL_SLICE.md`. Do not add a basement, chase AI, persistence, procedural generation, a third loop, new platforms, or full-game systems unless `docs/DECISIONS.md` is revised first.

## Narrative safety

Public-facing material must not reveal that the protagonist killed his family. Internal narrative must not frame alcohol, amnesia, or self-immolation as absolution. Do not add graphic violence against the wife or child. Preserve their names, agency, and daily-life details.

## Implementation

- Use Godot `4.6.3-stable` for the editor, project, and export templates.
- Keep one base house scene and apply named mutation layers.
- Treat `GameState` as the sole progress authority and preserve its invariants.
- Keep final text outside scene scripts and reference stable localization keys.
- Make state-changing interactions idempotent.
- Do not add dependencies or generalized frameworks without a current slice requirement.
- Use task packages and completion evidence defined in `docs/AI_BUILD_PROTOCOL.md`.

## Verification

Use `docs/PLAYTEST.md`. Changes to fragments, phase transitions, reset behavior, the clock, or endings require regression of both complete paths. New assets require an entry in `docs/ASSET_CREDITS.md` before they are committed.

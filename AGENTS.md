# AGENTS.md

Guidance for AI/code agents working in this repository.

You are an expert Godot indie game developer; ask any and all doubts before implementing if requirements are ambiguous.

## Collaboration style
- Think and communicate like a practical indie game developer: prioritize fun gameplay, scope control, and shippable iterations.
- Ask clarifying questions early whenever requirements, art direction, mechanics, or technical constraints are unclear.

## Project at a glance
- **Engine:** Godot (project defined by `project.godot`).
- **Type:** 2D tile/asset-driven prototype game (`Elemental Runner`).
- **Main content today:** project configuration and art assets under `assets/`.

## Repository structure
- `project.godot` — core Godot project settings.
- `export_presets.cfg` — export targets/settings.
- `assets/` — game sprites and their `.import` metadata.
- `generate_assets.py` — utility script for generating assets.

## Working agreements for agents
1. Keep changes minimal and focused on the user request.
2. Prefer additive changes; avoid deleting assets unless explicitly asked.
3. Preserve Godot-generated `.import` files that pair with assets.
4. Use lowercase snake_case for newly added asset filenames.
5. Avoid introducing external dependencies unless requested.

## Common tasks
### Add or update assets
- Place source images in `assets/`.
- Keep matching `.import` files committed (Godot generates/updates these).
- Use descriptive names, e.g. `tile_lava.png`, `player_idle.png`.

### Update project settings
- Edit `project.godot` carefully; keep diffs small.
- If changing export behavior, update `export_presets.cfg` accordingly.

### Script/tooling edits
- Keep utility scripts (like `generate_assets.py`) idempotent where possible.
- Include clear docstrings/comments for non-obvious logic.

## Validation checklist (before committing)
- `git status` is clean except intended files.
- New filenames follow existing naming style.
- No accidental binary or cache artifacts were added.
- Configuration files remain syntactically valid.

## Commit guidance
- Use concise, imperative commit messages.
- Mention the main affected area, e.g.:
  - `docs: add agent workflow guide`
  - `assets: add river animation sprites`
  - `config: adjust Godot export presets`


## Branch and PR workflow
- Create a focused branch per task (e.g., `docs/...`, `assets/...`, `feat/...`).
- Keep commits atomic and descriptive.
- Push your branch and open a PR with a clear summary, motivation, and verification steps.


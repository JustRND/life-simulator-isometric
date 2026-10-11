# UI layout conventions

Life.exe uses Godot Control containers for responsive layout. Preserve existing
visual styling and gameplay behavior when editing UI.

- Configure each dynamic control where it is created. Do not use a global tree
  walk that changes anchors, size flags, minimum sizes, or text wrapping after
  controls have been added.
- In an `HBoxContainer`, avatars, icons, badges, and close buttons are compact
  (`SIZE_SHRINK_*`); the single information column is `SIZE_EXPAND_FILL`.
- Use `LayoutGuard.configure_action_button` for new dynamic action buttons,
  and `LayoutGuard.configure_compact_grid_action` for two-column grids, and
  `LayoutGuard.configure_compact_label` for short values that must remain on
  one line. Descriptions use word-smart wrapping in an expanding column.
- Do not give a compact control `SIZE_EXPAND_FILL` merely to prevent clipping.
  Fix its parent allocation instead.
- On narrow layouts, use a `GridContainer` that changes columns or stack
  secondary controls. Do not reduce readable text to a character-wide column.
- `LayoutGuard` reports suspiciously narrow visible labels/buttons in debug
  builds only. It must not resize controls or run in release exports.
- Before changing a shared builder, test at the project's portrait size
  (1080×1920) and a narrow mobile viewport (390×844), then check a desktop
  viewport.

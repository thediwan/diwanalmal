# Responsive Architecture — ديوان المال

This document describes the constraint-based responsive system used across mobile, tablet, web, and desktop from a single Flutter codebase.

## Breakpoints (Material 3 Window Size Classes)

Defined in `lib/core/responsive/app_breakpoints.dart`:

| Class | Width | Navigation | Typical layout |
|-------|-------|------------|----------------|
| compact | &lt; 600 dp | Bottom `NavigationBar` | Single column |
| medium | 600–839 dp | Icon `NavigationRail` | Single column, max ~720 dp content |
| expanded | 840–1199 dp | Extended `NavigationRail` | Two columns, master-detail |
| large | 1200–1599 dp | Extended rail | Grids (3–4 columns) |
| extraLarge | ≥ 1600 dp | Extended rail | Wider grids |

Classification uses **`LayoutBuilder` constraints**, never platform checks (`Platform.isWindows`, `kIsWeb`, `isDesktop`).

## Core modules

```
lib/core/responsive/
├── app_breakpoints.dart      # WindowSizeClass + helpers
├── responsive_layout.dart    # LayoutBuilder → size class
├── responsive_content.dart   # Max-width + padding
├── responsive_grid.dart      # Adaptive column grid
└── responsive_spacing.dart   # Spacing tokens

lib/core/layouts/
├── adaptive_app_shell.dart   # Bottom nav / navigation rail
├── form_page_layout.dart     # Centered forms (~560 dp)
├── master_detail_layout.dart # List + detail panes
├── page_scaffold.dart        # AppBar + responsive body
└── two_column_layout.dart    # Primary + secondary columns
```

## Navigation

- **Router:** `StatefulShellRoute.indexedStack` in `lib/router/app_router.dart` preserves tab state per branch.
- **Shell:** `AdaptiveAppShell` switches between bottom nav (compact) and rail (medium+).
- **RTL:** Rail renders on the start side automatically via `NavigationRail` in a `Row`.

## Screen composition pattern

```
FeatureScreen (StatefulWidget — data, providers)
  └── FeatureScreenView (layout variants via ResponsiveLayout)
        └── FeatureScreenContent (shared widgets)
```

Business logic stays in providers/services; layout files only arrange widgets.

## Feature integration

| Feature | Responsive behavior |
|---------|---------------------|
| Dashboard | Two columns on expanded+ (summary left, chart/transactions right) |
| Transactions | Master-detail on expanded+; compact pushes full-screen edit |
| Wallets | Grouped list on compact; responsive grid on expanded+ |
| Settings | `ResponsiveContent` max-width list |
| Forms | `FormPageLayout` centered ~560 dp |
| Auth | `ResponsiveAuthLayout`; split panel on expanded+ via `SplitAuthBackground` |

## Widget rules

- Prefer `Expanded` / `Flexible` over fixed page widths.
- Use `ResponsiveContent` on tab-root screens.
- Use `ResponsiveGrid` for card collections — never hardcode column counts in features.
- Use directional APIs (`EdgeInsetsDirectional`, `AlignmentDirectional`) for RTL.
- All user-facing strings via `context.l10n`.

## Testing

Unit tests: `test/core/responsive/app_breakpoints_test.dart`

Manual QA checklist:
- [ ] Compact phone layout unchanged
- [ ] Resize web/desktop window through all breakpoints
- [ ] Arabic RTL at each breakpoint
- [ ] Dark mode per layout variant
- [ ] Tab state preserved when switching tabs and resizing

## Adding a new screen

1. Wrap body in `ResponsiveContent` (or `FormPageLayout` for forms).
2. Use `ResponsiveLayout` only when structure changes (not for padding alone).
3. Extract shared sections into feature `widgets/` — do not duplicate mobile/desktop screens.
4. Run `flutter analyze` before merging.

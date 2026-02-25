# Game UI Architecture Plan

## The Problem

The game needs to run on two very different contexts:

- **Mobile**: vertical orientation, small screen, touch input, compact UI with icons only.
- **Desktop**: horizontal orientation, larger screen, mouse/keyboard input, expanded UI with icons and text.

This affects **every screen** in the game, not just the match HUD. Every section (main menu, collection, deck builder, profile, settings, social, etc.) needs a layout adapted to each platform.

## Target Resolutions

Each platform targets a specific reference resolution:

| Platform | Resolution   | Orientation | Aspect Ratio |
|----------|-------------|-------------|--------------|
| Desktop  | 1920 × 1080 | Horizontal  | 16:9         |
| Mobile   | 330 × 800    | Vertical    | ~9:19.4      |

All layouts are designed to these reference sizes. The Godot project uses `stretch_mode = canvas_items` so the UI scales proportionally to other resolutions while maintaining the designed proportions.

## Backend and Frontend Architecture

The project follows a **common backend, separate frontends** approach:

- **Backend (shared):** A single Laravel REST API (`https://leyendas.espadasdeceniza.com/api/v1`) serves all game data, translations, images, and configuration. Both platforms consume the exact same endpoints. The backend handles all server-side logic: data storage, translations, image serving, and game configuration. See `API.md` for the full endpoint reference.
- **Frontend (per device):** The Godot client contains two visual layouts for every screen — one optimized for desktop and one for mobile. The game logic is written once and shared between both layouts. The `SceneManager` autoload handles loading the correct layout variant at runtime based on the detected platform.

## The Approach: Shared Logic, Separate Layouts

The core idea is to **never duplicate logic**. Each screen has:

- **One script** (.gd) with all the logic: button callbacks, data loading, signals, state management.
- **Two scene files** (.tscn): one for mobile and one for desktop. Both attach the same script.

This way, the visual layout is completely independent from the behavior. Adding a new feature means writing the logic once and placing the nodes in two layouts.

```
res://screens/main_menu/
├── main_menu.gd                # Logic (shared)
├── main_menu_mobile.tscn       # Vertical, compact
└── main_menu_desktop.tscn      # Horizontal, expanded
```

## Why Not a Single Adaptive Layout?

Godot does not have a CSS media query equivalent. While it is possible to rearrange nodes by code based on screen size, this approach has significant drawbacks:

- The code becomes cluttered with layout logic mixed into game logic.
- Complex rearrangements (vertical to horizontal, hiding/showing elements, changing container types) are painful to manage in code.
- It is much harder to visually design and iterate on a layout that only exists at runtime.

Having two scene files means each layout can be designed visually in the Godot editor, which is faster and less error-prone.

## Scene Manager

A global autoload called `SceneManager` handles all navigation. When any part of the game requests a screen change, the scene manager automatically loads the correct variant (mobile or desktop) without the caller needing to know which one.

```
SceneManager.go_to("main_menu")
# Loads main_menu_mobile.tscn or main_menu_desktop.tscn
```

Platform detection happens once at startup using `OS.has_feature("mobile")`, and the result is stored for the rest of the session.

## Project Structure

```
res://
├── autoloads/
│   ├── scene_manager.gd         # Navigation between screens
│   ├── game_data.gd             # Player data, collection, decks
│   └── audio_manager.gd         # Music and SFX
│
├── screens/
│   ├── main_menu/
│   │   ├── main_menu.gd
│   │   ├── main_menu_mobile.tscn
│   │   └── main_menu_desktop.tscn
│   ├── play/
│   │   ├── mode_selection/
│   │   │   ├── mode_selection.gd
│   │   │   ├── mode_selection_mobile.tscn
│   │   │   └── mode_selection_desktop.tscn
│   │   └── match/
│   │       ├── match.gd
│   │       ├── match_mobile.tscn
│   │       └── match_desktop.tscn
│   ├── collection/
│   │   ├── card_browser/
│   │   │   ├── card_browser.gd
│   │   │   ├── card_browser_mobile.tscn
│   │   │   └── card_browser_desktop.tscn
│   │   ├── hero_browser/
│   │   │   ├── hero_browser.gd
│   │   │   ├── hero_browser_mobile.tscn
│   │   │   └── hero_browser_desktop.tscn
│   │   └── deck_builder/
│   │       ├── deck_builder.gd
│   │       ├── deck_builder_mobile.tscn
│   │       └── deck_builder_desktop.tscn
│   ├── social/
│   │   ├── friends.gd
│   │   ├── friends_mobile.tscn
│   │   └── friends_desktop.tscn
│   ├── profile/
│   │   ├── profile.gd
│   │   ├── profile_mobile.tscn
│   │   └── profile_desktop.tscn
│   └── settings/
│       ├── settings.gd
│       ├── settings_mobile.tscn
│       └── settings_desktop.tscn
│
├── ui/
│   └── components/              # Reusable widgets (buttons, card previews, etc.)
│
├── assets/
│   ├── icons/placeholder/       # Lucide icons as temporary placeholders
│   ├── fonts/
│   └── textures/
│
├── translations/
│   ├── ui.csv                   # General UI translations (es, en)
│   ├── settings.csv             # Settings translations
│   ├── match.csv                # In-match HUD translations
│   └── errors.csv               # Error messages translations
│
└── core/
    ├── card.gd                  # Card data model
    ├── hero.gd                  # Hero data model
    └── deck.gd                  # Deck data model
```

## Screen Map

```
Main Menu
├── Play
│   ├── Mode Selection
│   └── Match
├── Collection
│   ├── Card Browser
│   ├── Hero Browser
│   └── Deck Builder
├── Social
│   └── Friends
├── Profile
└── Settings
```

Future sections like Events or Shop follow the same pattern: one script, two layouts, registered in the scene manager.

## Reusable Components

The project prioritizes a **component-based UI architecture**. Shared UI elements live in `ui/components/` and are designed to be composed into any screen layout.

### Principles

- **Build once, use everywhere:** Common widgets (buttons, card previews, stat bars, hero portraits, resource indicators, list items, dialogs, etc.) are self-contained scenes that receive data via exported variables or setter functions and emit signals for interaction.
- **Platform-adaptive:** Components should work in both mobile and desktop layouts at their respective reference resolutions (330×800 and 1920×1080). If a component requires radically different layouts per platform, it follows the same pattern as screens: one script with two `.tscn` variants.
- **Consistent styling:** All components use the shared theme resources (`GameColors`, fonts, and icon conventions defined in `STYLE_GUIDE.md`) to ensure visual consistency across screens.
- **Composable:** Screens are assembled by placing reusable components in the layout editor, not by duplicating UI code. A new screen should mostly consist of arranging existing components plus minimal screen-specific additions.

### Directory Structure

```
res://ui/components/
├── buttons/              # Custom button styles (primary, secondary, icon-only, etc.)
├── cards/                # Card preview, card list item, card detail
├── heroes/               # Hero portrait, hero stat bar, hero list item
├── dialogs/              # Confirmation dialog, info popup
├── navigation/           # Tab bar, breadcrumb, back button
└── common/               # Generic widgets (loading spinner, divider, badge, etc.)
```

## Internationalization (i18n)

The application is **multi-language from day one**. The supported languages are:

| Language | Code | Role     |
|----------|------|----------|
| Español  | `es` | Primary  |
| English  | `en` | Secondary|

### How It Works

Translations are split between the backend (dynamic game content) and the frontend (UI labels and static text):

**Backend translations (game data):**
The Laravel API handles all game content translations (card names, hero lore, ability descriptions, etc.). The client requests data with the `?locale=es|en` query parameter and receives already-translated strings. See `API.md` for details.

**Frontend translations (UI text):**
All static UI text (button labels, screen titles, menu items, tooltips, error messages, etc.) uses Godot's built-in translation system with `.csv` translation files.

```
res://translations/
├── ui.csv                # General UI: buttons, menus, titles, common labels
├── settings.csv          # Settings screen labels
├── match.csv             # In-match HUD text
└── errors.csv            # Error and feedback messages
```

Each `.csv` file follows this format:

```csv
key,es,en
MAIN_MENU_PLAY,Jugar,Play
MAIN_MENU_COLLECTION,Coleccion,Collection
MAIN_MENU_SOCIAL,Social,Social
MAIN_MENU_PROFILE,Perfil,Profile
MAIN_MENU_SETTINGS,Ajustes,Settings
```

### Making Views Translatable

Every user-visible string in a scene or script must use a translation key instead of hardcoded text:

- **In scenes (.tscn):** Set the `text` property of Labels and Buttons to a translation key (e.g., `MAIN_MENU_PLAY`). Godot auto-translates nodes whose `auto_translate` property is enabled (default).
- **In scripts (.gd):** Use the `tr()` function for any dynamic text:
  ```gdscript
  label.text = tr("DECK_BUILDER_CARDS_COUNT").format({"count": deck.size()})
  ```

### Language Selection

The player's preferred language is stored in `user://settings.cfg` and applied at startup. The `SceneManager` or a dedicated `LocaleManager` autoload sets `TranslationServer.set_locale(code)` and also appends `?locale=code` to all API requests so both UI text and game data match the selected language.

## Placeholder Icons

During development, Lucide Icons (lucide.dev) are used as UI placeholders. They are stored as PNG files in `assets/icons/placeholder/` and will be replaced with custom assets later. Using a dedicated folder and a consistent naming convention (e.g., `icon_play.png`, `icon_settings.png`) makes the swap straightforward.

## Benefits of This Architecture

- **No logic duplication**: behavior is written once per screen.
- **Visual editing**: both layouts are designed in the Godot editor at their target resolutions (1920×1080 desktop, 330×800 mobile), not assembled by code.
- **Clean separation**: adding a new screen or a new platform variant does not affect existing code.
- **Easy to scale**: new sections (shop, events, tournaments) follow the exact same pattern.
- **Component reuse**: building screens from shared components reduces duplication and ensures UI consistency.
- **Multi-language ready**: all user-facing text is translatable from day one via translation files (UI) and API locale parameter (game data).
- **Common backend**: a single API serves both platforms, avoiding data or logic divergence between desktop and mobile.
- **Simple placeholder workflow**: temporary assets are isolated and easy to replace.
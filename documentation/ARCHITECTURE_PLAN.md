# Game UI Architecture Plan

## The Problem

The game needs to run on two very different contexts:

- **Mobile**: vertical orientation, small screen, touch input, compact UI with icons only.
- **Desktop**: horizontal orientation, larger screen, mouse/keyboard input, expanded UI with icons and text.

This affects **every screen** in the game, not just the match HUD. Every section (main menu, collection, deck builder, profile, settings, social, etc.) needs a layout adapted to each platform.

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

Shared UI elements (custom buttons, card preview widgets, stat bars, etc.) live in `ui/components/`. These components should be small and adaptive enough to work in both layouts, or have their own mobile/desktop variants if needed.

## Placeholder Icons

During development, Lucide Icons (lucide.dev) are used as UI placeholders. They are stored as PNG files in `assets/icons/placeholder/` and will be replaced with custom assets later. Using a dedicated folder and a consistent naming convention (e.g., `icon_play.png`, `icon_settings.png`) makes the swap straightforward.

## Benefits of This Architecture

- **No logic duplication**: behavior is written once per screen.
- **Visual editing**: both layouts are designed in the Godot editor, not assembled by code.
- **Clean separation**: adding a new screen or a new platform variant does not affect existing code.
- **Easy to scale**: new sections (shop, events, tournaments) follow the exact same pattern.
- **Simple placeholder workflow**: temporary assets are isolated and easy to replace.
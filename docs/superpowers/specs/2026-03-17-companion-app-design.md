# Bauhaus Clock Companion App — Design Spec

## Overview

A single-window SwiftUI companion app ("Bauhaus Clock") that configures the installed screensaver by writing to `UserDefaults(suiteName: "com.bauhausclk.BauhausClock")`. On launch it snapshots current values; OK persists changes, Cancel reverts. Both close the window.

## Data Model

Stored keys in the shared UserDefaults suite:

| Key          | Type   | Values                                    | Default          |
|--------------|--------|-------------------------------------------|------------------|
| `appearance` | String | `"day"`, `"night"`, `"system"`            | `"night"`        |
| `dial`       | String | 16 dial names from `Palettes.dialNames`   | `"Noir"`         |
| `size`       | String | `"Classic"`, `"Compact"`                  | `"Classic"`      |
| `movement`   | String | `"Quartz"`, `"Mechanical"`, `"Digital"`   | `"Mechanical"`   |
| `lume`       | String | 9 lume names from `Palettes.lumeNames`    | `"Tritium Green"`|
| `seconds`    | Bool   | true/false                                | `true`           |

The boolean `night` key is replaced by the three-state `appearance` key.

## UI Layout

Fixed-size, non-resizable window. Two visual regions: light upper area and dark bottom bar.

### 1. Appearance Section
- Header: "Appearance" bold label
- 3 rounded-rect thumbnail cards: Day / Night / System
- Each card contains a clock preview rendered via ClockRenderer into a small bitmap
- Day card: current dial palette. Night card: current lume on black. System card: split day+night with rounded-rect clip
- Selected card: bold border + bold label text

### 2. Clock Dial Section
- Header: "Clock Dial" bold label + `<` `>` circular arrow buttons
- Horizontally scrollable row showing 5 circular dial thumbnails at a time
- Each thumbnail: ClockRenderer output clipped to a circle, dial name below
- Selected: bold circular border + bold label
- Arrows scroll by one position; wraps around

### 3. Size + Movement Row (side by side)
- **Size**: "Size" bold label, 2 rounded-rect icon cards (Classic / Compact)
- **Movement**: "Movement" bold label + dot + description text (e.g., "Mechanical sweep"), 3 rounded-rect icon cards (Quartz / Mechanical / Digital)
- Movement icons: stylized second-hand fan illustrations
- Selected: bold border + bold label

### 4. Lume Color Bar (dark background)
- "Lume Color" white label
- Row of 9 colored circles from `Palettes.lumeColors`
- Selected circle: white ring outline
- Selected lume name shown below in gray text

### 5. Footer (dark background, continuation of lume bar)
- Left: "Made with care by Atilla ↗" link (opens browser)
- Right: Cancel button (gray) + OK button (white/prominent)
- Cancel: reverts to snapshot values, closes window
- OK: writes current values to UserDefaults, closes window

## Architecture

```
CompanionApp/
├── BauhausClockApp.swift      # SwiftUI App entry, single window
├── SettingsView.swift          # Main settings layout (all sections)
├── SettingsViewModel.swift     # ObservableObject, reads/writes UserDefaults suite
├── ClockThumbnail.swift        # NSViewRepresentable rendering ClockRenderer
└── Info.plist                  # App bundle metadata
```

Reuses `BauhausClock/ClockRenderer.swift` and `BauhausClock/Palettes.swift` directly — no duplication.

## Build

`build-companion.sh` compiles all SwiftUI + shared sources into `build/BauhausClock.app` macOS app bundle.

## Screensaver Update

`ClockScreenSaverView.swift` updated to read `appearance` key instead of boolean `night`:
- `"day"` → night mode off
- `"night"` → night mode on
- `"system"` → check `NSAppearance.current` for dark mode

Also reads the new `movement` key (currently unused by screensaver — already has movement logic but reads from a hardcoded or missing default).

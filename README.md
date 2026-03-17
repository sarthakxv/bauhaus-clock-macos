# Bauhaus Clock

A macOS screensaver recreation of [bauhausclock.com](https://bauhausclock.com/) — the $19 screensaver by [@_atilla1](https://x.com/_atilla1). Built as a native Swift `.saver` bundle using Core Graphics for all rendering.

---

## Features

- **16 dial palettes** — White, Turquoise, Glacier, Ocean, Tennis, Signal Blue, Salmon, Yellow, Beige, Pistachio, Lavender, Rose, Sky Blue, Cream, Slate, Noir
- **3 movement types** — Quartz (1 Hz tick), Mechanical (4 Hz / 28,800 bph sweep), Digital (smooth continuous)
- **Night mode** — 9 lume colors: Tritium Green, Amber, Swiss BGW9, Ice Blue, Red, Lavender, Rose, Seafoam, White
- **Burn-in protection** — subtle position drift every 45 s
- **Settings panel** — slide-in on click; Classic / Compact size, second hand toggle
- **Grain texture** — deterministic LCG noise over the full viewport, soft-light blended

## Project Structure

```
bauhaus-clock-macos/
├── BauhausClock/
│   ├── ClockScreenSaverView.swift  # ScreenSaver.framework entry point
│   ├── ClockRenderer.swift         # Pure Core Graphics rendering engine
│   ├── Palettes.swift              # NSColor palette definitions (16 dials)
│   └── Info.plist
├── build.sh                        # One-command build (no Xcode required)
└── project.yml                     # XcodeGen spec (optional, for IDE use)
```

## Building

### Prerequisites

- macOS 13+
- Xcode Command Line Tools (`xcode-select --install`)

### Quick build

```bash
./build.sh
```

Output: `build/BauhausClock.saver`

### Install

```bash
open build/BauhausClock.saver
# macOS will prompt — click "Install for this user only"
```

Or copy manually:

```bash
cp -R build/BauhausClock.saver ~/Library/Screen\ Savers/
```

Then open **System Settings → Screen Saver** and select **Bauhaus Clock**.

### Optional: Xcode project (via XcodeGen)

```bash
brew install xcodegen
xcodegen generate
open BauhausClock.xcodeproj
```

## Design Notes

- **Hands** — leaf/lozenge CGPath; 6-stop metallic gradient (edge → mid → highlight) + drop shadow
- **Hour indices** — capsule rounded rects at all 12 positions; same 2-layer metallic treatment
- **Minute ticks** — 48 fine gray lines at `fR * 0.94–0.98` (skipping hour positions)
- **Face/background** — same color (no bezel or outer border); deterministic LCG grain overlay
- **Center hub** — 5-layer concentric ring assembly
- **Typography** — Jost Medium via CoreText (geometric Bauhaus-era typeface); fallback: Helvetica Neue

## Known Differences from the Original

- Typography uses Jost rather than the original's custom in-house typeface
- Hand bezier curves are close but not identical (real hands may have concave edges)
- Palette colors are approximated from marketing thumbnails, not extracted from the binary
- Settings panel is basic; original has a polished native macOS sheet
- Multi-language support (EN/FR/DE/ES/IT/JA/ZH/RU/TR/AR) not implemented
- Day/Night auto-switching via `NSAppearance` not yet wired up

## Tech Stack

- Swift 5, ScreenSaver.framework, AppKit, CoreText, CoreGraphics
- macOS 13+ (arm64)
- No third-party dependencies

## Credits

Original design by [@_atilla1](https://x.com/_atilla1), inspired by the Junghans Max Bill watch dial.
This is an independent open-source reimplementation for personal/educational use.

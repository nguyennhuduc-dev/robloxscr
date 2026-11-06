# ⚡ Roblox Visual Control Center

<p align="center">
  <img src="assets/file_000000005c5082079ef4c59766fca733.png" alt="Roblox visual tools banner" width="100%" />
</p>
<p align="center">
  <strong>Client-side Luau visual tools for Roblox</strong><br>
  FPS optimization · Blox Fruits grayscale map · Auto Click · Combined control menu
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-Luau-00BFFF?style=for-the-badge&logo=lua" alt="Luau" />
  <img src="https://img.shields.io/badge/Platform-Roblox-111111?style=for-the-badge&logo=roblox" alt="Roblox" />
  <img src="https://img.shields.io/badge/Executor-Delta-5865F2?style=for-the-badge" alt="Delta" />
</p>

---

## 📌 About

This repository provides client-side Luau scripts for visual customization and optimization in Roblox. You can run each feature separately or use the combined **Visual Control Center** menu to choose which features to enable.

## 🧭 Recommended: Visual Control Center

### `visual-control-center.lua` — Visual Control Center V3

A Banana Cat Hub-inspired interface with three independent features:

- **FPS Booster Ultra:** toggles selected particles, trails, beams, smoke, fire, sparkles, post effects, shadows, and selected lighting settings.
- **Blox Fruits Gray Map Ultra:** toggles eligible map parts and terrain materials to gray while preserving Terrain Water, named water/ocean/sea objects, and large thin blue/cyan ocean surfaces.
- **Auto Click (executor M1 input):** sends repeated left-click input using `mouse1click()` or the `mouse1press()`/`mouse1release()` pair, at a configurable interval from 0.05 to 5 seconds (default 0.10 seconds). It does not detect or require a specific weapon. It hides the menu after starting and pauses M1 input while the menu is open, preventing repeated clicks from activating menu controls. The floating avatar remains available to reopen the menu. Mobile Delta support is not guaranteed.
- **Floating avatar button:** tap the avatar to hide or show the main menu.
- **Three navigation tabs:** FPS Booster Ultra, Gray Map Ultra, and Auto Click.
- **Restore All + Stop Auto Click:** restores saved visual properties and stops the Auto Click loop.
- **Draggable menu and avatar:** move the panel and floating avatar on screen.

**Delta loader**
```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nguyennhuduc-dev/robloxscr/refs/heads/main/visual-control-center.lua"
))()
```

**File:** [visual-control-center.lua](visual-control-center.lua)

## 📦 Individual scripts

### 1. Roblox FPS Booster Ultra — `roblox.lua`

General-purpose visual optimization with its own GUI and approximate FPS counter.

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nguyennhuduc-dev/robloxscr/refs/heads/main/roblox.lua"
))()
```

**File:** [roblox.lua](roblox.lua)

### 2. Blox Fruits Gray Map Ultra — `blox-fruits-gray-map.lua`

Standalone map grayscale script with a restore button.

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nguyennhuduc-dev/robloxscr/refs/heads/main/blox-fruits-gray-map.lua"
))()
```

**File:** [blox-fruits-gray-map.lua](blox-fruits-gray-map.lua)

## 🚀 How to use

1. Join the Roblox experience.
2. Open your supported executor (for example, Delta).
3. For the combined menu, paste the **Visual Control Center** loader above.
4. Tap **FPS BOOSTER** and/or **GRAY MAP** to enable each feature independently.
5. In **Auto Click**, set the interval (0.05–5 seconds) and tap **START AUTO CLICK**. The menu hides automatically and repeated M1 input runs while the menu is hidden. Tap the floating avatar to reopen the menu; input pauses while the menu is visible. Tap **STOP AUTO CLICK** to stop.
6. Tap **RESTORE ALL + STOP AUTO CLICK** to restore visual settings and stop Auto Click.
6. Tap the floating avatar to hide or show the menu. The dash button in the header also hides it; tap the avatar again to reopen it.

For Blox Fruits, Gray Map skips Terrain Water, water/ocean/sea-named objects (including their parent groups), and large thin blue/cyan parts commonly used as custom sea surfaces. Unusual custom water assets may still need an additional game-specific exclusion.

## ⚠️ Notes & limitations

- These scripts run client-side. Auto Click uses executor-provided `mouse1click()` or `mouse1press()`/`mouse1release()` input functions. It does not detect equipped weapons. The menu automatically hides when Auto Click starts. M1 input pauses while the menu is visible, so the loop does not repeatedly activate menu controls. The floating avatar remains available to reopen the menu.
- Auto Click requires the executor to expose `mouse1click()` or both `mouse1press()` and `mouse1release()`. Some mobile executor builds do not expose these APIs, and behavior on Android/Delta is not guaranteed. If no supported API exists, the script reports that Auto Click is unavailable rather than pretending it is running.
- These scripts do not modify server data, player stats, combat logic, or game progression.
- FPS improvements are not guaranteed; results depend on the device, experience, and rendering workload.
- Some effects or map objects may be recreated by the game or may not be accessible to the script.
- Restore can only return properties that were successfully recorded. If the game changes an object while a feature is active, the result may not exactly match its original appearance.
- The FPS Booster can reduce water wave effects; if keeping the sea's original appearance is important, leave FPS Booster off and use Gray Map alone.
- Disabling or recoloring visuals can make gameplay cues harder to see.
- The Auto Click settings controls are positioned separately from the main action card to avoid overlapping the Start/Stop control. The status refreshes when a Tool is equipped or unequipped.\n- Compatibility may change after Roblox, game, or executor updates. This script has not been verified by running it inside Delta/Blox Fruits; test carefully and stop if you encounter issues.

## 📁 Repository structure

```text
robloxscr/
├── README.md
├── visual-control-center.lua
├── roblox.lua
└── blox-fruits-gray-map.lua
```

## 👨‍💻 Developer

**GitHub:** [@nguyennhuduc-dev](https://github.com/nguyennhuduc-dev)

**Repository:** [nguyennhuduc-dev/robloxscr](https://github.com/nguyennhuduc-dev/robloxscr)

---

<p align="center">
  Made with ❤️ for the Roblox scripting community
</p>

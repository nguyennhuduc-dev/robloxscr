# ⚡ Roblox Visual Control Center

<p align="center">
  <img src="assets/file_000000005c5082079ef4c59766fca733.png" alt="Roblox visual tools banner" width="100%" />
</p>
<p align="center">
  <strong>Client-side Luau visual tools for Roblox</strong><br>
  FPS optimization · Blox Fruits grayscale map · Combined control menu
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

### `visual-control-center.lua`

A Banana Cat Hub-inspired interface with **only the two original visual features**:

- **FPS Booster Ultra:** toggles selected particles, trails, beams, smoke, fire, sparkles, post effects, shadows, and selected lighting settings.
- **Blox Fruits Gray Map Ultra:** toggles eligible map parts and terrain materials to gray while attempting to preserve water.
- **Floating avatar button:** tap the avatar to hide or show the main menu.
- **Two navigation tabs:** FPS Booster Ultra and Gray Map Ultra.
- **Restore Both Features:** restores the saved visual properties from both features.
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
5. Tap **RESTORE ALL SETTINGS** to turn both features off and restore saved properties.
6. Tap **X** to restore settings and close the menu.

For Blox Fruits, Gray Map is designed to preserve Terrain Water and objects identified as water. Custom game assets may not always be identified correctly.

## ⚠️ Notes & limitations

- These scripts make **client-side visual changes**. They do not modify server data, player stats, combat logic, or game progression.
- FPS improvements are not guaranteed; results depend on the device, experience, and rendering workload.
- Some effects or map objects may be recreated by the game or may not be accessible to the script.
- Restore can only return properties that were successfully recorded. If the game changes an object while a feature is active, the result may not exactly match its original appearance.
- The FPS Booster can reduce water wave effects; if keeping the sea's original appearance is important, leave FPS Booster off and use Gray Map alone.
- Disabling or recoloring visuals can make gameplay cues harder to see.
- Compatibility may change after Roblox, game, or executor updates. Test carefully and stop if you encounter issues.

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

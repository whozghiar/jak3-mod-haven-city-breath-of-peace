# Peaceful Haven City — Jak 3

<p align="center">
  <img src="https://img.shields.io/badge/OpenGOAL-Mod-blue.svg" alt="OpenGOAL Mod">
  <img src="https://img.shields.io/badge/Game-Jak%203-orange.svg" alt="Target Game">
  <img src="https://img.shields.io/badge/AI--assisted-Modding-purple.svg" alt="AI Assisted">
</p>

> **Contents:** [Overview](#overview) · [Key Features](#key-features) · [Download & Play](#download--play-via-opengoal-launcher-players) · [Developer Setup](#developer-setup--local-compilation) · [Demo Video](#demonstration-video) · [Technical Documentation](#technical-documentation)

---

## Overview
Haven City at peace in Jak 3: Freedom League guards and citizens walk every district and enemies stop spawning, with an optional Jak 2-style alert system and Freedom Fighter Hellcat patrols, all switchable from the Mods menu.

- **Target Game:** Jak 3
- **Repository:** [`whozghiar/jak3-mod-peaceful-haven-city`](https://github.com/whozghiar/jak3-mod-peaceful-haven-city), created from the modding base [`whozghiar/jak-project`](https://github.com/whozghiar/jak-project)

## Key Features
Open the Mods menu in game with **L3 + SELECT**, then **peaceful-haven-city**. Every feature starts off and can be switched on or off at any time, alone or together.

- **Peace in Haven City:** Freedom League guards patrol every district, the Metal Head zone included, and citizens walk every district except the Metal Head zone. Krimson Guard robots and Metal Heads no longer appear. Story missions that need enemies still get them.
- **Jak 2 alert system:** hurt a citizen or attack a guard and the city goes on alert, as in Jak 2: five alert levels, guards hunting you, battle music and a red-pulsing minimap. Keep fighting and the alert climbs; lie low for about 30 seconds and it ends once the guards stand down.
- **Freedom League Hellcats:** Hellcat gunships flown by Freedom League guards join the city's air traffic in every district. With the alert system on, they chase and shoot you from alert level 2, or as soon as you attack one. Press Triangle next to one to steal it, like any city car (the guards will not like it), then hold R1 to fire its front gun.
- **Busier streets:** more citizens and more guards in the streets, and more of the fat citizens among them.

## Download & Play via OpenGOAL Launcher (Players)

> [!TIP]
> **No developer environment required!** Players can install and play this mod directly using the official OpenGOAL Launcher:

### Option A — Add Custom Mod Source (Recommended)
1. In the **OpenGOAL Launcher**, navigate to **Settings ▸ Mods ▸ Add Custom Mod Source**.
2. Paste this catalog URL:
   ```text
   https://raw.githubusercontent.com/whozghiar/jak3-mod-peaceful-haven-city/main/index.json
   ```
3. Go to the **Mods** tab, locate **Peaceful Haven City**, and click **Install**.
4. Select your clean PS2 game ISO when prompted. The launcher will automatically extract assets and launch the game!

### Option B — Manual Installation from GitHub Releases
1. Download the pre-built package for your operating system from the [Releases](https://github.com/whozghiar/jak3-mod-peaceful-haven-city/releases) tab (`windows-v*.zip` or `linux-v*.zip`).
2. Extract the archive into your OpenGOAL Launcher features directory:
   - **Windows:** `%APPDATA%\OpenGOAL-Launcher\features\jak3\mods\_local\peaceful-haven-city\`
   - **Linux:** `~/.config/OpenGOAL-Launcher/features/jak3/mods/_local/peaceful-haven-city/`
3. Launch the game from the OpenGOAL Launcher.

---

## Developer Setup & Local Compilation

If you want to modify or compile this mod locally from source:

### 0. Get the Source
Already working in a clone of [`whozghiar/jak-project`](https://github.com/whozghiar/jak-project)? Switch to this mod there, keeping your extracted game data:
```bash
task modding-switch -- jak3-mod-peaceful-haven-city
```
Otherwise clone it on its own; the knowledge base used by AI agents is a submodule, so clone with it:
```bash
git clone --recurse-submodules https://github.com/whozghiar/jak3-mod-peaceful-haven-city.git
```
To pull the latest modding base into this mod later, run `task modding-sync-branch`.

### 1. Select the Active Game
Make sure your environment is targeting Jak 3:
```bash
task set-game-jak3
```

### 2. Binary Compilation
- **Status:** Not required: no C++ change, the standard binaries are enough.
- **Details:** The mod changes GOAL code and the decompiler configuration only (see step 3).
```bash
# GOAL-only mod: nothing to build — go straight to the REPL below.
# Engine / compiler C++ changed:
task build-release-game
# Decompiler or decompiler/config changed (then step 3 is mandatory):
task build-release-decomp
```

### 3. Asset Extraction
- **Status:** Required (`task extract`).
- **Details:** The Hellcat model is baked into the Freedom League guards' level (`ctypesa.fr3`) at extraction.
```bash
task extract
```

### 4. Launch the Game
Run the game natively:
```bash
task boot-game
```
*(Or launch via the OpenGOAL REPL using `task repl`, then compile and run with `(mi)` and `(r)`).*

## Demonstration Video

[![Demonstration Video](https://img.youtube.com/vi/{YOUTUBE_ID}/maxresdefault.jpg)](https://youtu.be/{YOUTUBE_ID})

**[Watch the demonstration video on YouTube](https://youtu.be/{YOUTUBE_ID})**

> [!NOTE]
> *Demonstration videos must be hosted externally on YouTube to prevent repository bloating. Replace `{YOUTUBE_ID}` with your YouTube video ID (e.g. `MnqnybexhSA` from `https://youtu.be/MnqnybexhSA`).*

## Technical Documentation
For the complete technical breakdown, architecture, developer notes and change log, refer to:
- [`docs/modding/current_mod/peaceful-haven-city_readme.md`](docs/modding/current_mod/peaceful-haven-city_readme.md)

---
*(AI-assisted)*

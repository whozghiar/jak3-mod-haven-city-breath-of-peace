# Peaceful Haven City (Jak 3): technical notes

How the mod is built: its files, the vanilla hook points, how each feature works on Jak 3's city
code, how to rebuild it, what to check in game, and the change log. Player-facing description:
the root [`README.md`](../../../README.md). GOAL patterns referenced here live in the Lisp wiki
([`.agents/skills/goal-lisp/wiki/`](../../../.agents/skills/goal-lisp/wiki/index.md)).

## 1. Features

All four ship off. They are switched in [L3 + SELECT] > Mods > `peaceful-haven-city` and can be
combined freely.

| Toggle | Effect |
|---|---|
| Peace in Haven City | Freedom League guards in every district, Metal Head zone included. Citizens in every district except the Metal Head zone. No Krimson Guard robots and no Metal Heads (traffic and flitter spawners). Steps aside while a mission drives the city's factions. |
| Jak 2 alert system | Jak 2's wanted level: hitting a civilian or attacking a guard starts an alert (levels 0-4), guards then hunt Jak, the city plays its battle music and the minimap pulses red. Every 8 kills raise the level. The alert lasts 30 s after the last offence (faster while Jak hides), then ends once no guard or Hellcat hunts anymore. |
| Freedom League Hellcats | Three Hellcats piloted by Freedom League guards fly in the city's air traffic (five from alert level 3). With the alert system on they chase and shoot Jak from alert level 2, or when he attacks one. Jak can steal one like a city car: its pilot is knocked off and turns into a guard on foot, which raises the alert to 2. |
| Busier streets | Citizen pools 16 male, 16 female, 10 fat (stock 10, 10, 3), so about one citizen in four is a fat citizen. Guard caps x1.7 (11 instead of 7 at alert level 0). Only types the story currently allows get more. |

## 2. Files

| File | DGO | Role |
|---|---|---|
| `goal_src/jak3/pc/features/peaceful-haven-city-menu.gc` | GAME | The four toggles and the Mods menu. Also the data the city code points GAME structures at (the peace borrow alias, the saved stock aliases), so nothing dangles when CWI unloads. |
| `goal_src/jak3/levels/city/peaceful-haven-city/peaceful-haven-city.gc` | CWI | All gameplay code: peace, the alert port, the `h-hellcat` class and its pilot, the crowd pools. Linked right after `ctywide-init.o`. |

Vanilla touch points, each marked `MOD peaceful-haven-city`:

| File | Change |
|---|---|
| `levels/city/common/ff-squad-control.gc` | `update` runs the mod's alert instead of `ff-squad-control-method-45` while the alert toggle is on, then calls the mod's per-frame entry point. |
| `levels/city/traffic/citizen/guard.gc` | `damage-enemy-from-attack!`: an attack by Jak on a guard raises the alert to 1 (alert toggle only). |
| `levels/city/traffic/traffic-manager.gc` | `traffic-object-spawn`: a `guard-car` case spawning `h-hellcat`. Stock never spawns `guard-car` (want-count 0). |
| `levels/city/ctywide-obs.gc` | `flitter-spawner`: no flitter while peace is enforced. |
| `dgos/game.gd`, `dgos/cwi.gd` | The two new objects. |
| `dgos/ctypesa.gd` | Hellcat texture pages 950/951 and `hellcat-ag`, art block kept sorted by decreasing size. |
| `decompiler/config/jak3/jak3_config.jsonc` | `extra_art_groups_by_dgo`: `hellcat-ag` baked into `ctypesa.fr3`. |

Jak 3's `cgo-file` finds a new `.gc` by name under `goal_src/jak3` (`set-gsrc-folder!` indexes the
tree), so `game.gp` needs no change.

## 3. How it works

### 3.1 Who spawns where

Every frame the faction manager (`cty-faction-manager`, `levels/wascity/cty-faction.gc`) answers
"may this faction spawn or walk in this territory" through `cty-faction-manager-method-14`:
`faction-array[territory]` (one of `*default-faction-info*`'s 21 entries) plus modifiers set by
story commands (`faction-strength`, at most +-5). Positive lets a faction spawn, zero lets it walk
through, negative keeps it out. Territories 18-20 are the Metal Head zone.

Peace swaps the 21 pointers for two mod entries (+60 guards, +60 citizens, -60 robots and Metal
Heads; citizens -60 in territories 18-20). No modifier can flip those signs. Story commands never
write `faction-array`, so restoring the default pointers is a full restore. The mod then flushes
the permission cache (`cty-faction-manager-method-19`) and rebuilds the territory list
(`cty-faction-manager-method-22`), which also ends any war mode.

Citizens also need their art (`ctypepa`) loaded. Which borrow levels load is set by the
`ctywide-*` aliases, rewritten by each story node. While peace is enforced, every alias that only
borrows stock city levels is switched to the stock `ctywide-ff` list (guards, cars, bikes,
citizens) and `add-borrow-levels` is called. Aliases that borrow a mission level (`lctyass`,
`lctyprot`, `lpatkcs`...) are left alone.

Peace is suspended (stock tables and aliases restored) while a mission drives the city: an open
task node with faction commands, `kg-enemy-settings` or `mh-enemy-settings`, or a
`faction-command` setting.

### 3.2 The alert

Jak 3 kept Jak 2's alert state machine as `ff-squad-control-method-45` and still raises it when
Jak hits a civilian (`citizen-method-210`), but nothing reacts to it: guards ignore `'alert-begin`,
the music and minimap pulse are gone, `*alert-level-settings*` holds one level of five (levels 1+
read past it) and `ff-squad-control-method-48` (live guard count) returns nothing, so an alert
never ends. With the toggle on, the mod's `mod-peaceful-haven-city-alert-update` replaces
method-45:

| Part | Behavior |
|---|---|
| Settings | Jak 2's five-level table in Jak 3's layout. Level 0 is Jak 3's stock level 0 (3 tazers, 3 rifles, 1 grenadier). Levels 1-4 scale Jak 2's guard counts by Jak 3's denser patrol and keep Jak 2's aim and fire timings. |
| Raise | Civilian hit by a shot or explosion, or twice in melee (stock). Any attack on a guard (mod hook). Attack on a Hellcat: level 2. Kill escalation: 8 kills per level of civilians, guards and their vehicles. |
| Hunt | Every frame of an active alert, each guard receives `'member-attacked` (Jak 3's own "angry at Jak" hatred switch) and each Hellcat `'alert-begin`. |
| End | After 30 s without offence the alert enters its ending phase: guards and Hellcats stand down (hatred reset, `'end-pursuit`, `'alert-end`) and no new guard or Hellcat activates. Three seconds after the last hunter stood down, the level drops to 0. Jak 2 waited for every guard to leave; Jak 3's denser patrols would keep that from ever happening. |
| Music | Jak 3's city battle track `fight1`, written each frame on the faction manager's own persistent key `'cty-faction-music`, so it never flickers back mid-alert. `city1` is restored at the end the way the game does it. |
| HUD | `*game-info* wanted-flash`, which still drives the red minimap ring. |
| Pool | While alerted, the guard pool is the alert's target count + 4 (traffic cap: 20 per type). |

Turning the toggle on or off resets the alert state, so an alert Jak 3 raised silently before is
not inherited.

### 3.3 The Hellcats

Jak 3 declares `h-hellcat`, maps it to traffic type `guard-car` and ships `*h-hellcat-constants*`
and `skel-h-hellcat`, but never defines the class nor loads its art (`CTYCARC`). The mod:

- defines `h-hellcat` on `h-car-base`, with the collision Jak 3's own `h-warf` uses on the same
  art, and Jak 2's front turret (joint 4) firing `guard-shot`;
- spawns a pilot, `mod-peaceful-haven-city-pilot`: a `vehicle-rider` on the Freedom League guard
  model, in the seated stance (`crimson-guard-car-stance-ja`). `crimson-guard-ag` holds every mesh
  variant at once (blue and dark guard bodies, weapons): the pilot sets the masks a guard on foot
  sets in `crimson-guard-method-267` (hide bits 1-4, show 3), without a weapon;
- ships `hellcat-ag` in `CTYPESA`, the guards' borrow level, so pilot and ship always load
  together without a fourth small borrow slot (the borrow manager caps them at 3);
- registers `vehicle-levels` slot `h-hellcat` to `ctypesa` while that level is loaded
  (`lwide-deactivate` clears it on unload) and sets the `guard-car` pool and caps each frame;
- ports Jak 2's guard-vehicle pursuit: line of sight through `squad-control-method-17`, pursuit
  through `vehicle-method-104`/`105`, intercept steering through the controller's direct mode,
  turret bursts with the alert level's Hellcat settings, give-up after 8 s out of sight;
- lets Jak steal it: `*h-hellcat-constants*` uses the city cars' pilot stance and vehicle type, so
  the stock boarding code works once the `no-hijack` flag is left off. The stock code knocks the
  pilot off (`target-pilot.gc`); his `vr3` flag turns him into a guard on foot and raises the alert
  to 2. Entering `player-control` drops the Hellcat's alert and chase, so the alert stops counting
  it as a hunter. While Jak flies it, the game holds `ctypesa` loaded (`'player-enter-vehicle`
  sets `borrow-hold-perm` to the type's level).

Without peace, Hellcats only patrol where Freedom League guards may spawn (they share the guards'
faction slot and art level).

### 3.4 Busier streets

Each pedestrian activation picks the type furthest below its cap (`target-count`, the peace-time
one), within its pool (`want-count`), which `traffic-manager-method-22` rewrites every frame from the
faction spawn level (10 male, 10 female, 3 fat by default). Stock code sets the citizens' caps only
in `restore-default-settings`, to pool - 1 from the pools of that moment: when the traffic starts
the fat citizen's pool is 1, so its cap is 0 until a later restore brings it to 2. That is why fat
citizens are rare.

With the toggle on, the mod rewrites pool and cap of the three citizen types each frame after
method-22 (16/15, 16/15, 10/9), multiplies the guard caps by 1.7 through `guard-target-level` and
gives guards a pool of cap + 4 (engine cap: 20 per type). A type whose stock pool is 0 (turned off
by the story or a mission) is left alone. Switching off restores multiplier 1.0 and caps of pool - 1.
War-mode territories keep their own caps.

## 4. Rebuild

The decompiler config changed, so a fresh clone or a switch to this mod needs the extraction:

```bash
task set-game-jak3
task extract                 # bakes hellcat-ag into out/jak3/fr3/ctypesa.fr3
task compile-check
task boot-game-retail        # Mods menu: L3 + SELECT
```

After switching from another mod, compile with the forced build described in
[Switch to another mod](../guides/repository_workflow.md#switch-to-another-mod) instead of
`task compile-check`. No C++ changes: the base binaries are enough.

## 5. In-game checks

| Check | Expected |
|---|---|
| All toggles off | Stock Haven City. |
| Peace on, in a KG or Metal Head district | Robots and Metal Heads vanish. Guards walk in. Citizens appear in KG districts, not in the Metal Head zone. |
| Peace on, start a city mission with enemies (port fight, HQ defence) | The mission's enemies spawn: peace steps aside. |
| Alert on, shoot a civilian | Minimap ring pulses red, battle music starts, guards attack Jak. |
| Alert on, wait about 30 s away from guards | Guards stand down, music and minimap return to normal. |
| Hellcats on | Hellcats with a guard at the controls fly the traffic lanes. Jak cannot board them. |
| Hellcats and alert on, shoot a Hellcat | It chases Jak and fires its front gun. |
| Hellcat pilot | Blue guard, no dark guard mesh, no weapon. |
| Steal a Hellcat (triangle) | Jak flies it; the pilot drops as a guard on foot and the alert reaches 2. |
| Busier streets on | Noticeably more citizens and guards, about one fat citizen in four. |
| Die during an alert | Respawn without the alert, Hellcats still spawn. |

## 6. Known limits

- Jak 2's Dark Jak alert triggers (transforming raised the alert) are not ported.
- Jak 2's alarm sound effect is not played: the alert uses the battle music only.
- Jak cannot fire the Hellcat's front gun nor his own gun while flying it (constants flag `#x20`
  off, unlike the city cars).
- The global launcher catalog key `peaceful-haven-city` is also the Jak 2 mod's key: on release,
  the catalog keeps one of the two (`sync_global_catalog.py` warns and the newest release wins).

## 7. Change log

| Date | Change |
|---|---|
| 2026-10-04 | First version: peace, Jak 2 alert system, Freedom League Hellcats. Compiles (forced build, 3508 targets), `hellcat-ag` baked into `ctypesa.fr3`. Played by the user: the three features work. Open: the pilot shows every guard mesh variant at once, and Jak can hang on a Hellcat but not fly it. |
| 2026-10-04 | Pilot shows a regular blue guard (guard mesh masks). Hellcats can be stolen (no `no-hijack`; alert dropped on boarding). New toggle "Busier streets": bigger citizen and guard pools, about one fat citizen in four. Played by the user: all three work, engine sound fine while Jak flies a Hellcat. |

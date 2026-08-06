# Changelog

## 1.5.0

- **TomTom support**: when TomTom is installed, every Pin button sets a TomTom crazy-arrow waypoint (cross-zone, queueable) instead of the native map pin. Without TomTom nothing changes.
- Corrected the Cypher Research Console pin: it now points at Firim's spot in Exile's Hollow (34.1, 48.3) instead of a nearby cave landmark.

- The unlock chain now shows **all four Cypher Console researches** as separate steps: Metrial (5 Cyphers, instant, completes with the campaign quest), Aealic (45 Cyphers, 18h), Dealic (3d 18h, also opens Pocopoc's pet-forge quest -- not needed for mounts), Sopranian (220 Cyphers, 5d 18h).
- **Research state is now read live from the game** via the Cypher Console talent tree (ID 474): researched, researching (with time remaining shown), or not started. Nodes are identified by research duration, so this works on any client language. When the tree API returns nothing, the old quest-log inference still applies.
- `/zmm research` prints what the console tree reports -- use it to verify the detection on your character.

## 1.4.0

- **Craft alert.** The moment you have everything for a mount -- recipe owned, every reagent in the bag, mount not yet collected -- a small popup appears. No sound, no screen-centre banner: it fades out on its own, is draggable, and clicking it jumps straight to that mount.
- Only genuinely new opportunities fire, so spending mats and re-earning them alerts you again, and logging in does not dump a stack of popups.
- `/zmm alerts` turns the popup off and on. `/zmm reset` moves it back to the top of the screen.

## 1.3.0

- New **Schematics** tab: every recipe and where it comes from, grouped by source -- lying in the world, mob drop, reputation cache, inside the Sepulcher, quest reward, puzzle -- so you can plan one sweep instead of clicking through 24 mounts.
- **The addon now knows which recipes you own.** Each schematic starts a Schematic Reassimilation quest, and that hand-in is readable, so every mount shows `recipe owned` / `recipe missing` for real instead of guessing.
- Header counter for recipes owned, and a `recipe owned` marker on the Mounts tab.
- **Always-visible forge pin** in the window header: one click drops a waypoint on the Protoform Repository from any tab.

## 1.2.0

- New **Tips** tab: nine concrete recommendations for getting there faster -- where motes actually drop in bulk, why the weekly is the best 20 minutes in the zone, which reagents are Warband-bound and Unique-capped, which "raid" reagents need no raid at all, and which mounts are cheapest to knock out first.
- **Corrected the unlock chain**: Sopranian Understanding sits inside the *Dealic* research tree, so the gate order is Metrial -> Aealic -> Dealic Understanding -> Sopranian Understanding. The earlier text named the wrong prerequisites.
- The unlock chain now states that the pet forge is a separate unlock and is not required for mounts.
- Added the step everyone misses: each looted schematic starts a **Schematic Reassimilation** quest that must be turned in at the Servitor Interface before that mount appears in the forge.

## 1.1.0

- New **Unlock chain** tab: the full path to unlocking mount crafting, from the Zereth Mortis campaign through the Cypher Research Console to the eleven-quest Finding Tahli / A New Architect chain.
- Every step shows its live state read from your quest log: done, in progress (you are here), next step, or locked.
- The header states plainly whether mount crafting is unlocked on the current character.
- Each step has a Pin button for the quest giver's location.

## 1.0.0

First release.

- Tracks all 24 Protoform Synthesis mounts from Zereth Mortis.
- Shows which mounts you have already learned, read from the Mount Journal.
- Live reagent counts (bags, bank, reagent bank, warband bank) for Genesis Motes, the lattice and the rare reagent.
- Farm notes for every reagent, and the schematic source for every mount.
- "Pin" buttons drop a Zereth Mortis map waypoint and start super-tracking it.
- Filters: All / Not learned / Craftable now.
- Draggable minimap button, `/zmm` slash command.

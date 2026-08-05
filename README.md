# Zereth Mortis Mounts

A small World of Warcraft addon that tracks every **Protoform Synthesis** mount from Zereth Mortis
(patch 9.2, Eternity's End) — all 24 of them.

One minimap button, one window. No dependencies, no libraries.

## What it shows

- **All 24 mounts**, with a green check for the ones you have already learned and a red cross for the rest.
- **Live reagent counts** for the mount you select: Genesis Motes, the lattice, and the rare reagent — `have / need`, green when satisfied. Counts include your bags, bank, reagent bank and warband bank.
- **Where to farm** every reagent, and **where to find the schematic** that unlocks the recipe.
- **Click "Pin"** next to any line to drop a map waypoint in Zereth Mortis and start super-tracking it (the arrow on your minimap). Lines that are not out in the world — vendors, paragon caches, raid drops — have the Pin button greyed out and explain the source in text instead.
- Header summary: how many you have learned, how many you can craft **right now** with what is in your bags, your current Genesis Motes, and how many motes the remaining mounts still cost.
- Filters: **All** / **Not learned** / **Craftable now**.

Everything is crafted at the **Protoform Repository** (`68.5, 30.1`, Arrangement Index) — there is a Pin button for that too.

## Install

Copy the `ZerethMortisMounts` folder into:

```
<World of Warcraft>/_retail_/Interface/AddOns/ZerethMortisMounts
```

Then `/reload` or restart the game. Files must sit directly inside that folder (`ZerethMortisMounts/ZerethMortisMounts.toc`, not nested one level deeper).

## Usage

- Click the minimap button (Genesis Mote icon) to open and close the window. Drag it to move it around the minimap ring; the position is saved.
- `/zmm` or `/zerethmounts` does the same.
- Escape closes the window; drag its background to move it.
- Hover a mount in the list for its normal item tooltip; hover a reagent for the reagent's tooltip.

## Notes

- `## Interface: 120007` in the `.toc` (client 12.0.7). If a patch makes the client report the addon as out of date, set that number to your live client's interface version (`/run print(select(4, GetBuildInfo()))` in game) — nothing else needs to change.
- Recipes (mote cost, lattice, rare reagent, spell/item IDs) come from the per-mount recipe listings on warcraft.wiki.gg and are exact.
- Map coordinates are community reference points and are **approximate** — they put you in the right spot to look around, not on the pixel. Some schematics (Serenade, Curious Crystalsniffer) are inside Sepulcher of the First Ones and some come from caches or quests, so they have no world pin at all.
- "Learned" means the mount is in your Mount Journal, which is what actually matters for collection. The addon does not try to guess whether you have merely looted the schematic.

## Files

| File | Purpose |
| --- | --- |
| `ZerethMortisMounts.toc` | Addon manifest |
| `Data.lua` | The 24 recipes, reagent sources, coordinates |
| `Core.lua` | Item counts, mount-journal lookups, waypoints, events, slash command |
| `UI.lua` | The window and the minimap button |

-- Zereth Mortis Mounts :: static data
-- Every recipe below (mote cost, lattice, rare reagent, spell/item IDs) was taken from
-- the per-mount recipe listings on warcraft.wiki.gg. Map coordinates are community
-- reference points and are approximate -- treat them as "go here and look around".

local ADDON, ns = ...

ns.MAP_ID = 1970 -- Zereth Mortis
ns.MOTE_ITEM = 188957 -- Genesis Mote

-- The mount forge. Everything is crafted here.
ns.FORGE = { name = "Protoform Repository", x = 68.5, y = 30.1, note = "Arrangement Index, north-east Zereth Mortis" }

-- itemID -> { label, how (where to farm), x, y (optional map pin) }
ns.reagents = {
	[188957] = {
		label = "Genesis Mote",
		how = "Drops from nearly every mob in Zereth Mortis. Fastest farm: devourers pouring out of the portals around Droning Precipice / Pilgrim's Grace, where the Automa NPCs help you kill them. Also rewarded by |cffffff00A New Architect|r and by Olea Cache from the weekly |cffffff00Patterns Within Patterns|r.",
		x = 61.8, y = 58.9,
	},

	-- Lattices (the body -- one per creature family)
	[187633] = { label = "Bufonid Lattice",  how = "Drops from bufonids (the frogs) in Zereth Mortis and in Sepulcher of the First Ones. Chance from Olea Cache.", x = 49.8, y = 73.1 },
	[189500] = { label = "Cervid Lattice",   how = "Drops from cervids in Zereth Mortis. One guaranteed drop from the Repository Vault inside the Protoform Repository. Chance from Olea Cache.", x = 55.7, y = 80.6 },
	[189145] = { label = "Helicid Lattice",  how = "Drops from helicids (the snails) in Zereth Mortis. Chance from Olea Cache.", x = 56.4, y = 82.6 },
	[190388] = { label = "Lupine Lattice",   how = "Drops from lupines in Zereth Mortis. Chance from Olea Cache.", x = 39.0, y = 55.5 },
	[189150] = { label = "Raptora Lattice",  how = "Drops from raptora (the hawk-like birds) around the Plain of Actualization and the western grasslands. Chance from Olea Cache." },
	[189152] = { label = "Tarachnid Lattice", how = "Drops from tarachnids in Zereth Mortis and from Tarachnid Eggs treasures. Chance from Olea Cache.", x = 56.9, y = 34.2 },
	[189154] = { label = "Vespoid Lattice",  how = "Drops from vespoids in Zereth Mortis. Best density is Droning Precipice, just south of Pilgrim's Grace -- low health, quick respawns. Chance from Olea Cache.", x = 52.7, y = 42.2 },
	[189156] = { label = "Vombata Lattice",  how = "Drops from vombata in Zereth Mortis. Chance from Olea Cache.", x = 45.1, y = 67.0 },

	-- Rare reagents (the soul)
	[189171] = { label = "Bauble of Pure Innovation", how = "One sits in Qie's bed inside Exile's Hollow. Also from Olea Cache. Unique (2).", x = 34.5, y = 49.7 },
	[189174] = { label = "Lens of Focused Intention", how = "Sold by |cffffff00Vilo|r in Haven for 40g. Requires Revered with The Enlightened. Unique (2)." },
	[189172] = { label = "Crystallized Echo of the First Song", how = "Looted from crystals with a music symbol floating above them, on the Sepulcher island in eastern Zereth Mortis. Also from Olea Cache. Unique (3).", x = 77.5, y = 59.0 },
	[189173] = { label = "Eternal Ragepearl", how = "Drops from elite automa in Zereth Mortis and in Sepulcher of the First Ones. Very rarely from Olea Cache. Unique (2)." },
	[189175] = { label = "Mawforged Bridle", how = "Looted from the High Value Cache in Sepulcher of the First Ones. Small chance from Olea Cache." },
	[189176] = { label = "Protoform Sentience Crown", how = "Drops from elite mobs in Zereth Mortis and Sepulcher of the First Ones -- the dominated elites on Antecedent Isle are the usual farm. Small chance from Olea Cache." },
	[189177] = { label = "Revelation Key", how = "Drops from the rare |cffffff00Protector of the First Ones|r in Zereth Mortis." },
	[189178] = { label = "Tools of Incomprehensible Experimentation", how = "Drops from Lihuvim, Principal Architect in Sepulcher of the First Ones." },
	[189179] = { label = "Unalloyed Bronze Ingot", how = "Drops from |cffffff00Requisites Originator|r in the Repertory Alcove. Also from Olea Cache. Unique (2)." },
	[189180] = { label = "Wind's Infinite Call", how = "Drops from Enhanced Avian on the Sepulcher island in eastern Zereth Mortis. Low chance from Olea Cache.", x = 77.0, y = 57.0 },
}

-- The unlock chain for MOUNT crafting.
-- Research at the Cypher Research Console cannot be read reliably from the API,
-- so the research step is inferred: it is certainly done once any quest of the
-- chain has been picked up. Quest steps use IsQuestFlaggedCompleted/IsOnQuest.
ns.UNLOCK_SPELL = 366367 -- Protoform Synthesis (Mount) -- known == craft unlocked

-- Chain quest IDs, used to infer that the research step is behind us.
ns.CHAIN_QUESTS = { 64829, 64745, 64759, 64761, 64762, 64763, 64766, 64767, 65420, 65426, 65427 }

-- Step types:
--   quest    -- tracked directly via the quest log
--   infer    -- cannot be read from the API; done once any quest in inferQuests
--               has been completed or picked up
--   research -- a Cypher Console node, read live from garrison talent tree 474;
--               `duration` (research seconds) identifies the node in any locale.
--               Falls back to inferQuests when the tree API returns nothing.
-- x/y put a Pin button on the row. NPC coordinates are approximate.
ns.unlockChain = {
	{ type = "infer", inferQuests = { 64230 }, title = "Zereth Mortis campaign, chapters 1-2",
	  note = "\"Into the Unknown\" and \"We Battle Onward\". Starts from the call board / Oribos. Just follow the campaign." },
	{ type = "quest", id = 64230, title = "Cyphers of the First Ones  (campaign, ch. 3)",
	  note = "Ninth quest of \"Forming an Understanding\", from Firim in Exile's Hollow. Unlocks Pocopoc, the Cypher Research Console, world quests and the weekly Patterns Within Patterns.",
	  x = 34.0, y = 48.1, pinLabel = "Firim, Exile's Hollow" },
	{ type = "research", duration = 0, inferQuests = { 64230 }, inferCompletedOnly = true,
	  title = "Research: Metrial Understanding",
	  note = "The first console node -- researching it is an objective of Cyphers of the First Ones, so it completes with that quest. 5 Cyphers, instant.",
	  x = 34.5, y = 49.7, pinLabel = "Cypher Research Console, Exile's Hollow" },
	{ type = "research", duration = 64800, inferQuests = ns.CHAIN_QUESTS,
	  title = "Research: Aealic Understanding",
	  note = "45 Cyphers, 18 hours of research. Queue it the moment Metrial completes -- the timer keeps running while you are offline.",
	  x = 34.5, y = 49.7, pinLabel = "Cypher Research Console, Exile's Hollow" },
	{ type = "research", duration = 324000, inferQuests = ns.CHAIN_QUESTS,
	  title = "Research: Dealic Understanding",
	  note = "3 days 18 hours of research. Completing it also lets |cffffff00Pocopoc|r offer the Protoform Synthesis quest -- that unlocks the PET forge. Nice bonus, but NOT required for mounts.",
	  x = 34.5, y = 49.7, pinLabel = "Cypher Research Console, Exile's Hollow" },
	{ type = "research", duration = 496800, inferQuests = ns.CHAIN_QUESTS,
	  title = "Research: Sopranian Understanding",
	  note = "220 Cyphers, 5 days 18 hours -- the longest wait in the whole unlock; it sits inside the Dealic tree. When it finishes, Elder Amir offers Finding Tahli.",
	  x = 34.5, y = 49.7, pinLabel = "Cypher Research Console, Exile's Hollow" },
	{ type = "quest", id = 64829, title = "Finding Tahli",
	  note = "From Elder Amir at Pilgrim's Grace (an Ancient Translocator leads there). Find Tahli near the Arrangement Index.",
	  x = 60.0, y = 53.0, pinLabel = "Elder Amir, Pilgrim's Grace (approx.)" },
	{ type = "quest", id = 64745, title = "Selfless Preservation",
	  note = "From Tahli, at the ruins buried under the sands near the Arrangement Index.",
	  x = 64.2, y = 30.5, pinLabel = "Tahli, Arrangement Index (approx.)" },
	{ type = "quest", id = 64759, title = "Junk's Not Dead",
	  note = "From Tahli. Obtain glyphs from 6 Depleted Servitors around the Arrangement Index. Runs together with Core Competency.",
	  x = 64.2, y = 30.5, pinLabel = "Tahli, Arrangement Index (approx.)" },
	{ type = "quest", id = 64761, title = "Core Competency",
	  note = "From Tahli. Charge a Depleted Automa Core by draining slain wild creatures.",
	  x = 64.2, y = 30.5, pinLabel = "Tahli, Arrangement Index (approx.)" },
	{ type = "quest", id = 64762, title = "Revival of the Fittest",
	  note = "From Tahli. Revive the Hidden Servitor with the charged core; turns in to Kodah.",
	  x = 64.2, y = 30.5, pinLabel = "Tahli, Arrangement Index (approx.)" },
	{ type = "quest", id = 64763, title = "Maintenance Mode",
	  note = "Follow-up at the Arrangement Index. Runs together with Access Request.",
	  x = 64.2, y = 30.5, pinLabel = "Arrangement Index (approx.)" },
	{ type = "quest", id = 64766, title = "Access Request",
	  note = "Runs together with Maintenance Mode.",
	  x = 64.2, y = 30.5, pinLabel = "Arrangement Index (approx.)" },
	{ type = "quest", id = 64767, title = "The Final Song",
	  note = "From Kodah: defend him and restore the Protoform Repository. Turns in to Tahli.",
	  x = 68.5, y = 30.1, pinLabel = "Protoform Repository" },
	{ type = "quest", id = 65420, title = "Judgment Call",
	  note = "From Tahli; speak to Elder Amir in Pilgrim's Grace.",
	  x = 60.0, y = 53.0, pinLabel = "Elder Amir, Pilgrim's Grace (approx.)" },
	{ type = "quest", id = 65426, title = "The Lost Component",
	  note = "Recover the missing forge component near the Protoform Repository.",
	  x = 68.5, y = 30.1, pinLabel = "Protoform Repository" },
	{ type = "quest", id = 65427, title = "A New Architect",
	  note = "Final step, at the Servitor Interface inside the Protoform Repository. Rewards the mount forge, 450 Genesis Motes, a Cervid Lattice, Tools of Incomprehensible Experimentation and Schematic: Deathrunner.",
	  x = 68.5, y = 30.1, pinLabel = "Servitor Interface, Protoform Repository" },
	{ type = "note", title = "Then: one \"Schematic Reassimilation\" per mount",
	  note = "Looting a schematic is not enough. Each one starts a quest |cffffff00Schematic Reassimilation: <mount>|r that you turn in at the Servitor Interface in the Protoform Repository -- only then does that mount appear in the forge. If a schematic is sitting unused in your bags, this is why.",
	  x = 68.5, y = 30.1, pinLabel = "Servitor Interface, Protoform Repository" },
}


-- Farming advice shown on the Tips tab.
ns.tips = {
	{ title = "Genesis Motes: devourers, not wildlife",
	  body = "Motes are the real bottleneck -- 9,850 for all 24 mounts. Wildlife drops a trickle; the devourers that spawn from the invasion portals drop far more, come in dense packs and the Automa NPCs tank them for you. Park at a portal, AoE, repeat. Droning Precipice south of Pilgrim's Grace is the usual spot.",
	  x = 61.8, y = 58.9, pinLabel = "Devourer farm, Droning Precipice" },
	{ title = "Do the weekly before anything else",
	  body = "|cffffff00Patterns Within Patterns|r rewards an Olea Cache, which can contain ANY lattice and most rare reagents, plus ~140 Cyphers. It is the single highest-value 20 minutes in the zone and it is weekly, so never skip it. It also drops Tribute of the Enlightened Elders, the only source of Schematic: Bronze Helicid." },
	{ title = "Lattices: farm the accelerated / matron versions",
	  body = "Normal critters drop lattices rarely. The named-up variants (Accelerated Bufonid, Accelerated Helicid, Vombata Matron, Vespoid Overseer) have a much better rate. Kill those on sight and ignore the rest -- and remember lattices stack to 20 and are Warband-bound, so bank extras for alts." },
	{ title = "Warband-bound reagents: buy on alts too",
	  body = "The rare reagents bind to Warband, not to character. Lens of Focused Intention is sold by Vilo for 40g and is Unique (2) -- buy your two, craft, buy again. Bauble of Pure Innovation, Unalloyed Bronze Ingot and Eternal Ragepearl are also Unique (2), and Crystallized Echo of the First Song is Unique (3): craft to free the slot before farming another." },
	{ title = "Sepulcher island reagents need no raid lockout",
	  body = "Wind's Infinite Call (Enhanced Avian) and Crystallized Echo of the First Song (the humming crystals) are out in the open on the eastern Sepulcher island, not inside the raid. Only Tools of Incomprehensible Experimentation (Lihuvim) and Mawforged Bridle (High Value Cache) actually require going into the Sepulcher.",
	  x = 77.2, y = 57.5, pinLabel = "Sepulcher island reagents" },
	{ title = "Sepulcher can be soloed at current gear",
	  body = "The two raid-only reagents come from LFR-difficulty content that is trivial at modern item levels. Run it on Raid Finder, or solo the earlier bosses. Lihuvim is the eighth boss, so LFR wing 3 is what you want for the Tools." },
	{ title = "Start Sopranian research immediately",
	  body = "The research timer (~5d 18h) runs whether you are online or not, and it is the longest single wait in the whole unlock. Queue it the moment Dealic Understanding finishes, then go farm motes while it ticks. Cyphers come fastest from the weekly (~140), Antros (~80) and dailies (~15 each)." },
	{ title = "Treasure schematics are one-time and account-wide-ish",
	  body = "Schematics that sit in the world (Vespoid Flutterer, Genesis Crawler, Scarlet Helicid and friends) are a single pickup each -- grab every one in a single sweep of the zone with the Pin buttons on the Mounts tab. Mob-drop schematics (Goldplate Bufonid, Mawdapted Raptora, Buzz) are the grindy ones; farm them while you are killing things for motes anyway." },
	{ title = "Cheapest mounts first",
	  body = "If you just want mount count, do the 300-mote recipes first: Reins of the Sundered Zerethsteed and Unsuccessful Prototype Fleetpod. Then the 350s. Buzz, Serenade, Ineffable Skitterer and Heartbond Lupine cost 500 each -- leave them for last." },
}

-- All 24 Protoform Synthesis mounts.
-- motes / lattice / rare = the exact recipe. schematic = how you unlock the recipe.
ns.mounts = {
	-- Vombata
	{ name = "Adorned Vombata", spellID = 359232, itemID = 187632, family = "Vombata", flying = false,
	  motes = 450, lattice = 189156, rare = 189174,
	  schematic = { itemID = 189478, how = "Inside the |cffffff00Grateful Boon|r treasure.", x = 37.2, y = 78.3 } },
	{ name = "Curious Crystalsniffer", spellID = 359230, itemID = 187630, family = "Vombata", flying = false,
	  motes = 400, lattice = 189156, rare = 189172,
	  schematic = { itemID = 189476, how = "Inside Sepulcher of the First Ones -- second room (the Halondrus approach), north side near the large Zereth-style sphere." } },
	{ name = "Darkened Vombata", spellID = 359231, itemID = 187631, family = "Vombata", flying = false,
	  motes = 450, lattice = 189156, rare = 189175,
	  schematic = { itemID = 189477, how = "In a cage at the Arrangement Index.", x = 64.2, y = 35.6 } },

	-- Bufonid
	{ name = "Goldplate Bufonid", spellID = 359413, itemID = 187683, family = "Bufonid", flying = false,
	  motes = 400, lattice = 187633, rare = 189171,
	  schematic = { itemID = 189468, how = "Low drop chance from |cffffff00Accelerated Bufonid|r mobs.", x = 49.8, y = 73.1 } },
	{ name = "Russet Bufonid", spellID = 363706, itemID = 188810, family = "Bufonid", flying = false,
	  motes = 350, lattice = 187633, rare = 189174,
	  schematic = { itemID = 189471, how = "From |cffffff00Enlightened Broker Supplies|r -- the paragon cache for The Enlightened." } },
	{ name = "Prototype Leaper", spellID = 363703, itemID = 188809, family = "Bufonid", flying = false,
	  motes = 350, lattice = 187633, rare = 189178,
	  schematic = { itemID = 189469, how = "From the |cffffff00Forgotten Proto-Vault|r treasure.", x = 67.0, y = 69.4 } },

	-- Cervid
	{ name = "Deathrunner", spellID = 359278, itemID = 187638, family = "Cervid", flying = false,
	  motes = 450, lattice = 189500, rare = 189178,
	  schematic = { itemID = 189457, how = "Reward from the level 60 quest |cffffff00A New Architect|r (Zereth Mortis campaign)." } },
	{ name = "Pale Regal Cervid", spellID = 342671, itemID = 187639, family = "Cervid", flying = false,
	  motes = 400, lattice = 189500, rare = 189176,
	  schematic = { itemID = 189455, how = "Unlocked automatically by the achievement |cffffff00Cyphers of the First Ones|r." } },
	{ name = "Reins of the Sundered Zerethsteed", spellID = 359277, itemID = 187641, family = "Cervid", flying = false,
	  motes = 300, lattice = 189500, rare = 189175,
	  schematic = { itemID = 189456, how = "From a |cffffff00Mawsworn Cache|r -- one sits between the cages at the Arrangement Index.", x = 60.6, y = 30.6 } },

	-- Helicid
	{ name = "Bronze Helicid", spellID = 359376, itemID = 187670, family = "Helicid", flying = false,
	  motes = 400, lattice = 189145, rare = 189179,
	  schematic = { itemID = 189462, how = "From |cffffff00Tribute of the Enlightened Elders|r, the reward chest of the weekly |cffffff00Patterns Within Patterns|r." } },
	{ name = "Scarlet Helicid", spellID = 359378, itemID = 187672, family = "Helicid", flying = false,
	  motes = 350, lattice = 189145, rare = 189177,
	  schematic = { itemID = 189464, how = "On Antecedent Isle, on top of the big arch on the left-hand side.", x = 47.7, y = 9.5 } },
	{ name = "Serenade", spellID = 346719, itemID = 187669, family = "Helicid", flying = false,
	  motes = 500, lattice = 189145, rare = 189172,
	  schematic = { itemID = 189461, how = "Inside Sepulcher of the First Ones -- first room, under the platform, between the hanging chains." } },
	{ name = "Unsuccessful Prototype Fleetpod", spellID = 359377, itemID = 187671, family = "Helicid", flying = false,
	  motes = 300, lattice = 189145, rare = 189178,
	  schematic = { how = "Reward from the Locus Shift puzzle in the Camber Alcove." } },

	-- Lupine
	{ name = "Heartbond Lupine", spellID = 367673, itemID = 190580, family = "Lupine", flying = true,
	  motes = 500, lattice = 190388, rare = 189172,
	  schematic = { how = "Drops from |cffffff00Maw-Frenzied Lupine|r inside the Choral Residium cave.", x = 52.8, y = 63.6 } },

	-- Raptora
	{ name = "Desertwing Hunter", spellID = 342668, itemID = 187666, family = "Raptora", flying = true,
	  motes = 400, lattice = 189150, rare = 189180,
	  schematic = { how = "On top of a tall pillar in the Plain of Actualization.", x = 62.0, y = 43.5 } },
	{ name = "Mawdapted Raptora", spellID = 359372, itemID = 187667, family = "Raptora", flying = true,
	  motes = 350, lattice = 189150, rare = 189175,
	  schematic = { how = "Low drop chance from |cffffff00Mawsworn Hulk|r mobs.", x = 61.0, y = 24.0 } },
	{ name = "Raptora Swooper", spellID = 359373, itemID = 187668, family = "Raptora", flying = true,
	  motes = 450, lattice = 189150, rare = 189173,
	  schematic = { how = "In a cave in the Chamber of Shaping.", x = 67.4, y = 40.2 } },

	-- Tarachnid
	{ name = "Genesis Crawler", spellID = 359401, itemID = 187677, family = "Tarachnid", flying = false,
	  motes = 400, lattice = 189152, rare = 189171,
	  schematic = { how = "On top of the doorway of the Genesis Alcove.", x = 34.4, y = 50.3 } },
	{ name = "Ineffable Skitterer", spellID = 359403, itemID = 187679, family = "Tarachnid", flying = false,
	  motes = 500, lattice = 189152, rare = 189176,
	  schematic = { how = "Inside Exile's Hollow -- you must enter as a ghost by talking to |cffffff00Shade of Irik-tu|r.", x = 34.5, y = 48.7 } },
	{ name = "Tarachnid Creeper", spellID = 359402, itemID = 187678, family = "Tarachnid", flying = false,
	  motes = 450, lattice = 189152, rare = 189177,
	  schematic = { how = "Inside a building, behind a blocked door in the northern ruins.", x = 63.0, y = 21.5 } },

	-- Vespoid
	{ name = "Bronzewing Vespoid", spellID = 359364, itemID = 187663, family = "Vespoid", flying = true,
	  motes = 350, lattice = 189154, rare = 189179,
	  schematic = { how = "Inside the Gravid Repose cave.", x = 48.9, y = 40.4 } },
	{ name = "Buzz", spellID = 359366, itemID = 187665, family = "Vespoid", flying = true,
	  motes = 500, lattice = 189154, rare = 189176,
	  schematic = { how = "From |cffffff00Pulp-Covered Relic|r objects around the vespoid nests.", x = 52.7, y = 42.2 } },
	{ name = "Forged Spiteflyer", spellID = 359367, itemID = 187664, family = "Vespoid", flying = true,
	  motes = 450, lattice = 189154, rare = 189173,
	  schematic = { how = "Sticking out of a vespoid hive.", x = 53.3, y = 25.7 } },
	{ name = "Vespoid Flutterer", spellID = 342678, itemID = 187660, family = "Vespoid", flying = true,
	  motes = 400, lattice = 189154, rare = 189180,
	  schematic = { how = "Under a pile of sand at the base of a pillar.", x = 50.3, y = 27.1 } },
}

-- Per-mount schematic metadata, merged into ns.mounts[].schematic below.
--   [1] the "Schematic Reassimilation: <mount>" quest the schematic starts.
--       Completing it is what actually puts the recipe in the forge, and it is
--       readable via C_QuestLog.IsQuestFlaggedCompleted -- so we can tell you
--       whether you already own the recipe.
--   [2] source bucket, used to group the Schematics tab.
ns.SOURCE_TYPES = {
	{ key = "treasure", label = "Lying in the world -- one pickup each",
	  hint = "Go get these first: they are guaranteed, not RNG. One sweep of the zone with the Pin buttons clears the lot." },
	{ key = "mob", label = "Mob drops -- low chance, farm while you grind motes",
	  hint = "No shortcut. Kill these while farming Genesis Motes anyway." },
	{ key = "cache", label = "Reputation and weekly caches",
	  hint = "Gated by time, not effort. Do the weekly every week and the paragon boxes will follow." },
	{ key = "raid", label = "Inside Sepulcher of the First Ones",
	  hint = "Raid Finder is enough. Both are pickups in the open, not boss drops." },
	{ key = "quest", label = "Quest and achievement rewards",
	  hint = "Handed to you by progression. Nothing to farm." },
	{ key = "puzzle", label = "Puzzle reward",
	  hint = "The Locus Shift minigame. Solve it once." },
}

local SCHEMATIC_META = {
	["Adorned Vombata"]                   = { 65401, "treasure" },
	["Curious Crystalsniffer"]            = { 65399, "raid" },
	["Darkened Vombata"]                  = { 65400, "treasure" },
	["Goldplate Bufonid"]                 = { 65391, "mob" },
	["Russet Bufonid"]                    = { 65394, "cache" },
	["Prototype Leaper"]                  = { 65393, "treasure" },
	["Deathrunner"]                       = { 65380, "quest" },
	["Pale Regal Cervid"]                 = { 65375, "quest" },
	["Reins of the Sundered Zerethsteed"] = { 65379, "treasure" },
	["Bronze Helicid"]                    = { 65385, "cache" },
	["Scarlet Helicid"]                   = { 65387, "treasure" },
	["Serenade"]                          = { 65384, "raid" },
	["Unsuccessful Prototype Fleetpod"]   = { 65386, "puzzle" },
	["Heartbond Lupine"]                  = { 65680, "mob" },
	["Desertwing Hunter"]                 = { 65381, "treasure" },
	["Mawdapted Raptora"]                 = { 65382, "mob" },
	["Raptora Swooper"]                   = { 65383, "treasure" },
	["Genesis Crawler"]                   = { 65388, "treasure" },
	["Ineffable Skitterer"]               = { 65390, "treasure" },
	["Tarachnid Creeper"]                 = { 65389, "treasure" },
	["Bronzewing Vespoid"]                = { 65396, "treasure" },
	["Buzz"]                              = { 65397, "mob" },
	["Forged Spiteflyer"]                 = { 65398, "treasure" },
	["Vespoid Flutterer"]                 = { 65395, "treasure" },
}

for _, mount in ipairs(ns.mounts) do
	local meta = SCHEMATIC_META[mount.name]
	mount.schematic.quest = meta[1]
	mount.schematic.srcType = meta[2]
end

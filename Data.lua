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
-- x/y put a Pin button on the row. NPC coordinates are approximate.
ns.unlockChain = {
	{ type = "infer", inferQuests = { 64230 }, title = "Zereth Mortis campaign, chapters 1-2",
	  note = "\"Into the Unknown\" and \"We Battle Onward\". Starts from the call board / Oribos. Just follow the campaign." },
	{ type = "quest", id = 64230, title = "Cyphers of the First Ones  (campaign, ch. 3)",
	  note = "Ninth quest of \"Forming an Understanding\", from Firim in Exile's Hollow. Unlocks Pocopoc, the Cypher Research Console, world quests and the weekly Patterns Within Patterns.",
	  x = 34.0, y = 48.1, pinLabel = "Firim, Exile's Hollow" },
	{ type = "infer", inferQuests = ns.CHAIN_QUESTS, title = "Cypher Research: Sopranian Understanding",
	  note = "At the Cypher Research Console in Exile's Hollow. Needs the earlier tiers (Metrial, Aealic, Dealic) first; Sopranian Understanding itself costs 220 Cyphers and researches for ~5 days 18 hours. When it finishes, Elder Amir offers the next quest.",
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

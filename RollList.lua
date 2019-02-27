-------------------------------------------------------------------------------
-- Dice Master (C) 2019 <The League of Lordaeron> - Moon Guard
-------------------------------------------------------------------------------
--

--
-- The roll options list
-- name			Name of the roll option
-- subName		Pattern for subbing text in description tooltips
-- wheelName	Name to display on the Roll Wheel
-- desc			Description of the roll option
-- stat			Statistic used as a modifier
--

DiceMaster4.RollList = {
	["Combat Actions"] = {
		{
			name = "Melee Attack",
			subName = "Melee Attack[s]*",
			wheelName = "Melee|nAttack",
			desc = "Roll to strike an enemy with a melee weapon.", 
			stat = "Strength",
		},
		{
			name = "Ranged Attack",
			subName = "Ranged Attack[s]*",
			wheelName = "Ranged|nAttack",
			desc = "Roll to strike an enemy with a ranged weapon.", 
			stat = "Dexterity",
		},
		{
			name = "Spell Attack",
			subName = "Spell Attack[s]*",
			wheelName = "Spell|nAttack",
			desc = "Roll to cast an spell upon an enemy.", 
			stat = "Intelligence",
		},
		{
			name = "Defence",
			subName = "[Spell]*%s?Defen[cs]e[s]*",
			desc = "Roll to defend yourself from enemy damage.",
			stat = "Constitution",
		},
		{
			name = "Spell Defence",
			subName = "Spell Defen[cs]e[s]*",
			desc = "Roll to defend yourself from enemy spell damage.",
			stat = "Intelligence",
		},
	},
	["Skills"] = {
		{
			name = "Athletics",
			subName = "Athletics",
			wheelName = "Athle.",
			desc = "Roll to swim, climb, flee, fly, or outrun someone.", 
			stat = "Strength",
		},
		{
			name = "Bluff",
			subName = "Bluff",
			desc = "Roll to deceive, trick, or lie to someone.", 
			stat = "Charisma",
		},
		{
			name = "Diplomacy",
			subName = "Diplomacy",
			wheelName = "Diplom.",
			desc = "Roll to persuade or win favour with someone.", 
			stat = "Charisma",
		},
		{
			name = "Disable Device",
			subName = "Disable Device",
			wheelName = "Disable|nDevice",
			desc = "Roll to disarm a trap or disable a lock.", 
			stat = "Dexterity",
		},
		{
			name = "Disguise",
			subName = "Disguise",
			desc = "Roll to change your appearance.", 
			stat = "Charisma",
		},
		{
			name = "Escape",
			subName = "Escape",
			wheelName = "Escape",
			desc = "Roll to slip bonds and escape from grapples.", 
			stat = "Dexterity",
		},
		{
			name = "Grapple",
			subName = "Grapple[s]*",
			desc = "Roll to disarm or disable an enemy.", 
			stat = "Strength",
		},
		{
			name = "Healing",
			subName = "Heal[sing]*%A",
			wheelName = "Heal",
			desc = "Roll to mend wounds or restore health to someone.", 
			stat = "Wisdom",
		},
		{
			name = "Insight",
			subName = "Insight",
			wheelName = "Sense|nMotive",
			desc = "Roll to discern intent or decipher body language.", 
			stat = "Wisdom",
		},
		{
			name = "Intimidation",
			subName = "Intimidat[esion]*%A",
			wheelName = "Coerce",
			desc = "Roll to taunt, coerce, or frighten someone.", 
			stat = "Charisma",
		},
		{
			name = "Knowledge",
			subName = "Knowledge",
			desc = "Roll to determine your education or understanding of a particular topic.", 
			stat = "Intelligence",
		},
		{
			name = "Perception",
			subName = "Perception",
			wheelName = "Percep.",
			desc = "Roll to notice fine details and alert yourself to danger.", 
			stat = "Wisdom",
		},
		{
			name = "Performance",
			subName = "Performance[s]*",
			wheelName = "Perform",
			desc = "Roll to impress an audience with your talent and skill.", 
			stat = "Charisma",
		},
		{
			name = "Spellcraft",
			subName = "Spellcraft[ing]*",
			desc = "Roll to sense or identify spells and magic items.", 
			stat = "Intelligence",
		},
		{
			name = "Stealth",
			subName = "Stealth",
			wheelName = "Sneak",
			desc = "Roll to avoid detection and remain unseen.", 
			stat = "Dexterity",
		},
		{
			name = "Survival",
			subName = "Survival",
			wheelName = "Survive",
			desc = "Roll to survive or navigate in the wilderness.", 
			stat = "Wisdom",
		},
	},
	["Saving Throws"] = {
		{
			name = "Fortitude Save",
			subName = "Fortitude%s?",
			wheelName = "Fort.|nSave",
			desc = "Roll to resist physical punishment or pain.", 
			stat = "Constitution",
		},
		{
			name = "Reflex Save",
			subName = "Reflex%s?",
			wheelName = "Reflex|nSave",
			desc = "Roll to avoid or prevent an unexpected action.", 
			stat = "Dexterity",
		},
		{
			name = "Will Save",
			subName = "Will%s?",
			wheelName = "Will|nSave",
			desc = "Roll to resist mental influence.", 
			stat = "Wisdom",
		},
	},
}

DiceMaster4.AttributeList = {
	["Strength"] = {
		desc = "A measure of your muscle and physical power.",
	},
	["Dexterity"] = {
		desc = "A measure of your hand-eye coordination, agility, reflexes, and balance.",
	},
	["Constitution"] = {
		desc = "A measure of your health and stamina.",
	},
	["Intelligence"] = {
		desc = "A measure of how well you learn and reason.",
	},
	["Wisdom"] = {
		desc = "A measure of your willpower, common sense, awareness, and intuition.",
	},
	["Charisma"] = {
		desc = "A measure of your personality, personal magnetism, ability to lead, and appearance.",
	},
}
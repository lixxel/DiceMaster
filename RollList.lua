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
			desc = "Roll to cast a spell upon an enemy.", 
			stat = "Intelligence",
		},
		{
			name = "Defence",
			subName = "Defen[cs]e[s]*",
			desc = "Roll to defend yourself from enemy damage.",
			stat = "Defence",
		},
	},
	["Skills"] = {
		{
			name = "Athletics",
			subName = "Athletics",
			wheelName = "Athle.",
			desc = "Roll to flee from combat or outrun someone.", 
			stat = "Strength",
		},
		{
			name = "Bluff",
			subName = "Bluff",
			desc = "Roll to deceive, trick, or lie to someone.", 
			stat = "Charisma",
		},
		{
			name = "Craft",
			subName = "Craft",
			desc = "Roll to create an item that requires a specific skill.", 
			stat = "Intelligence",
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
			name = "Escape Artist",
			subName = "Escape Artist",
			wheelName = "Escape",
			desc = "Roll to slip bonds and escape from grapples.", 
			stat = "Dexterity",
		},
		{
			name = "Grapple",
			subName = "Grapple[s]*",
			desc = "Roll to incapacitate or disable someone.", 
			stat = "Strength",
		},
		{
			name = "Healing",
			subName = "Heal[sing]*",
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
			subName = "Intimidat[eion]*",
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
			name = "Sleight of Hand",
			subName = "Sleight of Hand",
			wheelName = "Sleight|nof Hand",
			desc = "Roll to take or conceal an item on your person without being noticed.", 
			stat = "Dexterity",
		},
		{
			name = "Spellcraft",
			subName = "Spellcraft[ing]*",
			desc = "Roll to cast or identify spells and magic items.", 
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
			subName = "Fortitude%s?[Saves]*",
			wheelName = "Fort.|nSave",
			desc = "Roll to resist physical punishment or pain.", 
			stat = "Constitution",
		},
		{
			name = "Reflex Save",
			subName = "Reflex%s?[Saves]*",
			wheelName = "Reflex|nSave",
			desc = "Roll to avoid or prevent an unexpected action.", 
			stat = "Dexterity",
		},
		{
			name = "Will Save",
			subName = "Will%s?[Saves]*",
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
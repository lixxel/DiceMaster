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
			subName = "Melee Attack[s]?",
			wheelName = "Melee|nAttack",
			desc = "Roll to strike an enemy with a melee weapon.", 
			stat = "Strength",
		},
		{
			name = "Ranged Attack",
			subName = "Ranged Attack[s]?",
			wheelName = "Ranged|nAttack",
			desc = "Roll to strike an enemy with a ranged weapon.", 
			stat = "Dexterity",
		},
		{
			name = "Spell Attack",
			subName = "Spell Attack[s]?",
			wheelName = "Spell|nAttack",
			desc = "Roll to cast a spell upon an enemy.", 
			stat = "Intelligence",
		},
		{
			name = "Defence",
			subName = "Defen[cs]e[s]?",
			desc = "Roll to defend yourself from enemy damage.",
			stat = "Constitution",
		},
		{
			name = "Spell Defence",
			subName = "Spell Defen[cs]e[s]?",
			desc = "Roll to defend yourself from enemy spell damage.",
			stat = "Intelligence",
		},
	},
	["Skills"] = {
		{
			name = "Acrobatics",
			subName = "Acrobatics",
			wheelName = "Acrob.",
			desc = "Roll to dive, flip, jump, and roll to avoid attacks and overcome obstacles.", 
			stat = "Dexterity",
		},
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
			subName = "Grapple[s]?",
			desc = "Roll to disarm or disable an enemy, or reverse grapples.", 
			stat = "Strength",
		},
		{
			name = "Healing",
			subName = "Healing",
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
			subName = "Intimidation",
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
			subName = "Performance[s]?",
			wheelName = "Perform",
			desc = "Roll to impress an audience with your talent and skill.", 
			stat = "Charisma",
		},
		{
			name = "Spellcraft",
			subName = "Spellcraft",
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

DiceMaster4.TermsList = {
	["Effects"] = {
		{
			name = "Advantage",
			subName = "Advantage",
			iconID = 38,
			desc = "Allows a character to roll the same dice twice, and take the greater of the two resulting numbers.",
		},
		{
			name = "Armour Penetration",
			subName = "Arm[ou]*r Penetration",
			iconID = 16,
			desc = "Allows a character's successful attack to bypass the target's Armour this turn.",
		},
		{
			name = "Cleave",
			subName = "Cleave[s]*",
			iconID = 30,
			desc = "Allows a character's successful attack to inflict damage to up to two additional targets.",
		},
		{
			name = "Control",
			subName = "Control[sleding]*",
			iconID = 47,
			desc = "Allows a character to take command of a target and control their actions until the effect ends.",
		},
		{
			name = "Counter",
			subName = "Counter[seding]*",
			iconID = 48,
			desc = "Allows a character to immediately attack the same target after a successful Defence roll.",
		},
		{
			name = "Disadvantage",
			subName = "Disadvantage",
			iconID = 39,
			desc = "Allows a character to roll the same dice twice, and take the lesser of the two resulting numbers.",
		},
		{
			name = "Disarm",
			subName = "Disarm[s]*",
			iconID = 31,
			desc = "Removes a target's weapons for one turn, preventing them from using them.",
		},
		{
			name = "Double or Nothing",
			subName = "Double or Nothing",
			iconID = 32,
			desc = "An unmodified D40 roll. If the roll succeeds, the character is rewarded with a critical success; however, if the roll fails, the character suffers a critical failure.",
		},
		{
			name = "Empower",
			subName = "Empower[seding]*",
			iconID = 45,
			desc = "Allows a character's successful Melee Attack or Ranged Attack to be considered a Spell Attack.",
		},
		{
			name = "Immunity",
			subName = "Immunity",
			iconID = 46,
			desc = "Prevents a character from suffering any damage from a failure this turn.",
		},
		{
			name = "Intercept",
			subName = "Intercept[edsing]*",
			iconID = 49,
			desc = "Intercepts another character's failure, taking the full amount of damage.",
		},
		{
			name = "Multistrike",
			subName = "Multistrike",
			iconID = 28,
			desc = "Allows a character to attack twice on their turn; however, their second attack only inflicts 1 damage (2 if critically successful).",
		},
		{
			name = "Natural 1",
			subName = "NAT1",
			iconID = 37,
			desc = "A roll of 1 that is achieved before dice modifiers are applied that results in critical failure.",
			altTerm = "NAT1",
		},
		{
			name = "Natural 20",
			subName = "NAT20",
			iconID = 36,
			desc = "A roll of 20 that is achieved before dice modifiers are applied that results in critical success.",
			altTerm = "NAT20",
		},
		{
			name = "Reload",
			subName = "Reload[edsing]*",
			iconID = 29,
			desc = "Grants the character's active-use trait another use.",
		},
		{
			name = "Revive",
			subName = "Reviv[desing]*",
			iconID = 34,
			desc = "Allows a character with |cFFFFFFFF0|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t|cFFffd100 remaining to return to combat with |cFFFFFFFF3|r|TInterface/AddOns/DiceMaster/Texture/health-heart:12|t|cFFffd100.",
		},
	},
	["Conditions"] = {
		{
			name = "Blind",
			subName = "Blind[seding]*",
			iconID = 1,
			desc = "The target is unable to see and automatically fails any ability check that requires sight. Attack rolls against the target have Advantage, and the target's attack rolls have Disadvantage.",
			term = "Blind",
		},
		{
			name = "Charm",
			subName = "Charm[seding]*",
			iconID = 3,
			desc = "The target is entranced and unable to attack the charmer. The charmer has Advantage on any ability check to interact socially with the target.",
			term = "Charm",
		},
		{
			name = "Deafen",
			subName = "Deafen[seding]*",
			iconID = 5,
			desc = "The target is unable to hear and automatically fails any ability check that requires hearing.",
		},
		{
			name = "Fatigue",
			subName = "Fatigu[esding]*",
			iconID = 6,
			desc = "The target cannot run nor charge. The target has Disadvantage on Fortitude and Reflex Saves.",
		},
		{
			name = "Frighten",
			subName = "Frighten[seding]*",
			iconID = 9,
			desc = "The target has Disadvantage on ability checks and attack rolls while the source of its fear is within line of sight. The target cannot willingly move closer to the source of its fear.",
		},
		{
			name = "Grapple",
			subName = "Grappl[edsing]*",
			iconID = 10,
			desc = "The target is unable to move for the duration of the Grapple. The condition ends if the grappler is incapacitated.",
		},
		{
			name = "Incapacitate",
			subName = "Incapacitat[esding]*",
			iconID = 11,
			desc = "The target cannot take actions or reactions.",
		},
		{
			name = "Invisible",
			subName = "Invisible",
			iconID = 12,
			desc = "The target is impossible to see without the aid of magic or a special sense. Attack rolls against the target have Disadvantage, and the target's attack rolls have Advantage.",
		},
		{
			name = "Paralyse",
			subName = "Paraly[sz]*[esding]*",
			iconID = 14,
			desc = "The target cannot take actions or reactions, move, or speak. The target automatically fails Fortitude and Reflex Saves. Attack rolls against the target have Advantage.",
		},
		{
			name = "Petrify",
			subName = "Petrif[iyesding]*",
			iconID = 15,
			desc = "The target is transformed into solid stone and cannot take actions or reactions, move, or speak. Attack rolls against the target have Advantage. The target is immune to poison and disease, but automatically fails Fortitude and Reflex Saves.",
		},
		{
			name = "Poison",
			subName = "Poison[seding]*",
			iconID = 18,
			desc = "The target has Disadvantage on attack rolls and ability checks.",
		},
		{
			name = "Prone",
			subName = "Prone",
			iconID = 19,
			desc = "The target's only movement option is to crawl, unless it stands up and ends the condition. The target has Disadvantage on attack rolls. Melee Attack rolls against the target have Advantage, but Ranged Attack rolls have Disadvantage.",
		},
		{
			name = "Restrain",
			subName = "Restrain[seding]*",
			iconID = 22,
			desc = "The target is unable to move and has Disadvantage on Reflex Saves. Attack rolls against the target have Advantage, and the target's Attack rolls have Disadvantage.",
		},
		{
			name = "Silence",
			subName = "Silenc[esding]*",
			iconID = 33,
			desc = "Interrupts a target's spellcast and prevents them from casting spells on their next turn.",
		},
		{
			name = "Slow",
			subName = "Slow[seding]*",
			iconID = 35,
			desc = "Reduces a target's movement speed until the effect ends.",
		},
		{
			name = "Stun",
			subName = "Stun[sneding]*",
			iconID = 24,
			desc = "The target cannot take actions or reactions, cannot move, and can speak only falteringly. The target automatically fails Fortitude and Reflex Saves. Attack rolls against the target have Advantage.",
		},
		{
			name = "Unconscious",
			subName = "Unconscious",
			iconID = 26,
			desc = "The target cannot take actions or reactions, cannot move or speak, and drops whatever it is holding. The target automatically fails Fortitude and Reflex Saves and attack rolls against the target have Advantage.",
		},
	},
	["Other"] = {
		{
			name = "Armour",
			subName = "Armo[u]*r",
			desc = "Extends a character's Health beyond the maximum amount by a certain value. Damage taken will usually be deducted from Armour before Health unless otherwise specified.",
			altTerm = "AR",
		},
		{
			name = "Health",
			subName = "Health",
			desc = "A measure of a character's health or an object's integrity. Damage taken decreases Health, and healing restores Health.",
			altTerm = "HP",
		},
	},
}
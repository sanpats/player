CLANGEDDIN'S COLLECTION V 1.0
26/12/2017

INTRODUCTION
	This mod is a collection of three mods I made in the past.
	To make it easier to maintain them, I decided to dedicate them a single page with a single download file.
	It is still possible to choose which mods to use (even none at all if you just want to make use of the library)
	by deleting the folders "Mod_xxxx" of the mods you don't want to use.

INSTALLATION
	Delete any previous version of Clangeddin's UI, Clangeddin's Rebuild and Clangeddin's Fix, if you have them.
	Extract the contents of the zip folder in .../MyDocuments/Neverwinter Nights 2/override/
	Delete the folders of the mods you don't want to use (optional)

FEATURES
	Main (Mandatory for every other mod listed here to work, don't delete this folder)
		Includes a general library that provides many new functions that scripters can use.
		Use #include "clangeddin_library" in your script to make use of the new functions.
		More detailed info can be find inside the script as comment on the function prototypes.
		This file can also used be to tweak options (Constants) for other mods listed here.
		
	Mod_Fixes
		Fixes the following bugs:
		1) Spell resistance from items firing only once.
		2) Damage immunities from items becoming vulnerabilities if they surpass 100%.
		3) Improved Uncanny Dodge not working. (This is actually a buff to the feat and may be disabled)
		4) Fix to an exploit that can allow you to equip items for which you don't have the required proficiency.
		In addition, it provides a new item (Character's essence) that may be used as a quality of life feature
		to instantly cast all available buff spells to the target. This can be disabled in the options as well.
	
	Mod_Rebuild
		Allows to rebuild your character with 2 possible options.
		1) Full rebuild. Rebuilds from level 1 allowing you to choose ability scores, deity, background, alignment
		2) Partial rebuild. Simply sends you back to the level you choose and grants you back the exp.
	
	Mod_UI
		Provides changes to the interface that include:
		1) Displayed HP numbers of targets. (can be disabled)
		2) A persistant item and gold storage for multiplayer. (can be disabled)
		3) Draggable Mode Bar.
		4) A button to instantly recall npc companions to you. (can be disabled)
		5) A new style of party bar interface with the options of moving it to the left. (can be reverted to default, in-game)
			
OPTIONS
	Several options are available inside the script "clangeddin_library.nss" to alter the behavior of the various mods.
	All instructions are written there as a comment.
	
CHANGELOG
	1.0 - Initial Release
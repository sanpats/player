// --------- \\
// CONSTANTS \\
// --------- \\

//Options for Clangeddin's Fixes (compile "clangfix_equip" and "i_clangfix_ac" scripts if you change this)
const int CLANG_DISABLE_IUDFIX = TRUE; 				//Set to TRUE if you wish to disable the fix to Improved Uncanny Dodge.
const int CLANG_DISABLE_BUFFDEVICE = FALSE;				//Set to TRUE if you wish to disable the buffing device.
const int CLANG_DISABLE_AUTOCONSERVATION = FALSE;		//Set to TRUE if you wish to disable the automatic item conservation function.
const int CLANG_FXEQUIP = -9004; 						//The ID used to identify effects applied by On Equip scripts.

//Options for Clangeddin's Rebuild (compile "gui_clang_rebuild" script if you change this)
const int CLANG_REB_FULL_FORBIDGOD = FALSE;				//If set to TRUE, Full Rebuild will no longer allow Deity Change.
const int CLANG_REB_FULL_GOLDSCALE = FALSE; 			//If set to TRUE, the gold cost of full rebuild will scale up with the character's level.
const int CLANG_REB_FULL_GOLDCOST = 0; 					//If higher than 0, full rebuild will cost gold.
const int CLANG_REB_FULL_ITEMCOST = FALSE; 				//If set to TRUE, full rebuild will require an item.
const string CLANG_REB_FULL_ITEM_TAG = "cft_gem_14"; 	//The tag of the items required to do full rebuild.
const int CLANG_REB_PART_GOLDSCALE = FALSE; 			//If set to TRUE, the gold cost of partial rebuild will scale up with the character's level.
const int CLANG_REB_PART_GOLDCOST = 0; 					//If higher than 0, partial rebuild will cost gold.
const int CLANG_REB_PART_ITEMCOST = FALSE;				//If set to TRUE, partial rebuild will require an item.
const string CLANG_REB_PART_ITEM_TAG = "cft_gem_14"; 	//The tag of the items required to do partial rebuild.

//Options for Clangeddin's User Interface (compile "gui_clangui" script if you change this)
const int CLANG_UI_DISABLE_RECALL = FALSE;				//If set to TRUE, Recall companion feature will be disabled.
const int CLANG_UI_DISABLE_HPNUMBERS = FALSE;			//If set to TRUE, target window will not display HP numbers.
const int CLANG_UI_DISABLE_STORAGE = FALSE;				//If set to TRUE, the multiplayer persistent storage will be disabled.

// ---------- \\
// PROTOTYPES \\
// ---------- \\

//Returns a proper element string for the various DAMAGE_TYPE_ variables.
//For example for nELEMENT = DAMAGE_TYPE_FIRE it will return the string "Fire".
//nCAPS: if TRUE it will set all the string to Upper case. (In the above example it would be "FIRE")
string GetElementString(int nELEMENT, int nCAPS = FALSE);

//Returns the corresponding DAMAGE_TYPE_* variable from the itemproperty equivalent.
//3 and 4 are not defined. Use only from 0 to 2 and from 5 to 13.
//nREVERSE: if TRUE then it will do the reverse operation, returning the item property from DAMAGE_TYPE_* variable.
int ConvertElement(int nELEMENT, int nREVERSE = FALSE);

//Returns how many sTAG tagged items oPC possesses. This includes stack size.
//For example, if I have one stack with 99 arrows and one stack with 41 arrows, this function will return 140.
//nREF: if TRUE then sTAG will be meant as the item's resref (template?) string instead of tag.
int GetItemQuantity(object oPC, string sTAG, int nREF = FALSE);

//Returns how many items (actually how many stacks of items) oPC has.
//For example, if I only have one stack of 10 potions and 1 weapon, this function will return 2.
//nBAGS: If set to TRUE, it will also count items inside containers.
int GetInventoryNum(object oPC, int nBAGS = FALSE);

//Removes nQTY items tagged sTAG from oPC.
//nFEED: If TRUE feedback will be displayed in the combat log.
//nREF: if TRUE then sTAG will be meant as the item's resref (template?) string instead of tag.
void RemoveItems(object oPC, string sTAG, int nQTY, int nFEED = TRUE, int nREF = FALSE);

//Forces oTARGET to attack oPC for at least fDUR Seconds.
//nINTERRUPT: If set to TRUE it will also interrupt any action performed by oTARGET.
//nPVP: If set to TRUE, it will also work against players.
//nSTART: Should stay set to TRUE. It's false only inside itself as a recursive call.
void RunTaunt(object oPC, object oTARGET, float fDUR, int nINTERRUPT = TRUE, int nPVP = TRUE, int nSTART = TRUE);

//Plays sSOUND at lSOUND location.
//sSOUND is the name of the sound file without the extension.
//n2D: if TRUE the sound will be played as 2D.
void ReallyPlaySound(location lSOUND, string sSOUND, int n2D = FALSE);

//Workoaround to make PlayCustomAnimation really work.
//Use it with AssignCommand to oPC, like this: AssignCommand(oPC, ReallyPlayCustomAnimation(oPC, sANIM));
void ReallyPlayCustomAnimation(object oPC, string sANIM, int nLOOP = FALSE, float fSPEED = 1.0);

//Returns TRUE if the spell with ID nSPELL cast by oPC on oTarget is to be considered a buffing spell.
//Works with standard NWN2 rules, customized/new spells may not be recognized properly.
int GetIsBuffSpell(object oPC, object oTARGET, int nSPELL);

//NOTE: This function works ONLY in single player. There is no need for it on multiplayer.
//WARNING: This function will not work if oPC is in combat or has a full inventory.
//This function will automatically create a container on oPC and store inside whatever item modified
//by Clangeddin's Fixes he has. Modders can use this to prevent the loss of elemental immunities
//whenever there's a module change in a campaign, or as a tool for character export in local vault servers.
//Calling the function again on a character that already has this special container will do the reverse operation.
//The items inside the container will be automatically equipped in their slot and the container will be destroyed.
//By default this function will be also called whenever someone uses the character's essence on itself.
void AutoItemConservation(object oPC);

// ----------- \\
// DEFINITIONS \\
// ----------- \\

//Used ONLY inside AutoItemConservation function. Don't use anywhere else.
void ProperlyProcessItem(object oPC, object oBAG, object oITEM, int nREVERSE, int nSTEP = 0)
{
	if (nSTEP == 0) 
	{
		object oCOPY = oITEM;
		if (nREVERSE != TRUE)
		{
			oCOPY = CopyItem(oITEM, oBAG, TRUE);
			AssignCommand(oITEM, SetIsDestroyable(TRUE, FALSE));
			DestroyObject(oITEM);
		}
		DelayCommand(0.0f, ProperlyProcessItem(oPC, oBAG, oCOPY, nREVERSE, 1));
	}
	else if (nSTEP == 1)
	{
		if (nREVERSE == TRUE)
		{
			int nSLOT = GetLocalInt(oITEM, "CLANGFIX_ITEMSLOT");		
			if (nSLOT > 0)
			{
				AssignCommand(oPC, ActionEquipItem(oITEM, nSLOT - 1));
				DeleteLocalInt(oITEM, "CLANGFIX_ITEMSLOT");
			}
			else AssignCommand(oPC, ActionTakeItem(oITEM, oBAG, FALSE));
		}
		DelayCommand(0.0f, ProperlyProcessItem(oPC, oBAG, oITEM, nREVERSE, 2));
	}
	else if (nSTEP == 2)
	{
		if (nREVERSE == TRUE)
		{
			int nPLOT = GetLocalInt(oITEM, "CLANGFIX_PLOT");
			int nCURSE = GetLocalInt(oITEM, "CLANGFIX_CURSE");
			int nDROP = GetLocalInt(oITEM, "CLANGFIX_DROP");
			SetPlotFlag(oITEM, nPLOT);
			SetItemCursedFlag(oITEM, nCURSE);
			SetDroppableFlag(oITEM, nDROP);
			DeleteLocalInt(oITEM, "CLANGFIX_PLOT");
			DeleteLocalInt(oITEM, "CLANGFIX_CURSE");
			DeleteLocalInt(oITEM, "CLANGFIX_DROP");
		}
		else
		{
			SetPlotFlag(oITEM, TRUE);
			SetItemCursedFlag(oITEM, TRUE);
			SetDroppableFlag(oITEM, TRUE);
		}		
	}
}

void AutoItemConservation(object oPC)
{
	if (CLANG_DISABLE_AUTOCONSERVATION == TRUE) return;
	if (GetIsSinglePlayer() == FALSE) return;
	if (GetIsInCombat(oPC) == TRUE) return;
	if (GetInventoryNum(oPC) > 126) return;
	int nSLOT;
	object oESSENCE = GetItemPossessedBy(oPC, "clangfix");
	object oBAG = GetItemPossessedBy(oPC, "clangfix_container");
	object oITEM;
	object oINVALID = OBJECT_INVALID;
	if (oBAG != oINVALID)
	{
		oESSENCE = GetFirstItemInInventory(oPC);
		while (oESSENCE != oINVALID)
		{
			if (GetTag(oESSENCE) == "clangfix")
			{
				if (GetLocalInt(oESSENCE, "CLANGFIX_MODIFIED") == 0)	
				{
					AssignCommand(oESSENCE, SetIsDestroyable(TRUE, FALSE));
					DestroyObject(oESSENCE);
					break;
				}
			}
			oESSENCE = GetNextItemInInventory(oPC);
		}
		oITEM = GetFirstItemInInventory(oBAG);
		while (oITEM != oINVALID)
		{
			ProperlyProcessItem(oPC, oBAG, oITEM, TRUE);
			oITEM = GetNextItemInInventory(oBAG);
		}
		AssignCommand(oBAG, SetIsDestroyable(TRUE, FALSE));
		DestroyObject(oBAG, 1.0);
	}
	else
	{
		oBAG = CreateItemOnObject("clangfix_container", oPC, 1);
		while (nSLOT < 18)
		{
			oITEM = GetItemInSlot(nSLOT, oPC);
			if (GetLocalInt(oITEM, "CLANGFIX_MODIFIED") == TRUE)
			{
				SetLocalInt(oITEM, "CLANGFIX_PLOT", GetPlotFlag(oITEM));
				SetLocalInt(oITEM, "CLANGFIX_CURSE", GetItemCursedFlag(oITEM));
				SetLocalInt(oITEM, "CLANGFIX_DROP", GetDroppableFlag(oITEM));
				SetLocalInt(oITEM, "CLANGFIX_ITEMSLOT", nSLOT + 1);
				ProperlyProcessItem(oPC, oBAG, oITEM, FALSE);
			}
			nSLOT = nSLOT + 1;
		}
		object oIN;
		int nITEM;
		int nBAG;
		oITEM = GetFirstItemInInventory(oPC);
		while (oITEM != oINVALID)
		{
			if (nBAG > 0) nBAG = nBAG - 1;
			else if (GetLocalInt(oITEM, "CLANGFIX_MODIFIED") == 1)
			{
				SetLocalInt(oITEM, "CLANGFIX_PLOT", GetPlotFlag(oITEM));
				SetLocalInt(oITEM, "CLANGFIX_CURSE", GetItemCursedFlag(oITEM));
				SetLocalInt(oITEM, "CLANGFIX_DROP", GetDroppableFlag(oITEM));
				ProperlyProcessItem(oPC, oBAG, oITEM, FALSE);
			}
			if (GetHasInventory(oITEM) == TRUE)
			{
				oBAG = oITEM;
				oIN = GetFirstItemInInventory(oBAG);
				while (oIN != oINVALID)
				{
					nBAG = nBAG + 1;
					oIN = GetNextItemInInventory(oBAG);	
				}
			}			
			oITEM = GetNextItemInInventory(oPC);
		}
		object oNEW = CopyItem(oESSENCE, oPC);
		SetFirstName(oNEW, "Temporary Essence");
		SetDescription(oNEW, "Use this on itself to retrieve the items stored for the transfer.");
	}
}

void RunTaunt(object oPC, object oTARGET, float fDUR, int nINTERRUPT = TRUE, int nPVP = TRUE, int nSTART = TRUE)
{	
	if (nSTART == TRUE)
	{
		if ((nPVP != TRUE) && (GetIsPC(oTARGET) == TRUE)) return;
		if (GetLocalObject(oTARGET, "TAUNT_SOURCE") != OBJECT_INVALID) return;
		if (nINTERRUPT == TRUE) AssignCommand(oTARGET, ClearAllActions());
		effect eTAUNT = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_TAUNT));
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTAUNT, oTARGET, fDUR);
		SetLocalObject(oTARGET, "TAUNT_SOURCE", oPC);	
	}
	if (fDUR <= 0.0f)
	{
		DeleteLocalObject(oTARGET, "TAUNT_SOURCE");
		return;
	}
	if ((GetAttackTarget(oTARGET) != oPC))
	{
		if (GetCurrentAction(oTARGET) != ACTION_CASTSPELL) AssignCommand(oTARGET, ClearAllActions());
		AssignCommand(oTARGET, ActionAttack(oPC));
	}
	DelayCommand(0.5, RunTaunt(oPC, oTARGET, fDUR - 0.5, nINTERRUPT, nPVP, FALSE));
}

void RemoveItems(object oPC, string sTAG, int nQTY, int nFEED = TRUE, int nREF = FALSE)
{
	if (sTAG == "") return;
	if (nQTY < 1) return;
	int nCOUNT = nQTY;
	int nSTACK;
	string sITEM;
	object oINVALID = OBJECT_INVALID;
	object oITEM = GetFirstItemInInventory(oPC);
	while (oITEM != oINVALID)
	{
		if (nREF == TRUE) sITEM = GetResRef(oITEM);
		else sITEM = GetTag(oITEM);
		if (sITEM == sTAG)
		{
			nSTACK = GetItemStackSize(oITEM);
			if (nSTACK > nCOUNT) SetItemStackSize(oITEM, nSTACK - nCOUNT, nFEED);
			else DestroyObject(oITEM, 0.0f, nFEED);
			nCOUNT = nCOUNT - nSTACK;
			if (nCOUNT < 1) return;
		}
		oITEM = GetNextItemInInventory(oPC);
	}
}

int GetItemQuantity(object oPC, string sTAG, int nREF = FALSE)
{
	object oINVALID = OBJECT_INVALID;
	if ((nREF == FALSE) && (GetItemPossessedBy(oPC, sTAG) == oINVALID)) return 0;
	int nTOT;
	string sITEM;
	object oITEM = GetFirstItemInInventory(oPC);
	while (oITEM != oINVALID)
	{
		if (nREF == TRUE) sITEM = GetResRef(oITEM);
		else sITEM = GetTag(oITEM);
		if (sITEM == sTAG) nTOT = nTOT + GetItemStackSize(oITEM);
		oITEM = GetNextItemInInventory(oPC);
	}
	return nTOT;
}

int GetInventoryNum(object oPC, int nBAGS = FALSE)
{
	int nITEM;
	int nBAG;
	object oBAG;
	object oIN;
	object oINVALID = OBJECT_INVALID;
	object oITEM = GetFirstItemInInventory(oPC);
	while (oITEM != oINVALID)
	{
		if (nBAG > 0) nBAG = nBAG - 1;
		else nITEM = nITEM + 1;
		if ((GetHasInventory(oITEM) == TRUE) && (nBAGS != TRUE))
		{
			oBAG = oITEM;
			oIN = GetFirstItemInInventory(oBAG);
			while (oIN != oINVALID)
			{
				nBAG = nBAG + 1;
				oIN = GetNextItemInInventory(oBAG);	
			}
		}
		oITEM = GetNextItemInInventory(oPC);
	}
	return nITEM;
}

void ReallyPlaySound(location lSOUND, string sSOUND, int n2D = FALSE)
{
	string sOUTPUT = sSOUND;
	if (n2D = TRUE) sOUTPUT = "D_" + sSOUND;
	object oSOUND = CreateObject(OBJECT_TYPE_CREATURE, "soundplayer", lSOUND, FALSE, sOUTPUT);
}

void ReallyPlayCustomAnimation(object oPC, string sANIM, int nLOOP = FALSE, float fSPEED = 1.0)
{
	PlayCustomAnimation(oPC, sANIM, nLOOP, fSPEED);
}

string GetElementString(int nELEMENT, int nCAPS = FALSE)
{
	string sTXT;
	switch (nELEMENT)
	{
		case DAMAGE_TYPE_BLUDGEONING: sTXT = "Bludgeoning"; break;
		case DAMAGE_TYPE_PIERCING: sTXT = "Piercing"; break;
		case DAMAGE_TYPE_SLASHING: sTXT = "Slashing"; break;
		case DAMAGE_TYPE_MAGICAL: sTXT = "Magical"; break;
		case DAMAGE_TYPE_ACID: sTXT = "Acid"; break;
		case DAMAGE_TYPE_COLD: sTXT = "Cold"; break;
		case DAMAGE_TYPE_DIVINE: sTXT = "Divine"; break;
		case DAMAGE_TYPE_ELECTRICAL: sTXT = "Electrical"; break;
		case DAMAGE_TYPE_FIRE: sTXT = "Fire"; break;
		case DAMAGE_TYPE_NEGATIVE: sTXT = "Negative"; break;
		case DAMAGE_TYPE_POSITIVE: sTXT = "Positive"; break;
		case DAMAGE_TYPE_SONIC: sTXT = "Sonic"; break;
		default: sTXT = "Error";
	}
	if (nCAPS == TRUE) sTXT = GetStringUpperCase(sTXT);
	return sTXT;
}

int ConvertElement(int nELEMENT, int nREVERSE = FALSE)
{
	int nEL;
	if (nREVERSE == TRUE)
	{
		switch (nELEMENT)
		{
			case DAMAGE_TYPE_BLUDGEONING: nEL = 0; break;
			case DAMAGE_TYPE_PIERCING: nEL = 1; break;
			case DAMAGE_TYPE_SLASHING: nEL = 2; break;
			case DAMAGE_TYPE_MAGICAL: nEL = 5; break;
			case DAMAGE_TYPE_ACID: nEL = 6; break;
			case DAMAGE_TYPE_COLD: nEL = 7; break;
			case DAMAGE_TYPE_DIVINE: nEL = 8; break;
			case DAMAGE_TYPE_ELECTRICAL: nEL = 9; break;
			case DAMAGE_TYPE_FIRE: nEL = 10; break;
			case DAMAGE_TYPE_NEGATIVE: nEL = 11; break;
			case DAMAGE_TYPE_POSITIVE: nEL = 12; break;
			case DAMAGE_TYPE_SONIC: nEL = 13; break;
			default: nEL = 3; //Broken
		}
	}
	else
	{
		switch (nELEMENT)
		{
			case 0: nEL = DAMAGE_TYPE_BLUDGEONING; break;
			case 1: nEL = DAMAGE_TYPE_PIERCING; break;
			case 2: nEL = DAMAGE_TYPE_SLASHING; break;
			case 5: nEL = DAMAGE_TYPE_MAGICAL; break;
			case 6: nEL = DAMAGE_TYPE_ACID; break;
			case 7: nEL = DAMAGE_TYPE_COLD; break;
			case 8: nEL = DAMAGE_TYPE_DIVINE; break;
			case 9: nEL = DAMAGE_TYPE_ELECTRICAL; break;
			case 10: nEL = DAMAGE_TYPE_FIRE; break;
			case 11: nEL = DAMAGE_TYPE_NEGATIVE; break;
			case 12: nEL = DAMAGE_TYPE_POSITIVE; break;
			case 13: nEL = DAMAGE_TYPE_SONIC; break;
			default: nEL = 0;
		}
	}
	return nEL;
}

int GetIsBuffSpell(object oPC, object oTARGET, int nSPELL)
{
	switch(nSPELL)
	{
		//Positive Exceptions
		case SPELL_LIGHT:
			return TRUE;
			break;
			
		//Negative Exceptions
		case SPELL_SHIELD_OTHER:
		case SPELL_SANCTUARY:
		case SPELL_BANE:
		case SPELL_ENLARGE_PERSON:
		case SPELL_REDUCE_PERSON:
		case SPELL_REDUCE_PERSON_GREATER:
		case SPELL_REDUCE_PERSON_MASS:
		case SPELL_REDUCE_ANIMAL:
			return FALSE;
			break;
			
		//Conditional Exceptions
		case SPELL_GREATER_MAGIC_WEAPON:
		case SPELL_MAGIC_WEAPON:
		case SPELL_KEEN_EDGE:
		case SPELL_WEAPON_OF_IMPACT:
		case SPELL_BLADES_OF_FIRE:
		case SPELL_FLAME_WEAPON:
			object oWEAPON = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTARGET);
			if (oWEAPON == OBJECT_INVALID) return FALSE;
			if (GetWeaponRanged(oWEAPON) == TRUE)
			{
				if (nSPELL == SPELL_GREATER_MAGIC_WEAPON) return TRUE;
				if (nSPELL == SPELL_MAGIC_WEAPON) return TRUE;
				else return FALSE;
			}
			if (GetWeaponType(oWEAPON) == WEAPON_TYPE_BLUDGEONING)
			{
				if (nSPELL == SPELL_KEEN_EDGE) return FALSE;
			}
			else if (nSPELL == SPELL_WEAPON_OF_IMPACT) return FALSE;
			return TRUE;
			break;		
	}
	if ((Get2DAString("spells", "Range", nSPELL) == "P") && (oPC != oTARGET)) return FALSE;
	int nCATEGORY = StringToInt(Get2DAString("spells", "Category", nSPELL));
	switch (nCATEGORY)
	{
		case 8:
		case 9:
		case 10:
		case 12:
		case 13:
		case 14:
			return TRUE;
			break;
	}
	return FALSE;
}
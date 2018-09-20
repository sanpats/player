//:://////////////////////////////////////////////
//:: Custom Equip system
//:://////////////////////////////////////////////
//:: Runs the Custom OnEquip Scripts.
//:://////////////////////////////////////////////
//:: Created By: Clangeddin
//:: Created On: December 12, 2015

#include "nw_i0_spells"
#include "clangeddin_library"

void FixItem(object oEQUIP)
{
	if (GetItemHasItemProperty(oEQUIP, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE) == FALSE)
	{
		if (GetItemHasItemProperty(oEQUIP, ITEM_PROPERTY_DAMAGE_VULNERABILITY) == FALSE) return;
	}
	int nCACHE_A = GetNum2DARows("iprp_immuncost");
	int nCACHE_B = GetNum2DARows("iprp_damvulcost");
	int nTYPE;
	int nSUB;
	int nITEM;
	int nTABLE;
	int nCOUNT;
	string sELEM;
	itemproperty iPROP = GetFirstItemProperty(oEQUIP);
	while (GetIsItemPropertyValid(iPROP) == TRUE)
	{
		if (GetItemPropertyDurationType(iPROP) == DURATION_TYPE_PERMANENT)
		{
			nTYPE = GetItemPropertyType(iPROP);
			if (GetItemPropertyType(iPROP) == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE)
			{
				nSUB = GetItemPropertySubType(iPROP);
				nTABLE = GetItemPropertyCostTableValue(iPROP);
				nITEM = StringToInt(Get2DAString("iprp_immuncost", "Value", nTABLE));
				sELEM = "CLANGFIX_ELEMENT_" + IntToString(ConvertElement(nSUB));
				SetLocalInt(oEQUIP, sELEM, nITEM);
				RemoveItemProperty(oEQUIP, iPROP);
				nCOUNT = nCOUNT + 1;			
			}
			else if (GetItemPropertyType(iPROP) == ITEM_PROPERTY_DAMAGE_VULNERABILITY)
			{
				nSUB = GetItemPropertySubType(iPROP);
				nTABLE = GetItemPropertyCostTableValue(iPROP);
				nITEM = StringToInt(Get2DAString("iprp_damvulcost", "Value", nTABLE));
				sELEM = "CLANGFIX_ELEMENT_" + IntToString(ConvertElement(nSUB));
				SetLocalInt(oEQUIP, sELEM, -nITEM);
				RemoveItemProperty(oEQUIP, iPROP);
			}
		}
		iPROP = GetNextItemProperty(oEQUIP);
	}
	while (nCOUNT > 0)
	{
		AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusLevelSpell(IP_CONST_CLASS_FIGHTER, 0), oEQUIP);
		nCOUNT = nCOUNT - 1;
	}
	if (GetLocalInt(oEQUIP, "CLANGFIX_MODIFIED") != TRUE)
	{
		SetFirstName(oEQUIP, "<c=orange>" + GetName(oEQUIP) + "*");
		SetLocalInt(oEQUIP, "CLANGFIX_MODIFIED", TRUE);
	}	
}

void FixSR(object oPC)
{
	object oITEM;
	int nEQUIP;
	int nSR;
	int nMAX;
	int nTYPE;
	int nTABLE;
	int nCACHE = GetNum2DARows("iprp_srcost");
	itemproperty iPROP;
	while (nEQUIP < 18)
	{
		oITEM = GetItemInSlot(nEQUIP, oPC);
		if (GetItemHasItemProperty(oITEM, ITEM_PROPERTY_SPELL_RESISTANCE) == TRUE)
		{
			iPROP = GetFirstItemProperty(oITEM);
			while (GetIsItemPropertyValid(iPROP))
			{
				nTYPE = GetItemPropertyType(iPROP);
				if (nTYPE == ITEM_PROPERTY_SPELL_RESISTANCE)
				{
					nTABLE = GetItemPropertyCostTableValue(iPROP);
					nSR = StringToInt(Get2DAString("iprp_srcost", "Value", nTABLE));
					if (nSR > nMAX)	nMAX = nSR;
				}
				iPROP = GetNextItemProperty(oITEM);
			}
		}
		nEQUIP = nEQUIP + 1;
	}
	if (nMAX < 1) return;
	effect eSR = EffectSpellResistanceIncrease(nMAX);
	eSR = SupernaturalEffect(eSR);
	eSR = SetEffectSpellId(eSR, CLANG_FXEQUIP);
	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSR, oPC);
}

void FixIMM(object oPC)
{
	object oEQUIP;
	effect eFX;
	int nEQUIP;
	int nITEM;
	int nTOTAL;
	int nELEMENT = 1; //DAMAGE_TYPE_BLUDGEON is 1, the first of the valid damage types.
	while (nELEMENT < 2050) //DAMAGE_TYPE_SONIC is 2048 and they progress as power of 2.
	{
		nEQUIP = 0;
		nTOTAL = 0;
		while (nEQUIP < 18)
		{
			oEQUIP = GetItemInSlot(nEQUIP, oPC);	
			nTOTAL = nTOTAL + GetLocalInt(oEQUIP, "CLANGFIX_ELEMENT_" + IntToString(nELEMENT));
			nEQUIP = nEQUIP + 1;
		}
		if (nTOTAL > 99) eFX = EffectLinkEffects(eFX, EffectDamageResistance(nELEMENT, 9999));
		else if (nTOTAL > 0) eFX = EffectLinkEffects(eFX, EffectDamageImmunityIncrease(nELEMENT, nTOTAL));
		else if (nTOTAL < 0) eFX = EffectLinkEffects(eFX, EffectDamageImmunityDecrease(nELEMENT, -nTOTAL));
		nELEMENT = nELEMENT * 2;
	}
	eFX = SupernaturalEffect(eFX);
	eFX = SetEffectSpellId(eFX, CLANG_FXEQUIP);
	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eFX, oPC);
}

void FixIUD(object oPC)
{
	if (CLANG_DISABLE_IUDFIX == TRUE) return;
	if (GetHasFeat(FEAT_IMPROVED_UNCANNY_DODGE, oPC, TRUE) == FALSE) return;
	effect eFX = EffectImmunity(IMMUNITY_TYPE_SNEAK_ATTACK);
	eFX = SupernaturalEffect(eFX);
	eFX = SetEffectSpellId(eFX, CLANG_FXEQUIP);
	ApplyEffectToObject(DURATION_TYPE_PERMANENT, eFX, oPC);
}

int FixSHIELD(object oPC)
{
	object oSHIELD = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
	int nSHIELD = GetBaseItemType(oSHIELD);
	int nFEAT;
	switch (nSHIELD)
	{
		case BASE_ITEM_SMALLSHIELD: nFEAT = FEAT_SHIELD_PROFICIENCY; break;
		case BASE_ITEM_LARGESHIELD: nFEAT = FEAT_SHIELD_PROFICIENCY; break;
		case BASE_ITEM_TOWERSHIELD: nFEAT = FEAT_TOWER_SHIELD_PROFICIENCY; break;
		default: return FALSE;
	}
	if (GetHasFeat(nFEAT, oPC, TRUE) == TRUE) return FALSE;
	AssignCommand(oPC, ClearAllActions());
	AssignCommand(oPC, ActionUnequipItem(oSHIELD));
	return TRUE;
}

int FixARMOR(object oPC)
{
	object oARMOR = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
	int nARMOR = GetArmorRank(oARMOR);
	int nFEAT;
	switch (nARMOR)
	{
		case ARMOR_RANK_LIGHT: nFEAT = FEAT_ARMOR_PROFICIENCY_LIGHT; break;
		case ARMOR_RANK_MEDIUM: nFEAT = FEAT_ARMOR_PROFICIENCY_MEDIUM; break;
		case ARMOR_RANK_HEAVY: nFEAT = FEAT_ARMOR_PROFICIENCY_HEAVY; break;
		default: return FALSE;
	}
	if (GetHasFeat(nFEAT, oPC, TRUE) == TRUE) return FALSE;
	AssignCommand(oPC, ClearAllActions(TRUE));
	AssignCommand(oPC, ActionUnequipItem(oARMOR));
	return TRUE;
}

void CreatePlayerEssence(object oPC)
{
	if (GetLocalInt(oPC, "CLANGFIX_ESSENCE") == TRUE) return;
	SetLocalInt(oPC, "CLANGFIX_ESSENCE", TRUE);
	object oESSENCE = GetItemPossessedBy(oPC, "clangfix");
	if (oESSENCE != OBJECT_INVALID) return;
	oESSENCE = CreateItemOnObject("clangfix", oPC);
}

void ApplyFixes(object oPC, object oITEM, int nEQUIP)
{
	if (FixSHIELD(oPC) == TRUE) return;
	if (FixARMOR(oPC) == TRUE) return;
	FixIUD(oPC);
	FixSR(oPC);
	FixIMM(oPC);
}

void main(object oITEM, int nEQUIP)
{
	object oPC = OBJECT_SELF;
	if (nEQUIP == TRUE)
	{
		FixItem(oITEM);
		CreatePlayerEssence(oPC);
	}
	RemoveEffectsFromSpell(oPC, CLANG_FXEQUIP);
	DelayCommand(0.0f, ApplyFixes(oPC, oITEM, nEQUIP));
}
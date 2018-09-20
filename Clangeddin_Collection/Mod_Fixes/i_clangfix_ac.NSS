#include "clangeddin_library"

void LoopTheBuffs(object oPC, object oTARGET, int nSPELL, int nTOTAL)
{
	if (nSPELL > nTOTAL) return;
	if (GetHasSpell(nSPELL, oPC) > 0)
	{
		if (GetHasSpellEffect(nSPELL, oTARGET) == FALSE)
		{
			if (GetIsBuffSpell(oPC, oTARGET, nSPELL) == TRUE)
			{
				AssignCommand(oPC, ActionCastSpellAtObject(nSPELL, oTARGET, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
			}
		}
	}
	DelayCommand(0.0f, LoopTheBuffs(oPC, oTARGET, nSPELL + 1, nTOTAL));
}

void StartTheBuffs(object oPC, object oTARGET)
{
	int nTOTAL = GetNum2DARows("spells");
	DelayCommand(0.0f, LoopTheBuffs(oPC, oTARGET, 0, nTOTAL));
}

void main()
{
	object oPC = GetItemActivator();
	if (GetIsInCombat(oPC) == TRUE)
	{
		FloatingTextStringOnCreature("This item cannot be used in combat.", oPC, FALSE);
		return;
	}
	object oITEM = GetItemActivated();
	object oTARGET = GetItemActivatedTarget();
	int nTYPE = GetObjectType(oTARGET);
	if (nTYPE == OBJECT_TYPE_CREATURE)
	{
		if (CLANG_DISABLE_BUFFDEVICE == TRUE) return;
		if (GetIsEnemy(oTARGET, oPC) == TRUE) return;
		if (GetIsDead(oTARGET) == TRUE) return;
		StartTheBuffs(oPC, oTARGET);
	}
	if (nTYPE != OBJECT_TYPE_ITEM) return;
	if (oTARGET == oITEM)
	{
		AutoItemConservation(oPC);
		return;
	}	
	if (GetLocalInt(oTARGET, "CLANGFIX_MODIFIED") != TRUE)
	{
		SendMessageToPC(oPC, "This item was not modified by Clangeddin's Fixes");
		return;
	}
	SendMessageToPC(oPC, GetName(oTARGET) + " - damage immunities and vulnerabilities.");
	int nELEMENT = 1;
	int nITEM;
	string sCOLOR;
	while (nELEMENT < 2050)
	{
		nITEM = GetLocalInt(oTARGET, "CLANGFIX_ELEMENT_" + IntToString(nELEMENT));
		if (nITEM > 0) sCOLOR = "<c=aqua>";
		else if (nITEM < 0) sCOLOR = "<c=red>";
		if (nITEM != 0) SendMessageToPC(oPC, sCOLOR + GetElementString(nELEMENT) + ": " + IntToString(nITEM) + "%.");
		nELEMENT = nELEMENT * 2;
	}
}
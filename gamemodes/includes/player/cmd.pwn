/*
	Player Commands:
		- HELP
		- BWMode
		- Other
*/

//=====================================[ HELP ]============================================
CMD:help(playerid) {
   	SendClientMessage(playerid, COLOR_GREEN,"___________Keki Project___________");
    SendClientMessage(playerid, COLOR_LIGHTCYAN,"[����Ф�] /stats, /changespawn");
	return 1;
}
//=====================================[ BWMode ]============================================
CMD:respawnme(playerid)
{
	if(!isDeathmode{playerid})
		return SendClientMessage(playerid, COLOR_GRAD1, "   �س�ѧ�����");
		
	if(InjuredTime[playerid] <= 0)
	{
		bf_off(player_bf[playerid], IS_SPAWNED);
		
		InjuredTime[playerid] = 0;
		isDeathmode{playerid} = false;
		isInjuredmode{playerid}=false;
		SetPVarInt(playerid, "MedicBill", 1);
		
		resetPlayerDamage(playerid);
		SpawnPlayer(playerid);
	}
	else SendClientMessage(playerid, COLOR_LIGHTRED, "��س��� 60 �Թҷ�");
	
	return 1;
}

CMD:acceptdeath(playerid, params[])
{
    if(!isInjuredmode{playerid} || isDeathmode{playerid})
 		return SendClientMessage(playerid, COLOR_GRAD1, "   �س������Ѻ�Ҵ��");

	if(InjuredTime[playerid] > 120)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �س��ͧ�����һ���ҳ 2 �ҷ����ͷ�������Ѻ�������");

	isDeathmode{playerid} = true;
	InjuredTime[playerid] = 60;
	
    SendClientMessage(playerid, COLOR_YELLOW, "-> �س�������㹢�й�� �س���繵�ͧ�� 60 �Թҷ������ѧ�ҡ��鹤س�֧������ö /respawnme");

    if (!IsPlayerInAnyVehicle(playerid)) 
		ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 0, 0, 1, 0, 1);
    

	return 1;
}
//=====================================[ BWMode ]============================================


//=====================================[ Other ]============================================
CMD:stats(playerid, params[])
{
	ShowStats(playerid,playerid);
	return 1;
}

ShowStats(playerid,targetid)
{
	new string[1000];
	format(string, sizeof string, ""EMBED_WHITE"���� "EMBED_YELLOW"%s "EMBED_WHITE"- [%s]"EMBED_GRAD"", ReturnPlayerName(targetid), ReturnDateTime(2));
	format(string, sizeof string, "%s\n\n����Ф� | �����:["EMBED_WHITE"%d"EMBED_GRAD"]["EMBED_WHITE"%s"EMBED_GRAD"] ��:["EMBED_WHITE"%s"EMBED_GRAD"] �Ҫվ:["EMBED_WHITE"%s"EMBED_GRAD"]", string, playerData[targetid][pFactionID] + 1, Faction_GetName(targetid), Faction_GetRank(targetid), "�����");
	Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "ʶԵ�", string, "�Դ", "");
}

CMD:changespawn(playerid) {
	Dialog_Show(playerid, ChangeSpawnDialog, DIALOG_STYLE_LIST, "����¹���¨ش�Դ", "������ͧ\n��ҹ\nῤ���", "���͡", "�Դ");
	return 1;
}

Dialog:ChangeSpawnDialog(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		if(SPAWN_POINT_PROPERTY == listitem || (SPAWN_POINT_FACTION == listitem && playerData[playerid][pFactionID] == -1)) {
			SendFormatMessage(playerid, COLOR_LIGHTRED, "����ͼԴ��Ҵ"EMBED_WHITE": �س�����%s", inputtext);
			return 1;
		}
		playerData[playerid][pSpawnType] = listitem;
		SendFormatMessage(playerid, -1, "�س�����¨ش�Դ�ͧ�س��ѧ %s", inputtext);
	}
	return 1;
}
//=====================================[ Other ]============================================
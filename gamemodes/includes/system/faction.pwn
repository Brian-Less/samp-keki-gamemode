#include <YSI\y_hooks>

#define FACTION_POLICE		1
#define FACTION_MEDIC		2
#define FACTION_NEWS		3
#define FACTION_ILLEGAL		4

new FillupDelay[MAX_PLAYERS];

forward Faction_Load();
public Faction_Load() {

    new
	    rows, str[8];

	cache_get_row_count(rows);

	for (new i = 0; i < rows; i ++) if (i < MAX_FACTIONS)
	{
        cache_get_value_name_int(i, "id", factionData[i][fID]);
        cache_get_value_name(i, "name", factionData[i][fName], 60);
        cache_get_value_name(i, "short_name", factionData[i][fShortName], 15);
        cache_get_value_name_int(i, "type", factionData[i][fType]);
        cache_get_value_name_int(i, "color", factionData[i][fColor]);
        cache_get_value_name_float(i, "spawnX", factionData[i][fSpawnX]);
        cache_get_value_name_float(i, "spawnY", factionData[i][fSpawnY]);
        cache_get_value_name_float(i, "spawnZ", factionData[i][fSpawnZ]);
        cache_get_value_name_int(i, "spawnInt", factionData[i][fSpawnInt]);
        cache_get_value_name_int(i, "spawnWorld", factionData[i][fSpawnWorld]);
        cache_get_value_name_int(i, "cash", factionData[i][fCash]);

        cache_get_value_name_int(i, "max_skin", factionData[i][fMaxSkins]);
        cache_get_value_name_int(i, "max_rank", factionData[i][fMaxRanks]);
        cache_get_value_name_int(i, "max_veh", factionData[i][fMaxVehicles]);

		if(factionData[i][fSpawnX] != 0.0 && factionData[i][fSpawnY] != 0.0) {
			Faction_SpawnUpdate(i);
		}

		for (new j = 0; j != MAX_FACTION_RANKS; j ++) {
		    format(str, sizeof(str), "rank%d", j);
		    cache_get_value_name(i, str, factionRanks[i][j], 30);
		}

		for (new j = 0; j != MAX_FACTION_SKINS; j ++) {
		    format(str, sizeof(str), "skin%d", j + 1);
		    cache_get_value_name_int(i, str, factionSkins[i][j]);
		}

		for (new j = 0; j != MAX_FACTION_WEAPONS; j ++) {
		    format(str, sizeof(str), "weapon%d", j + 1);
		    cache_get_value_name_int(i, str, factionWeapons[i][j][0]);

		    format(str, sizeof(str), "ammo%d", j + 1);
		    cache_get_value_name_int(i, str, factionWeapons[i][j][1]);
		}

        factionData[i][fOOC] = false;

        Iter_Add(Iter_Faction, i);
	}

    printf("Faction loaded (%d/%d)", Iter_Count(Iter_Faction), MAX_FACTIONS);
	return 1;
}

Faction_Save(id=-1) {
    if(Iter_Contains(Iter_Faction, id)) {
        /*new query[300];
        mysql_format(dbCon, query, sizeof(query), "UPDATE `faction` SET `name`='%e',`short_name`='%e',`type`=%d,`color`=%d,`spawnX`='%f',`spawnY`='%f',`spawnZ`='%f',`spawnA`='%f',`spawnInt`='%d',`spawnWorld`= %d,`cash`=%d,`max_skin`=%d,`max_rank`=%d,`max_veh`=%d WHERE `id`=%d",
            factionData[id][fName],
            factionData[id][fShortName],
            factionData[id][fType],
            factionData[id][fColor],
            factionData[id][fSpawnX],
            factionData[id][fSpawnY],
            factionData[id][fSpawnZ],
			factionData[id][fSpawnA],
            factionData[id][fSpawnInt],
            factionData[id][fSpawnWorld],
            factionData[id][fCash],
            factionData[id][fMaxSkins],
            factionData[id][fMaxRanks],
            factionData[id][fMaxVehicles],
            factionData[id][fID]
        );
        mysql_tquery(dbCon, query);*/

        new query[MAX_STRING];
        MySQLUpdateInit("faction", "id", factionData[id][fID]); 
        MySQLUpdateStr(query, "name", factionData[id][fName]);
        MySQLUpdateStr(query, "short_name", factionData[id][fShortName]);
        MySQLUpdateInt(query, "type", factionData[id][fType]);
        MySQLUpdateInt(query, "color", factionData[id][fColor]);
        MySQLUpdateFlo(query, "spawnX", factionData[id][fSpawnX]);
        MySQLUpdateFlo(query, "spawnY", factionData[id][fSpawnY]);
        MySQLUpdateFlo(query, "spawnZ", factionData[id][fSpawnZ]);
        MySQLUpdateFlo(query, "spawnA", factionData[id][fSpawnA]);
        MySQLUpdateInt(query, "spawnInt", factionData[id][fSpawnInt]);
        MySQLUpdateInt(query, "spawnWorld", factionData[id][fSpawnWorld]);
        MySQLUpdateInt(query, "cash", factionData[id][fCash]);
        MySQLUpdateInt(query, "max_skin", factionData[id][fMaxSkins]);
        MySQLUpdateInt(query, "max_rank", factionData[id][fMaxRanks]);
        MySQLUpdateInt(query, "max_veh", factionData[id][fMaxVehicles]);
		MySQLUpdateFinish(query);
    }
    return 1;
}

Faction_SaveRank(id, slot = -1) {
    if(Iter_Contains(Iter_Faction, id)) {
        new query[80];
		if(slot==-1) {
			for (new j = 0; j != MAX_FACTION_RANKS; j ++) {
				mysql_format(dbCon, query, sizeof(query), "UPDATE `faction` SET `rank%d`='%e' WHERE `id`=%d",j,factionRanks[id][j],factionData[id][fID]);
				mysql_pquery(dbCon, query);
			}
		}
		else {
			mysql_format(dbCon, query, sizeof(query), "UPDATE `faction` SET `rank%d`='%e' WHERE `id`=%d",slot,factionRanks[id][slot],factionData[id][fID]);
			mysql_pquery(dbCon, query);
		}
    }
    return 1;
}

Faction_SaveSkin(id, slot = -1) {
    if(Iter_Contains(Iter_Faction, id)) {
        new query[64];
		if(slot==-1) {
			for (new j = 0; j != MAX_FACTION_SKINS; j ++) {
				format(query, sizeof(query), "UPDATE `faction` SET `skin%d`=%d WHERE `id`=%d",j+1,factionSkins[id][j],factionData[id][fID]);
				mysql_pquery(dbCon, query);
			}
		}
		else {
			format(query, sizeof(query), "UPDATE `faction` SET `skin%d`=%d WHERE `id`=%d",slot+1,factionSkins[id][slot],factionData[id][fID]);
			mysql_pquery(dbCon, query);			
		}
    }
    return 1;
}

Faction_SaveWeapon(id, slot = -1) {
    if(Iter_Contains(Iter_Faction, id)) {
        new query[64];
		if(slot==-1) {
			for (new j = 0; j != MAX_FACTION_WEAPONS; j ++) {
				format(query, sizeof(query), "UPDATE `faction` SET `weapon%d`=%d, `ammo%d`=%d WHERE `id`=%d",j+1,factionWeapons[id][j][0],j+1,factionWeapons[id][j][1],factionData[id][fID]);
				mysql_pquery(dbCon, query);
			}
		}
		else {
			format(query, sizeof(query), "UPDATE `faction` SET `weapon%d`=%d, `ammo%d`=%d WHERE `id`=%d",slot+1,factionWeapons[id][slot][0],slot+1,factionWeapons[id][slot][1],factionData[id][fID]);
			mysql_pquery(dbCon, query);			
		}
    }
    return 1;
}

CMD:factionhelp(playerid) {
	SendClientMessage(playerid, COLOR_GRAD1, "�����: (/gov)ernment, /invite, /uninvite, /suit");
	return 1;
}

CMD:suit(playerid, params[]) {

	new skinid, faction_id = playerData[playerid][pFactionID];

	if (faction_id == -1)
	    return SendClientMessage(playerid, COLOR_GRAD1, "   �س��ͧ����Ҫԡ�ͧῤ���");

	if (factionData[faction_id][fMaxSkins] == 0)
		return SendClientMessage(playerid, COLOR_LIGHTRED, "ʡԹ�ѧ���١��駤���ô�Դ��ͼ������к�!");

	if (sscanf(params, "d", skinid)) {
        SendClientMessage(playerid, COLOR_GREEN,    "___________________________[�����]___________________________");
        SendFormatMessage(playerid, COLOR_GRAD1,    "�����: /suit [�����Ţ 1-%d]", factionData[faction_id][fMaxSkins]);
	    return 1;
	}

	if (skinid <= 0 || skinid > factionData[faction_id][fMaxSkins]) {
	    return SendFormatMessage(playerid, COLOR_GRAD1, "   ʡԹ����к����١��ͧ ʡԹ��ͧ���������ҧ 1 �֧ %d", factionData[faction_id][fMaxSkins]);
	}

	if(!IsPlayerInRangeOfPoint(playerid, 2.5, factionData[faction_id][fSpawnX], factionData[faction_id][fSpawnY], factionData[faction_id][fSpawnZ]) && GetPlayerVirtualWorld(playerid) == factionData[faction_id][fSpawnWorld]) {
		return  SendClientMessage(playerid, COLOR_GRAD1, "   �س�����������ش�Դῤ��蹢ͧ�س ");
	}

	SetPlayerSkin(playerid, factionSkins[faction_id][skinid - 1]);
	playerData[playerid][pModel] = factionSkins[faction_id][skinid - 1];

	return 1;
}

flags:factioncmds(CMD_MM)
CMD:factioncmds(playerid) {
    SendClientMessage(playerid, COLOR_GRAD1, "�����: /viewfactions, /makefaction, /removefaction");
    return 1;
}

flags:viewfactions(CMD_LEAD)
CMD:viewfactions(playerid) {
    ViewFactions(playerid);
    return 1;
}

flags:makefaction(CMD_MM)
CMD:makefaction(playerid, params[])
{
	new
        id,
		type,
        abbrev[15],
		name[60];

	if (sscanf(params, "ds[15]s[60]", type, abbrev, name))
	{
        SendClientMessage(playerid, COLOR_GREEN,    "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1,    "�����: /makefaction [������] [�������] [���ͽ���]");
        SendClientMessage(playerid, COLOR_GRAD2,    "[������] 1: ���ѧ�Ѻ�顮���� (Law Enforcement) - 2: ᾷ�� (Medical) - 3: �ѡ���� (News Network) - 4: �Դ������");
	    SendClientMessage(playerid, COLOR_LIGHTRED, "[ ! ]"EMBED_WHITE" ������������ժ�ͧ��ҧ");
		return 1;
	}

    if(type < 1 || type > 4) {
        SendClientMessage(playerid, COLOR_RED,   "�Դ��Ҵ: "EMBED_WHITE"������ῤ��蹵�ͧ����ӡ��� 1 �����ҡ���� 4");
        return 1;
    }

    if((id = Iter_Free(Iter_Faction)) != -1) {

	    format(factionData[id][fName], 60, name);
        format(factionData[id][fShortName], 15, abbrev);

        factionData[id][fColor] = 0xFFFFFF;
        factionData[id][fType] = type;
        factionData[id][fMaxRanks] = 6;
        factionData[id][fMaxSkins] = 0;
        factionData[id][fMaxVehicles] = 0;

		for (new j = 0; j != MAX_FACTION_RANKS; j ++) {
		    format(factionRanks[id][j], 30, "�� %d", j + 1);
		}

		for (new j = 0; j != MAX_FACTION_SKINS; j ++) {
		    factionSkins[id][j] = 0;
		}

	    mysql_tquery(dbCon, "INSERT INTO `faction` (`type`) VALUES(0)", "OnFactionCreated", "d", id);

        SendFormatMessage(playerid, COLOR_GREY, "���������: "EMBED_WHITE"�س�����ҧῤ����ʹ� "EMBED_ORANGE"%d", id + 1);

        Iter_Add(Iter_Faction, id);
    }
    else {
        SendFormatMessage(playerid, COLOR_RED,   "�Դ��Ҵ: "EMBED_WHITE"�������ö���ҧῤ������ҡ���ҹ������ �ӡѴ����� "EMBED_ORANGE"%d", MAX_FACTIONS);
    }
	return 1;
}

CMD:removefaction(playerid, params[]) {
	new
	    id = 0;

	if (sscanf(params, "d", id))
 	{
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
		SendClientMessage(playerid, COLOR_GRAD1, "�����: /removefaction [�ʹ� (/viewfactions)]");
		return 1;
	}

	id--;
	if(Iter_Contains(Iter_Faction, id))
	{
		new
	        string[80];

		//�Ŵ�������͡�ҡῤ��蹷��١ź
		format(string, sizeof(string), "UPDATE `players` SET `faction`=0,`spawntype`=0  WHERE `faction`=%d", factionData[id][fID]);
		mysql_tquery(dbCon, string);

		foreach (new i : Player)
		{
			if (playerData[i][pFaction] == factionData[id][fID]) {
		    	playerData[i][pFaction] = 0;
		    	playerData[i][pFactionID] = -1;
		    	playerData[i][pFactionRank] = 0;
				SetPlayerSkin(i, playerData[i][pModel]);
			}
			DeletePVar(i, "FactionEditID");
		}

		//ź�ҹ��˹з������ͧῤ���

		foreach(new i : Iter_ServerCar) {
			new
				cur = i;
			if(vehicleVariables[i][vVehicleFaction] != 0 && vehicleVariables[i][vVehicleFaction] == factionData[id][fID]) {

				Log(a_action_log, INFO, "%s: ź�ҹ��˹� %s(SQLID %d) �ͧῤ��� %s(%d)", ReturnPlayerName(playerid), ReturnVehicleModelName(vehicleVariables[i][vVehicleModelID]), vehicleVariables[i][vVehicleID], factionData[id][fName], factionData[id][fID]);

				format(string, sizeof(string), "DELETE FROM `vehicle` WHERE `vehicleID` = '%d'", vehicleVariables[i][vVehicleID]);
				mysql_tquery(dbCon, string);

				DestroyVehicle(vehicleVariables[i][vVehicleScriptID]);
				Iter_SafeRemove(Iter_ServerCar, cur, i);
			}
		}

		format(string, sizeof(string), "DELETE FROM `faction` WHERE `id` = '%d'", factionData[id][fID]);
		mysql_tquery(dbCon, string);

		if(IsValidDynamic3DTextLabel(factionData[id][fLabelSpawn])) 
			DestroyDynamic3DTextLabel(factionData[id][fLabelSpawn]);
		
		if(IsValidDynamicPickup(factionData[id][fPickupSpawn])) 
			DestroyDynamicPickup(factionData[id][fPickupSpawn]);

		Log(a_action_log, INFO, "%s: źῤ��� %s(%d)", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID]);

		SendFormatMessage(playerid, COLOR_GRAD1, "   �س��źῤ����ʹ� %d", id + 1);
		Iter_Remove(Iter_Faction, id);
	}
	else {
		SendFormatMessage(playerid, COLOR_LIGHTRED, "��辺ῤ����ʹ� %d ������к�", id + 1);
	}
	return 1;
}

forward OnFactionCreated(factionid);
public OnFactionCreated(factionid)
{
	if (factionid == -1)
	    return 0;

	factionData[factionid][fID] = cache_insert_id();

	Faction_Save(factionid);
	Faction_SaveRank(factionid);
    Faction_SaveSkin(factionid);
	return 1;
}

ViewFactions(playerid)
{
	new string[2048], menu[20], count;

	format(string, sizeof(string), "%s{B4B5B7}˹�� 1\n", string);

	SetPVarInt(playerid, "page", 1);

	foreach(new i : Iter_Faction) {
		if(count == 20)
		{
			format(string, sizeof(string), "%s{B4B5B7}˹�� 2\n", string);
			break;
		}
		format(menu, 20, "menu%d", ++count);
		SetPVarInt(playerid, menu, i);
		format(string, sizeof(string), "%s({FFBF00}%i"EMBED_WHITE") | "EMBED_YELLOW"%s\n", string, i + 1, factionData[i][fName]);
	}
	if(!count) Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "��ª���ῤ���", "��辺�����Ţͧῤ���..", "�Դ", "");
	else Dialog_Show(playerid, FactionsList, DIALOG_STYLE_LIST, "��ª���ῤ���", string, "���", "��Ѻ");
	return 1;
}

Dialog:FactionsList(playerid, response, listitem, inputtext[])
{
	if(response) {

		new menu[20];
		//Navigate
		if(listitem != 0 && listitem != 21) {

			if(!(playerData[playerid][pCMDPermission] & CMD_MM)) {
				SendClientMessage(playerid, COLOR_LIGHTRED, "�Դ��ͼԴ��Ҵ"EMBED_WHITE": �س������Ѻ͹حҵ�����ѧ���蹡����� "EMBED_RED"(MANAGEMENT ONLY)");
				return ViewFactions(playerid);
			}
			new str_biz[20];
			format(str_biz, 20, "menu%d", listitem);

			SetPVarInt(playerid, "FactionEditID", GetPVarInt(playerid, str_biz));
			ShowPlayerEditFaction(playerid);
			return 1;
		}

		new currentPage = GetPVarInt(playerid, "page");
		if(listitem==0) {
			if(currentPage>1) currentPage--;
		}
		else if(listitem == 21) currentPage++;

		new string[2048], count;
		format(string, sizeof(string), "%s{B4B5B7}˹�� %d\n", string, (currentPage==1) ? 1 : currentPage-1);

		SetPVarInt(playerid, "page", currentPage);

		new skipitem = (currentPage-1) * 20;

		foreach(new i : Iter_Faction) {

			if(skipitem)
			{
				skipitem--;
				continue;
			}
			if(count == 20)
			{
				format(string, sizeof(string), "%s{B4B5B7}˹�� 2\n", string);
				break;
			}
			format(menu, 20, "menu%d", ++count);
			SetPVarInt(playerid, menu, i);
			format(string, sizeof(string), "%s({FFBF00}%i"EMBED_WHITE") | "EMBED_YELLOW"%s\n", string, i + 1, factionData[i][fName]);

		}

		Dialog_Show(playerid, FactionsList, DIALOG_STYLE_LIST, "��ª���ῤ���", string, "���", "��Ѻ");
	}
	return 1;
}

ShowPlayerEditFaction(playerid)
{
    new id = GetPVarInt(playerid, "FactionEditID");
	if(Iter_Contains(Iter_Faction, id))
	{
		new caption[128], dialog_str[1024];
		format(caption, sizeof(caption), "���ῤ���: "EMBED_YELLOW"%s"EMBED_WHITE"(SQLID:%d)", factionData[id][fName], factionData[id][fID]);
        format(dialog_str, sizeof dialog_str, "����\t%s\n", factionData[id][fName]);
        format(dialog_str, sizeof dialog_str, "%s�������\t%s\n", dialog_str, factionData[id][fShortName]);
        format(dialog_str, sizeof dialog_str, "%s��\t{%06x}%06x\n", dialog_str, factionData[id][fColor], factionData[id][fColor]);
        format(dialog_str, sizeof dialog_str, "%s������\t%s\n", dialog_str, GetFactionTypeName(factionData[id][fType]));
        format(dialog_str, sizeof dialog_str, "%s��\t%d/%d\n", dialog_str, factionData[id][fMaxRanks], MAX_FACTION_RANKS);
        format(dialog_str, sizeof dialog_str, "%sʡԹ\t%d/%d\n", dialog_str, factionData[id][fMaxSkins], MAX_FACTION_SKINS);
        format(dialog_str, sizeof dialog_str, "%s�ҹ��˹��٧�ش\t%d\n", dialog_str, factionData[id][fMaxVehicles]);
        format(dialog_str, sizeof dialog_str, "%s���ظ\t[��������´�������]\n", dialog_str);
        format(dialog_str, sizeof dialog_str, "%s��Ѻ�ش�Դ���ѧ�ش�Ѩ�غѹ�ͧ�س", dialog_str);
		Dialog_Show(playerid, FactionEdit, DIALOG_STYLE_TABLIST, caption, dialog_str, "���", "��Ѻ");
	}
	return 1;
}

Dialog:FactionEdit(playerid, response, listitem, inputtext[])
{
	if(response) {

		new caption[128];    
        new id = GetPVarInt(playerid, "FactionEditID");
		switch(listitem)
		{
			case 0: // ��䢪���
			{
				format(caption, sizeof(caption), "��� -> ����: "EMBED_YELLOW"%s", factionData[id][fName]);
				Dialog_Show(playerid, FactionEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_ORANGE"0 "EMBED_WHITE"�������Թ "EMBED_ORANGE"60 "EMBED_WHITE"����ѡ��\n\n��͡����ῤ��蹷���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 1: // ��䢪������
			{
				format(caption, sizeof(caption), "��� -> �������: "EMBED_YELLOW"%s", factionData[id][fShortName]);
				Dialog_Show(playerid, FactionEdit_ShortName, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������Ǣͧ������͵�ͧ�ҡ���� "EMBED_ORANGE"0 "EMBED_WHITE"�������Թ "EMBED_ORANGE"15 "EMBED_WHITE"����ѡ��\n\n��͡����ῤ��蹷���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 2: // �����
			{
				format(caption, sizeof(caption), "��� -> ��: {%06x}%06x", factionData[id][fColor], factionData[id][fColor]);
				Dialog_Show(playerid, FactionEdit_Color, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������ҧ����: "EMBED_YELLOW"ffff00"EMBED_WHITE"\n\n��͡���շ���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 3: // ��䢻�����
			{
				format(caption, sizeof(caption), "��� -> ������: %s", GetFactionTypeName(factionData[id][fType]));
				Dialog_Show(playerid, FactionEdit_Type, DIALOG_STYLE_LIST, caption, "1: ���ѧ�Ѻ�顮���� (Law Enforcement)\n2: ᾷ�� (Medical)\n3: �ѡ���� (News Network)\n4: �Դ������", "����¹", "��Ѻ");
			}
			case 4: // �����
			{
				Dialog_Show(playerid, FactionEdit_Rank, DIALOG_STYLE_LIST, "��� -> ��", "�ӹǹ��\t(%d/%d)\n������\t", "���", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS);
			}
			case 5: // ���ʡԹ
			{
				Dialog_Show(playerid, FactionEdit_Skin, DIALOG_STYLE_LIST, "��� -> ʡԹ", "�ӹǹʡԹ\t(%d/%d)\n�ʹ�ʡԹ\t", "���", "��Ѻ", factionData[id][fMaxSkins], MAX_FACTION_SKINS);
			}
			case 6: // ��䢨ӹǹ��˹��٧�ش
			{
				Dialog_Show(playerid, FactionEdit_VehMax, DIALOG_STYLE_INPUT, "��� -> ��˹�", "�Ѩ�غѹ: %d\n\n��͡�ӹǹ��˹��٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxVehicles]);
			}
			case 7: // ���ظ
			{
				ShowPlayerEditFaction_Weapon(playerid);
			}
			case 8: // �ش�Դ
			{
				format(caption, sizeof(caption), "��� -> ��䢨ش�Դ");
				Dialog_Show(playerid, FactionEdit_Spawn, DIALOG_STYLE_MSGBOX, caption, "�س������ͷ��л�Ѻ�ش�Դῤ��蹹�����ѧ���˹觻Ѩ�غѹ�ͧ�س", "�׹�ѹ", "��Ѻ");
			}
		}
	}
	else
	{
	    DeletePVar(playerid, "FactionEditID");
        ViewFactions(playerid);
	}
    return 1;
}

Dialog:FactionEdit_SetRankName(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new rank_slot = GetPVarInt(playerid, "FactionEditSlot"), id = GetPVarInt(playerid, "FactionEditID");

	    if (isnull(inputtext))
			return Dialog_Show(playerid, FactionEdit_SetRankName, DIALOG_STYLE_INPUT, "�� -> ������", ""EMBED_WHITE"��: "EMBED_YELLOW"%s "EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n��سһ�͹�����������ҹ��ҧ���:", "����¹", "��Ѻ", factionRanks[id][rank_slot], rank_slot + 1);

	    if (strlen(inputtext) < 1 || strlen(inputtext) > 30)
	        return Dialog_Show(playerid, FactionEdit_SetRankName, DIALOG_STYLE_INPUT, "�� -> ������", ""EMBED_WHITE"��: "EMBED_YELLOW"%s "EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n"EMBED_LIGHTRED"��ͼԴ��Ҵ"EMBED_WHITE": ������Ǣͧ���͵�ͧ����ӡ��� "EMBED_ORANGE"1"EMBED_WHITE" �����ҡ���� "EMBED_ORANGE"30"EMBED_WHITE"\n\n��سһ�͹�����������ҹ��ҧ���:", "����¹", "��Ѻ", factionRanks[id][rank_slot], rank_slot + 1);

		SendFormatMessage(playerid, COLOR_GRAD, " �����Ȣͧ "EMBED_WHITE"%s"EMBED_GRAD" �ȷ�� "EMBED_WHITE"%d"EMBED_GRAD" �ҡ "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", factionData[id][fName], rank_slot + 1, factionRanks[id][rank_slot], inputtext);
		Log(a_action_log, INFO, "%s: ����¹�����Ȣͧ %s(%d) �ȷ�� %d �ҡ %s �� %s", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], rank_slot + 1, factionRanks[id][rank_slot], inputtext);
		format(factionRanks[id][rank_slot], 30, inputtext);
	    Faction_SaveRank(id, rank_slot);
	}
	return ShowPlayerEditFaction_RankList(playerid);
}

ShowPlayerEditFaction_RankList(playerid) {
	new
		string[45 * MAX_FACTION_RANKS], id = GetPVarInt(playerid, "FactionEditID");

	for (new i = 0; i < factionData[id][fMaxRanks]; i ++)
		format(string, sizeof(string), "%s�� %d: "EMBED_YELLOW"%s\n", string, i + 1, factionRanks[id][i]);

	return Dialog_Show(playerid, FactionEdit_RankName, DIALOG_STYLE_LIST, "�� -> ������", string, "���", "��Ѻ");
}

Dialog:FactionEdit_RankName(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "FactionEditID");
	if (response)
	{
		SetPVarInt(playerid, "FactionEditSlot", listitem);
		return Dialog_Show(playerid, FactionEdit_SetRankName, DIALOG_STYLE_INPUT, "�� -> ������", ""EMBED_WHITE"��: "EMBED_YELLOW"%s "EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n��سһ�͹�����������ҹ��ҧ���:", "����¹", "��Ѻ", factionRanks[id][listitem], listitem + 1);
	}
	return Dialog_Show(playerid, FactionEdit_Rank, DIALOG_STYLE_LIST, "��� -> ��", "�ӹǹ��\t(%d/%d)\n������\t", "���", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS);
}

Dialog:FactionEdit_Rank(playerid, response, listitem, inputtext[])
{
	if(response) { 
        new id = GetPVarInt(playerid, "FactionEditID");
		switch(listitem) {
			case 0: {
				return Dialog_Show(playerid, FactionEdit_RankMax, DIALOG_STYLE_INPUT, "��� -> ��", ""EMBED_WHITE"�Ѩ�غѹ: %d/%d\n\n��͡�ӹǹ���٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS);
			}
			case 1: {
				if(factionData[id][fMaxRanks] == 0) return Dialog_Show(playerid, FactionEdit_Rank, DIALOG_STYLE_LIST, "��� -> ��", "�ӹǹ��\t(%d/%d)\n������\t", "���", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS);
				else return ShowPlayerEditFaction_RankList(playerid);
			}
		}
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_RankMax(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "FactionEditID");
	if(response) {
		new typeint = strval(inputtext);
		if(typeint < 0 || typeint > MAX_FACTION_RANKS) {
			return Dialog_Show(playerid, FactionEdit_RankMax, DIALOG_STYLE_INPUT, "��� -> ��", ""EMBED_WHITE"�Ѩ�غѹ: %d/%d\n"EMBED_LIGHTRED"��ͼԴ��Ҵ"EMBED_WHITE": �ӹǹ��ͧ����ӡ��� "EMBED_ORANGE"0"EMBED_WHITE" �����ҡ���� "EMBED_ORANGE"%d"EMBED_WHITE"\n\n��͡�ӹǹ���٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS, MAX_FACTION_RANKS);
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ���٧�ش�ͧ "EMBED_WHITE"%s"EMBED_GRAD" �ҡ "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", factionData[id][fName], factionData[id][fMaxRanks], typeint);
		Log(a_action_log, INFO, "%s: ����¹���٧�ش�ͧ %s(%d) �ҡ %d �� %d", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fMaxRanks], typeint);
	    factionData[id][fMaxRanks] = typeint;
	    Faction_Save(id);
	}
	return Dialog_Show(playerid, FactionEdit_Rank, DIALOG_STYLE_LIST, "��� -> ��", "�ӹǹ��\t(%d/%d)\n������\t", "���", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS);
}

Dialog:FactionEdit_VehMax(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "FactionEditID");
	if(response) {
		new typeint = strval(inputtext);
		if(typeint < 0) {
			return Dialog_Show(playerid, FactionEdit_VehMax, DIALOG_STYLE_INPUT, "��� -> ��˹�", "�Ѩ�غѹ: %d\n\n��͡�ӹǹ��˹��٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxVehicles]);
		}
		Log(a_action_log, INFO, "%s: ����¹�ӹǹ��˹��٧�ش�ͧ %s(%d) �ҡ %d �� %d", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fMaxVehicles], typeint);
	    factionData[id][fMaxVehicles] = typeint;
	    Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_Type(playerid, response, listitem, inputtext[])
{
	if(response) {
		new id = GetPVarInt(playerid, "FactionEditID");
		listitem++;
		SendFormatMessage(playerid, COLOR_GRAD, " ���ͻ����� "EMBED_WHITE"%s"EMBED_GRAD" �ҡ "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", factionData[id][fName], GetFactionTypeName(factionData[id][fType]), GetFactionTypeName(listitem));
		Log(a_action_log, INFO, "%s: ����¹������ %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], GetFactionTypeName(factionData[id][fType]), GetFactionTypeName(listitem));

		factionData[id][fType] = listitem;
	    Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_Color(playerid, response, listitem, inputtext[])
{
	if(response) {

		new caption[128], id = GetPVarInt(playerid, "FactionEditID"), color;
		if (strlen(inputtext) != 6 || sscanf(inputtext, "x", color)) {
			format(caption, sizeof(caption), "��� -> ��: {%06x}%06x", factionData[id][fColor], factionData[id][fColor]);
			return Dialog_Show(playerid, FactionEdit_Color, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������ҧ����: "EMBED_YELLOW"ffff00"EMBED_WHITE"\n\n��͡���շ���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ������ "EMBED_WHITE"%s"EMBED_GRAD" �� {%06x}%06x"EMBED_GRAD"", factionData[id][fName], color, color);
		
		new string[256];
		format(string, sizeof string, "%s: ����¹�� %s(%d) �ҡ %06x �� %06x", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fColor], color);
		Log(a_action_log, INFO, string);

	    factionData[id][fColor] = color;
	    Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_Name(playerid, response, listitem, inputtext[])
{
	if(response) {
		new caption[128];
		new id = GetPVarInt(playerid, "FactionEditID");

		if(isnull(inputtext) || strlen(inputtext) >= 60) {
			format(caption, sizeof(caption), "��� -> ����: "EMBED_YELLOW"%s", factionData[id][fName]);
			Dialog_Show(playerid, FactionEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"����ͼԴ��Ҵ:\n"EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_YELLOW"0 "EMBED_WHITE"�������Թ "EMBED_YELLOW"60 "EMBED_WHITE"����ѡ��", "����¹", "��Ѻ");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ���� "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", factionData[id][fName], inputtext);
		Log(a_action_log, INFO, "%s: ����¹���� %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fName], inputtext);

		format(factionData[id][fName], 60, inputtext);

		Faction_SpawnUpdate(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

		Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_ShortName(playerid, response, listitem, inputtext[])
{
	if(response) {
		new caption[128];
		new id = GetPVarInt(playerid, "FactionEditID");

		if(isnull(inputtext) || strlen(inputtext) >= 15) {
			format(caption, sizeof(caption), "��� -> �������: "EMBED_YELLOW"%s", factionData[id][fShortName]);
			Dialog_Show(playerid, FactionEdit_ShortName, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"����ͼԴ��Ҵ:\n"EMBED_WHITE"������Ǣͧ������͵�ͧ�ҡ���� "EMBED_YELLOW"0 "EMBED_WHITE"�������Թ "EMBED_YELLOW"15 "EMBED_WHITE"����ѡ��", "����¹", "��Ѻ");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ������� "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", factionData[id][fShortName], inputtext);
		Log(a_action_log, INFO, "%s: ����¹������� %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fShortName], inputtext);
	
		format(factionData[id][fShortName], 15, inputtext);
		Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

GetFactionTypeName(type) {
    new faction_type[24];
    switch(type) {
        case 1: format(faction_type, sizeof faction_type, "���ѧ�Ѻ�顮����");
        case 2: format(faction_type, sizeof faction_type, "ᾷ��");
        case 3: format(faction_type, sizeof faction_type, "�ѡ����");
        case 4: format(faction_type, sizeof faction_type, "�Դ������");
        default: format(faction_type, sizeof faction_type, "����к�");
    }
    return faction_type;
}

Faction_Name(factionid)
{
    new
		name[60] = "��ЪҪ�";

 	if (factionid == -1)
	    return name;

	format(name, 60, factionData[factionid][fName]);
	return name;
}

Faction_GetName(playerid)
{
    new
		factionid = playerData[playerid][pFactionID],
		name[60] = "��ЪҪ�";

 	if (factionid == -1)
	    return name;

	format(name, 60, factionData[factionid][fName]);
	return name;
}

Faction_GetRank(playerid)
{
    new
		factionid = playerData[playerid][pFactionID],
		rank[30] = "�����";

 	if (factionid == -1)
	    return rank;

	format(rank, 30, factionRanks[factionid][playerData[playerid][pFactionRank] - 1]);
	return rank;
}

Faction_SpawnUpdate(id) {
	new string[128];

	if(IsValidDynamic3DTextLabel(factionData[id][fLabelSpawn])) 
		DestroyDynamic3DTextLabel(factionData[id][fLabelSpawn]);
	
	if(IsValidDynamicPickup(factionData[id][fPickupSpawn])) 
		DestroyDynamicPickup(factionData[id][fPickupSpawn]);

	format(string, sizeof(string), "� %s"EMBED_WHITE" �\n������ \""EMBED_YELLOW"N"EMBED_WHITE"\" ������Ժ���ظ", factionData[id][fName]);
	factionData[id][fLabelSpawn] = CreateDynamic3DTextLabel(string, -1, factionData[id][fSpawnX], factionData[id][fSpawnY], factionData[id][fSpawnZ], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, factionData[id][fSpawnWorld], factionData[id][fSpawnInt], -1, 25.0);

	factionData[id][fPickupSpawn] = CreateDynamicPickup(356, 23, factionData[id][fSpawnX], factionData[id][fSpawnY], factionData[id][fSpawnZ], factionData[id][fSpawnWorld], factionData[id][fSpawnInt], -1, 25.0);
	return 1;
}

Dialog:FactionEdit_Skin(playerid, response, listitem, inputtext[])
{
	if(response) { 
        new id = GetPVarInt(playerid, "FactionEditID");
		switch(listitem) {
			case 0: {
				return Dialog_Show(playerid, FactionEdit_SkinMax, DIALOG_STYLE_INPUT, "��� -> ʡԹ", ""EMBED_WHITE"�Ѩ�غѹ: %d/%d\n\n��͡�ӹǹʡԹ�٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxSkins], MAX_FACTION_SKINS);
			}
			case 1: {
				if(factionData[id][fMaxSkins] == 0) return Dialog_Show(playerid, FactionEdit_Skin, DIALOG_STYLE_LIST, "��� -> ʡԹ", "�ӹǹʡԹ\t(%d/%d)\n�ʹ�ʡԹ\t", "���", "��Ѻ", factionData[id][fMaxSkins], MAX_FACTION_SKINS);
				else return ShowPlayerEditFaction_SkinList(playerid);
			}
		}
	}
	return ShowPlayerEditFaction(playerid);
}

ShowPlayerEditFaction_SkinList(playerid) {
	new
		string[45 * MAX_FACTION_SKINS], id = GetPVarInt(playerid, "FactionEditID");

	for (new i = 0; i < factionData[id][fMaxSkins]; i ++)
		format(string, sizeof(string), "%sʡԹ %d: "EMBED_YELLOW"%d\n", string, i + 1, factionSkins[id][i]);

	return Dialog_Show(playerid, FactionEdit_SkinID, DIALOG_STYLE_LIST, "ʡԹ -> �ʹ�ʡԹ", string, "���", "��Ѻ");
}

Dialog:FactionEdit_SkinMax(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "FactionEditID");
	if(response) {
		new typeint = strval(inputtext);
		if(typeint < 0 || typeint > MAX_FACTION_SKINS) {
			return Dialog_Show(playerid, FactionEdit_SkinMax, DIALOG_STYLE_INPUT, "��� -> ʡԹ", ""EMBED_WHITE"�Ѩ�غѹ: %d/%d\n"EMBED_LIGHTRED"��ͼԴ��Ҵ"EMBED_WHITE": �ӹǹ��ͧ����ӡ��� "EMBED_ORANGE"0"EMBED_WHITE" �����ҡ���� "EMBED_ORANGE"%d"EMBED_WHITE"\n\n��͡�ӹǹʡԹ�٧�ش㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ", factionData[id][fMaxRanks], MAX_FACTION_RANKS, MAX_FACTION_RANKS);
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ʡԹ�٧�ش�ͧ "EMBED_WHITE"%s"EMBED_GRAD" �ҡ "EMBED_WHITE"%d"EMBED_GRAD" �� "EMBED_WHITE"%d"EMBED_GRAD"", factionData[id][fName], factionData[id][fMaxSkins], typeint);
		Log(a_action_log, INFO, "%s: ����¹ʡԹ�٧�ش�ͧ %s(%d) �ҡ %d �� %d", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fMaxSkins], typeint);

	    factionData[id][fMaxSkins] = typeint;
	    Faction_Save(id);
	}
	return Dialog_Show(playerid, FactionEdit_Skin, DIALOG_STYLE_LIST, "��� -> ʡԹ", "�ӹǹʡԹ\t(%d/%d)\n�ʹ�ʡԹ\t", "���", "��Ѻ", factionData[id][fMaxSkins], MAX_FACTION_SKINS);
}

Dialog:FactionEdit_SkinID(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "FactionEditID");
	if (response)
	{
		SetPVarInt(playerid, "FactionEditSlot", listitem);
		return Dialog_Show(playerid, FactionEdit_SetSkinID, DIALOG_STYLE_INPUT, "ʡԹ -> �ʹ�ʡԹ", ""EMBED_WHITE"ʡԹ: "EMBED_YELLOW"%d "EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n��سһ�͹�ʹ�ʡԹ�����ҹ��ҧ���:", "����¹", "��Ѻ", factionSkins[id][listitem], listitem + 1);
	}
	return Dialog_Show(playerid, FactionEdit_Skin, DIALOG_STYLE_LIST, "��� -> ʡԹ", "�ӹǹʡԹ\t(%d/%d)\n�ʹ�ʡԹ\t", "���", "��Ѻ", factionData[id][fMaxSkins], MAX_FACTION_RANKS);
}

Dialog:FactionEdit_SetSkinID(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new skin_slot = GetPVarInt(playerid, "FactionEditSlot"), id = GetPVarInt(playerid, "FactionEditID"), skin_id = strval(inputtext);

	    if (isnull(inputtext))
			return Dialog_Show(playerid, FactionEdit_SetSkinID, DIALOG_STYLE_INPUT, "ʡԹ -> �ʹ�ʡԹ", ""EMBED_WHITE"ʡԹ: "EMBED_YELLOW"%d "EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n��سһ�͹�ʹ�ʡԹ�����ҹ��ҧ���:", "����¹", "��Ѻ", factionSkins[id][skin_slot], skin_slot + 1);

		SendFormatMessage(playerid, COLOR_GRAD, " �ʹ�ʡԹ�ͧ "EMBED_WHITE"%s"EMBED_GRAD" ʡԹ��� %d �ҡ "EMBED_WHITE"%d"EMBED_GRAD" �� "EMBED_WHITE"%d"EMBED_GRAD"", factionData[id][fName], skin_slot + 1, factionSkins[id][skin_slot], skin_id);
		Log(a_action_log, INFO, "%s: ����¹�ʹ�ʡԹ�ͧ %s(%d) ʡԹ��� %d �ҡ %d �� %d", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], skin_slot + 1, factionSkins[id][skin_slot], skin_id);
		factionSkins[id][skin_slot] = skin_id;
	    Faction_SaveSkin(id, skin_slot);
	}
	return ShowPlayerEditFaction_SkinList(playerid);
}

ShowPlayerEditFaction_Weapon(playerid) {
	new
		string[64 * MAX_FACTION_WEAPONS], id = GetPVarInt(playerid, "FactionEditID");

	for (new i = 0; i < MAX_FACTION_WEAPONS; i ++) {
		if(i==0) format(string, sizeof(string), ""EMBED_YELLOW"%s"EMBED_WHITE"(%d) �ӹǹ "EMBED_ORANGE"%d", ReturnFactionWeaponName(factionWeapons[id][i][0]), factionWeapons[id][i][0], factionWeapons[id][i][1]);
		else format(string, sizeof(string), "%s\n"EMBED_YELLOW"%s"EMBED_WHITE"(%d) �ӹǹ "EMBED_ORANGE"%d", string, ReturnFactionWeaponName(factionWeapons[id][i][0]), factionWeapons[id][i][0], factionWeapons[id][i][1]);
	}
	return Dialog_Show(playerid, FactionEdit_Weapon, DIALOG_STYLE_LIST, "��� -> ������ظ", string, "���", "��Ѻ");
}

Dialog:FactionEdit_Weapon(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new id = GetPVarInt(playerid, "FactionEditID");
		SetPVarInt(playerid, "FactionEditSlot", listitem);
		return Dialog_Show(playerid, FactionEdit_SetWeapon, DIALOG_STYLE_INPUT, "��� -> ������ظ", ""EMBED_WHITE"��ͧ��� %d: "EMBED_YELLOW"%s"EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n������ҧ \""EMBED_YELLOW"�ʹ����ظ "EMBED_ORANGE"�ӹǹ"EMBED_WHITE"\": \n����� \""EMBED_YELLOW"31 "EMBED_ORANGE"300"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"M4 "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"300"EMBED_WHITE")\n����� \""EMBED_YELLOW"100 "EMBED_ORANGE"200"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"���ʹ "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"200"EMBED_WHITE")\n\n�������: \n�ʹ� "EMBED_YELLOW"100"EMBED_WHITE" = ���ʹ \n�ʹ� "EMBED_YELLOW"200"EMBED_WHITE" = ����\n\n��سһ�͹�ʹ����ظ��ҹ��ҧ���", "��駤��", "��Ѻ", listitem + 1, ReturnFactionWeaponName(factionWeapons[id][listitem][0]), factionWeapons[id][listitem][1]);
	}
	return ShowPlayerEditFaction(playerid);
}

Dialog:FactionEdit_SetWeapon(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new wp_slot = GetPVarInt(playerid, "FactionEditSlot"), id = GetPVarInt(playerid, "FactionEditID");

	    if (isnull(inputtext))
			return Dialog_Show(playerid, FactionEdit_SetWeapon, DIALOG_STYLE_INPUT, "��� -> ������ظ", ""EMBED_WHITE"��ͧ��� %d: "EMBED_YELLOW"%s"EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n������ҧ \""EMBED_YELLOW"�ʹ����ظ "EMBED_ORANGE"�ӹǹ"EMBED_WHITE"\": \n����� \""EMBED_YELLOW"31 "EMBED_ORANGE"300"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"M4 "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"300"EMBED_WHITE")\n����� \""EMBED_YELLOW"100 "EMBED_ORANGE"200"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"���ʹ "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"200"EMBED_WHITE")\n\n�������: \n�ʹ� "EMBED_YELLOW"100"EMBED_WHITE" = ���ʹ \n�ʹ� "EMBED_YELLOW"200"EMBED_WHITE" = ����\n\n��سһ�͹�ʹ����ظ��ҹ��ҧ���", "��駤��", "��Ѻ", 
			wp_slot + 1, ReturnFactionWeaponName(factionWeapons[id][wp_slot][0]), factionWeapons[id][wp_slot][1]);

		new tmp[2][8];
		strexplode(tmp, inputtext, " ");

		new gunid = strval(tmp[0]), ammo = strval(tmp[1]);

		if(gunid < 0 || (gunid > 46 && gunid != 100 && gunid != 200) || gunid == 19 || gunid == 20 || gunid == 21)
			return Dialog_Show(playerid, FactionEdit_SetWeapon, DIALOG_STYLE_INPUT, "��� -> ������ظ", ""EMBED_LIGHTRED"����ͼԴ��Ҵ"EMBED_WHITE": �ʹ����ظ���١��ͧ\n\n��ͧ��� %d: "EMBED_YELLOW"%s"EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n������ҧ \""EMBED_YELLOW"�ʹ����ظ "EMBED_ORANGE"�ӹǹ"EMBED_WHITE"\": \n����� \""EMBED_YELLOW"31 "EMBED_ORANGE"300"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"M4 "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"300"EMBED_WHITE")\n����� \""EMBED_YELLOW"100 "EMBED_ORANGE"200"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"���ʹ "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"200"EMBED_WHITE")\n\n�������: \n�ʹ� "EMBED_YELLOW"100"EMBED_WHITE" = ���ʹ \n�ʹ� "EMBED_YELLOW"200"EMBED_WHITE" = ����\n\n��سһ�͹�ʹ����ظ��ҹ��ҧ���", "��駤��", "��Ѻ", 
			wp_slot + 1, ReturnFactionWeaponName(factionWeapons[id][wp_slot][0]), factionWeapons[id][wp_slot][1]);

		if(ammo <= 0 && gunid > 0)
			return Dialog_Show(playerid, FactionEdit_SetWeapon, DIALOG_STYLE_INPUT, "��� -> ������ظ", ""EMBED_LIGHTRED"����ͼԴ��Ҵ"EMBED_WHITE": �ӹǹ���١��ͧ\n\n��ͧ��� %d: "EMBED_YELLOW"%s"EMBED_WHITE"("EMBED_ORANGE"%d"EMBED_WHITE")\n\n������ҧ \""EMBED_YELLOW"�ʹ����ظ "EMBED_ORANGE"�ӹǹ"EMBED_WHITE"\": \n����� \""EMBED_YELLOW"31 "EMBED_ORANGE"300"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"M4 "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"300"EMBED_WHITE")\n����� \""EMBED_YELLOW"100 "EMBED_ORANGE"200"EMBED_WHITE"\" (���¶֧ "EMBED_YELLOW"���ʹ "EMBED_WHITE"�ӹǹ "EMBED_ORANGE"200"EMBED_WHITE")\n\n�������: \n�ʹ� "EMBED_YELLOW"100"EMBED_WHITE" = ���ʹ \n�ʹ� "EMBED_YELLOW"200"EMBED_WHITE" = ����\n\n��سһ�͹�ʹ����ظ��ҹ��ҧ���", "��駤��", "��Ѻ", 
			wp_slot + 1, ReturnFactionWeaponName(factionWeapons[id][wp_slot][0]), factionWeapons[id][wp_slot][1]);

		Log(a_action_log, INFO, "%s: ����¹���ظ�ͧ %s(%d) ��ͧ��� %d �ҡ %s(%d) �ӹǹ %d �� %s(%d) �ӹǹ %d", 
		ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], wp_slot + 1, ReturnFactionWeaponName(factionWeapons[id][wp_slot][0]), factionWeapons[id][wp_slot][0], factionWeapons[id][wp_slot][1], ReturnFactionWeaponName(gunid), gunid, ammo);

		SendFormatMessage(playerid, COLOR_GRAD, " ���ظ�ͧ "EMBED_WHITE"%s"EMBED_GRAD" ��ͧ��� %d �ҡ "EMBED_WHITE"%s(%d)"EMBED_GRAD" �� "EMBED_WHITE"%s(%d)"EMBED_GRAD"", factionData[id][fName], wp_slot + 1, ReturnFactionWeaponName(factionWeapons[id][wp_slot][0]), factionWeapons[id][wp_slot][1], ReturnFactionWeaponName(gunid), ammo);

		factionWeapons[id][wp_slot][0] = gunid;
		factionWeapons[id][wp_slot][1] = ammo;
		Faction_SaveWeapon(id, wp_slot);
	}
	return ShowPlayerEditFaction_Weapon(playerid);
}

Dialog:FactionEdit_Spawn(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new id = GetPVarInt(playerid, "FactionEditID");
		new Float:px, Float:py, Float:pz, Float:pa, pint = GetPlayerInterior(playerid), pworld = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(playerid, px, py, pz);
		GetPlayerFacingAngle(playerid, pa);

		SendFormatMessage(playerid, COLOR_GRAD, " �ش�Դ�ͧ "EMBED_WHITE"%s"EMBED_GRAD" �١����¹���ѧ�������Ѩ�غѹ�ͧ�س����", factionData[id][fName]);
		Log(a_action_log, INFO, "%s: ����¹�ش�Դ�ͧ %s(%d) �ҡ %f,%f,%f (int:%d|world:%d) �� %f,%f,%f (int:%d|world:%d)", ReturnPlayerName(playerid), factionData[id][fName], factionData[id][fID], factionData[id][fSpawnX], factionData[id][fSpawnY], factionData[id][fSpawnZ], factionData[id][fSpawnInt], factionData[id][fSpawnWorld], px, py, pz, pint, pworld);

        factionData[id][fSpawnX]=px;
        factionData[id][fSpawnY]=py;
        factionData[id][fSpawnZ]=pz;
		factionData[id][fSpawnA]=pa;
        factionData[id][fSpawnInt]=pint;
        factionData[id][fSpawnWorld]=pworld;

		Faction_SpawnUpdate(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
	   	Faction_Save(id);
	}
	return ShowPlayerEditFaction(playerid);
}

hook OP_KeyStateChange(playerid, newkeys, oldkeys)
{
	if(Pressed(KEY_NO)) {
		new faction_id = playerData[playerid][pFactionID];
		if(faction_id != -1) {
			if(IsPlayerInRangeOfPoint(playerid, 5.0, factionData[faction_id][fSpawnX], factionData[faction_id][fSpawnY], factionData[faction_id][fSpawnZ]) && GetPlayerVirtualWorld(playerid) == factionData[faction_id][fSpawnWorld] && GetPlayerInterior(playerid) == factionData[faction_id][fSpawnInt]) {
				
				if(FillupDelay[playerid] != 0 && gettime() - FillupDelay[playerid] < 30) {
					SendFormatMessage(playerid, COLOR_LIGHTRED, "�Դ��ͼԴ��Ҵ"EMBED_WHITE": �س�������ö��Ժ���ظ��㹢�й�� �ͧ�����ա������ա "EMBED_ORANGE"%d"EMBED_WHITE" �Թҷ�", 30 - (gettime() - FillupDelay[playerid]));
					return 1;
				}

				if(factionData[faction_id][fType] == FACTION_POLICE) {
					SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "* ���˹�ҷ�� %s ����Ժ���ظ�͡�ҡ��ѧ", ReturnPlayerName(playerid));
				}
				else {
					SendNearbyMessage(playerid, 20.0, COLOR_PURPLE, "* %s ����Ժ���ظ�͡�ҡ��ѧ", ReturnPlayerName(playerid));
				}
				ApplyAnimation(playerid,"COLT45","colt45_reload",4.0,0,0,0,0,0);

				ResetPlayerWeapons(playerid);

				for (new j = 0; j != 10; j ++) {
				    if(factionWeapons[faction_id][j][0] == 100) { // ���ʹ
				        SetPlayerHealthEx(playerid, factionWeapons[faction_id][j][1]);
				    }
				    else if(factionWeapons[faction_id][j][0] == 200) { // ����
				        SetPlayerArmour(playerid, factionWeapons[faction_id][j][1]);
				    }
				    else {
				        if(factionWeapons[faction_id][j][0] > 0) {
				           GivePlayerWeapon(playerid, factionWeapons[faction_id][j][0], factionWeapons[faction_id][j][1]);
				        }
				    }
				}

				FillupDelay[playerid] = gettime();
			}
		}
	}
	return 1;
}

hook OnPlayerConnect(playerid) {
	FillupDelay[playerid]=0;
	return 1;
}

flags:makeleader(CMD_LEAD)
CMD:makeleader(playerid, params[]) {

	new
		userid,
		id;		

	if (sscanf(params, "ud", userid, id)) {
        SendClientMessage(playerid, COLOR_GREEN,    "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1,    "�����: /makeleader [�ʹ�/���ͺҧ��ǹ] [�ʹ�ῤ���(/viewfactions)]");
		return 1;
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹�鹵Ѵ�����������");

	if (id < 0 || id > MAX_FACTIONS)
	    return SendClientMessage(playerid, COLOR_GRAD1, "   �س�к��ʹս������͡�����Դ��Ҵ");

	if (id == 0)
	{
		if(playerData[userid][pFactionID] != -1) {
			SendFormatMessage(playerid, COLOR_LIGHTBLUE, " �س��Ŵ %s �ҡῤ��� %s", ReturnPlayerName(userid), Faction_GetName(userid));
			SendFormatMessage(userid, COLOR_LIGHTBLUE, " %s ��Ŵ�س�͡�ҡῤ��� %s", ReturnPlayerName(playerid), Faction_GetName(userid));
			SendAdminMessage(COLOR_YELLOW, "AdmWarning: %s ��Ŵ %s �͡�ҡ����繼��� %s"EMBED_YELLOW" (%d)", ReturnPlayerName(playerid), ReturnPlayerName(userid), Faction_GetName(userid), playerData[userid][pFactionID] + 1);

			playerData[userid][pFaction] = 0;
			playerData[userid][pFactionID] = -1;
			playerData[userid][pFactionRank] = 0;
		}
		else return SendClientMessage(playerid, COLOR_GRAD1, " �����蹹������������ῤ���� �");
	}
	else
	{
		id--;
		if(Iter_Contains(Iter_Faction, id)) {
			playerData[userid][pFaction] = factionData[id][fID];
			playerData[userid][pFactionID] = id;
			playerData[userid][pFactionRank] = 1;

			SendFormatMessage(userid, COLOR_LIGHTBLUE, " �س���Ѻ����觵������繼��� %s"EMBED_LIGHTBLUE" ���ʹ�Թ %s", Faction_GetName(userid), ReturnPlayerName(playerid));
			SendFormatMessage(playerid, COLOR_LIGHTBLUE, " �س���觵����� %s �繼��� %s", ReturnPlayerName(userid), Faction_GetName(userid));
			SendAdminMessage(COLOR_YELLOW, "AdmWarning: %s ���觵����� %s �繼��� %s"EMBED_YELLOW" (%d)", ReturnPlayerName(playerid), ReturnPlayerName(userid), Faction_GetName(userid), id + 1);
		}
		else {
			SendFormatMessage(playerid, COLOR_LIGHTRED, "�Դ��ͼԴ��Ҵ"EMBED_WHITE": ��辺ῤ����ʹ� "EMBED_ORANGE"%d"EMBED_WHITE" ������к� (/viewfactions)", id + 1);
		}
	}
	return 1;
}

CMD:invite(playerid, params[]) {

	new userid = INVALID_PLAYER_ID, id = playerData[playerid][pFactionID];

	if(id == -1 || !Iter_Contains(Iter_Faction, id)) {
        SendClientMessage(playerid, COLOR_GRAD1,  "   �س�������ǹ˹�觢ͧῤ���!");
		return 1;
	}

	if (sscanf(params, "u", userid)) {
        SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /invite [�ʹ�/���ͺҧ��ǹ]");
		return 1;
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹�鹵Ѵ�����������");

	if (playerData[playerid][pFactionRank] == 1)
	{
		if (playerData[userid][pFactionID] == -1)
		{
			SendFormatMessage(userid, COLOR_LIGHTBLUE, "%s ���Ѻ�س���ῤ��� %s", ReturnPlayerName(playerid), Faction_GetName(playerid));
			SendFormatMessage(playerid, COLOR_LIGHTBLUE, "�س���Ѻ %s ���ῤ��� %s", ReturnPlayerName(userid), Faction_GetName(playerid));

			playerData[userid][pFaction] = playerData[playerid][pFaction];
			playerData[userid][pFactionID] = playerData[playerid][pFactionID];
			playerData[userid][pFactionRank] = factionData[id][fMaxRanks];
		}
		else
		{
		    SendClientMessage(playerid, COLOR_GREY, "  �����蹹����ῤ�����������");
		    return 1;
		}
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAD1, "   ����Ѻ����ῤ�����ҹ��!");
	}
	return 1;
}

CMD:uninvite(playerid, params[]) {

	new userid = INVALID_PLAYER_ID, id = playerData[playerid][pFactionID];

	if(id == -1 || !Iter_Contains(Iter_Faction, id)) {
        SendClientMessage(playerid, COLOR_GRAD1,  "   �س�������ǹ˹�觢ͧῤ���!");
		return 1;
	}

	if (sscanf(params, "u", userid)) {
        SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /uninvite [�ʹ�/���ͺҧ��ǹ]");
		return 1;
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹�鹵Ѵ�����������");

	if (playerData[playerid][pFactionRank] == 1)
	{
		if (playerData[userid][pFactionID] == playerData[playerid][pFaction])
		{
			SendFormatMessage(userid, COLOR_LIGHTBLUE, "%s ���Фس�͡�ҡῤ��� %s", ReturnPlayerName(playerid), Faction_GetName(playerid));
			SendFormatMessage(playerid, COLOR_LIGHTBLUE, "�س���� %s �͡�ҡῤ��� %s", ReturnPlayerName(userid), Faction_GetName(playerid));

			playerData[userid][pFaction]=0;
			playerData[userid][pFactionID]=-1;
			playerData[userid][pFactionRank]=0;
		}
		else
		{
		    SendClientMessage(playerid, COLOR_GREY, "  �����蹹�����������ῤ������ǡѺ��س");
		    return 1;
		}
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAD1, "   ����Ѻ����ῤ�����ҹ��!");
	}
	return 1;
}

alias:government("gov")
CMD:government(playerid, params[]) {

	new id = playerData[playerid][pFactionID];

	if(id == -1 || !Iter_Contains(Iter_Faction, id)) {
        SendClientMessage(playerid, COLOR_GRAD1,  "   �س�������ǹ˹�觢ͧῤ���!");
		return 1;
	}

	new
	    result[128];

	if (sscanf(params, "s[128]", result)) {
        SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /government [��ͤ���]");
		return 1;
	}

	if (playerData[playerid][pFactionRank] == 1)
	{
		if(Iter_Contains(Iter_Faction, id)) {
			SendFormatMessageToAll(COLOR_WHITE, "{%06x}|================== (( %s{%06x} )) ==================|", factionData[id][fColor], factionData[id][fName], factionData[id][fColor]);
			SendFormatMessageToAll(COLOR_WHITE, "��С�Ȩҡ %s %s(%d): %s", Faction_GetRank(playerid), ReturnPlayerName(playerid), playerid, result);
			SendFormatMessageToAll(COLOR_WHITE, "{%06x}|================== (( %s{%06x} )) ==================|", factionData[id][fColor], factionData[id][fName], factionData[id][fColor]);
		}
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAD1, "   ����Ѻ����ῤ�����ҹ��!");
	}
	return 1;
}
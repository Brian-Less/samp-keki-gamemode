#include <YSI\y_hooks>
/* 
    Standalone

    �Ӻ�÷Ѵ��ҹ��ҧ��á���� initgamemode.pwn ���� "// ��Ŵ�����Ũҡ Database"
    mysql_tquery(dbCon, "SELECT * FROM `entrance`", "Entrance_Load", "");

    // ���ͧ�ҡ��� hook OnGameModeInit �ж١���¡��͹�ѧ���� g_mysql_Init (�������Ͱҹ������) ������������ö��Ŵ��������������ѹ����

    To-do List:
        - ��ǧ�к� Dynamic Faction System (��˹��ҧ����������Ңͧ��ῤ���)
        - ���ҧ�͡��ѧ World �ͧ�ҧ�������� (����͹�ջ�е���ѧ��ҹ �����Һ�ҹ��ѧ���ǡѹ)
*/

#define MAX_ENTRANCE    100
#define DEFAULT_ENTRANCE_PICKUP 1318 // �ʹ��ͤ͹�������
#define ENTRANCE_WORLD  2000

new Iterator:Iter_Entrance<MAX_ENTRANCE>;

enum E_ENTRANCE_DATA
{
	eID,
	eName[60],
    Float:extX,
    Float:extY,
    Float:extZ,
    Float:extA,
    extInt,
    extWorld,
    eExtName[60],

    Float:intX,
    Float:intY,
    Float:intZ,
    Float:intA,
    eIntName[60],
    eInt,
    eWorld,
    eIntPickupModel,
    eExtPickupModel,

    eIntPickup,
    eExtPickup,
    STREAMER_TAG_3D_TEXT_LABEL:eExtLabel,
    STREAMER_TAG_3D_TEXT_LABEL:eIntLabel
};

new entranceData[MAX_ENTRANCE][E_ENTRANCE_DATA];

forward Entrance_Load();
public Entrance_Load() {

    new
	    rows;

	cache_get_row_count(rows);

	for (new i = 0; i < rows; i ++) if (i < MAX_ENTRANCE)
	{
        cache_get_value_name_int(i, "id", entranceData[i][eID]);
        cache_get_value_name(i, "name", entranceData[i][eName], 60);
        cache_get_value_name_float(i, "extX", entranceData[i][extX]);
        cache_get_value_name_float(i, "extY", entranceData[i][extY]);
        cache_get_value_name_float(i, "extZ", entranceData[i][extZ]);
        cache_get_value_name_float(i, "extA", entranceData[i][extA]);
        cache_get_value_name(i, "extName", entranceData[i][eExtName], 60);
        cache_get_value_name_int(i, "extInterior", entranceData[i][extInt]);
        cache_get_value_name_int(i, "extWorld", entranceData[i][extWorld]);
        cache_get_value_name_float(i, "intX", entranceData[i][intX]);
        cache_get_value_name_float(i, "intY", entranceData[i][intY]);
        cache_get_value_name_float(i, "intZ", entranceData[i][intZ]);
        cache_get_value_name_float(i, "intA", entranceData[i][intA]);
        cache_get_value_name(i, "intName", entranceData[i][eIntName], 60);
        cache_get_value_name_int(i, "Interior", entranceData[i][eInt]);
        cache_get_value_name_int(i, "World", entranceData[i][eWorld]);
        cache_get_value_name_int(i, "intPickup", entranceData[i][eIntPickupModel]);
        cache_get_value_name_int(i, "extPickup", entranceData[i][eExtPickupModel]);

        Entrance_Update(i);

        Iter_Add(Iter_Entrance, i);
	}

    printf("Entrance loaded (%d/%d)", Iter_Count(Iter_Entrance), MAX_ENTRANCE);
	return 1;
}

Entrance_Save(id=-1) {
    if(Iter_Contains(Iter_Entrance, id)) {
        new query[MAX_STRING];
        MySQLUpdateInit("entrance", "id", entranceData[id][eID], MYSQL_UPDATE_TYPE_THREAD); 
        MySQLUpdateStr(query, "name", entranceData[id][eName]);
        MySQLUpdateFlo(query, "extX", entranceData[id][extX]);
        MySQLUpdateFlo(query, "extY", entranceData[id][extY]);
        MySQLUpdateFlo(query, "extZ", entranceData[id][extZ]);
        MySQLUpdateFlo(query, "extA", entranceData[id][extA]);
        MySQLUpdateStr(query, "extName", entranceData[id][eExtName]);
        MySQLUpdateInt(query, "extInterior", entranceData[id][extInt]);
        MySQLUpdateInt(query, "extWorld", entranceData[id][extWorld]);
        MySQLUpdateFlo(query, "intX", entranceData[id][intX]);
        MySQLUpdateFlo(query, "intY", entranceData[id][intY]);
        MySQLUpdateFlo(query, "intZ", entranceData[id][intZ]);
        MySQLUpdateFlo(query, "intA", entranceData[id][intA]);
        MySQLUpdateStr(query, "intName", entranceData[id][eIntName]);
        MySQLUpdateInt(query, "Interior", entranceData[id][eInt]);
        MySQLUpdateInt(query, "World", entranceData[id][eWorld]);
        MySQLUpdateInt(query, "intPickup", entranceData[id][eIntPickupModel]);
        MySQLUpdateInt(query, "extPickup", entranceData[id][eExtPickupModel]);
		MySQLUpdateFinish(query);
    }
    return 1;
}

Entrance_Update(id) {
	new string[128];

	if(IsValidDynamic3DTextLabel(entranceData[id][eExtLabel])) 
		DestroyDynamic3DTextLabel(entranceData[id][eExtLabel]);
	if(IsValidDynamic3DTextLabel(entranceData[id][eIntLabel])) 
		DestroyDynamic3DTextLabel(entranceData[id][eIntLabel]);
	if(IsValidDynamicPickup(entranceData[id][eExtPickup])) 
		DestroyDynamicPickup(entranceData[id][eExtPickup]);
	if(IsValidDynamicPickup(entranceData[id][eIntPickup])) 
		DestroyDynamicPickup(entranceData[id][eIntPickup]);
        
    // ��¹͡
    if(entranceData[id][eExtPickupModel])
        entranceData[id][eExtPickup] = CreateDynamicPickup(entranceData[id][eExtPickupModel], 23, entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ], entranceData[id][extWorld], entranceData[id][extInt]);

	format(string, sizeof(string), "%s\n"EMBED_WHITE"������ \""EMBED_YELLOW"ENTER"EMBED_WHITE"\" �������", entranceData[id][eExtName]);
	entranceData[id][eExtLabel] = CreateDynamic3DTextLabel(string, -1, entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, entranceData[id][extWorld], entranceData[id][extInt]);
    // ����
    if(entranceData[id][eIntPickupModel])
        entranceData[id][eIntPickup] = CreateDynamicPickup(entranceData[id][eIntPickupModel], 23, entranceData[id][intX], entranceData[id][intY], entranceData[id][intZ], entranceData[id][eWorld], entranceData[id][eInt]);

	format(string, sizeof(string), "%s\n"EMBED_WHITE"������ \""EMBED_YELLOW"ENTER"EMBED_WHITE"\" �����͡", entranceData[id][eIntName]);
	entranceData[id][eIntLabel] = CreateDynamic3DTextLabel(string, -1, entranceData[id][intX], entranceData[id][intY], entranceData[id][intZ], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, entranceData[id][eWorld], entranceData[id][eInt]);

	return 1;
}

forward OnEntranceCreated(id);
public OnEntranceCreated(id)
{
	if (id == -1)
	    return 0;

	entranceData[id][eID] = cache_insert_id();
    Entrance_Update(id);
	Entrance_Save(id);
	return 1;
}

forward OnEntranceRemove(playerid, id);
public OnEntranceRemove(playerid, id)
{
	new string[144];
	
	if(IsValidDynamic3DTextLabel(entranceData[id][eExtLabel]))
		DestroyDynamic3DTextLabel(entranceData[id][eExtLabel]);
	if(IsValidDynamic3DTextLabel(entranceData[id][eIntLabel]))
		DestroyDynamic3DTextLabel(entranceData[id][eIntLabel]);
	if(IsValidDynamicPickup(entranceData[id][eExtPickup]))
		DestroyDynamicPickup(entranceData[id][eExtPickup]);
	if(IsValidDynamicPickup(entranceData[id][eIntPickup]))
		DestroyDynamicPickup(entranceData[id][eIntPickup]);

	format(string, sizeof(string),"���������: "EMBED_WHITE"�س�����·ҧ����ʹ� "EMBED_ORANGE"%d", id + 1);
	SendClientMessage(playerid, COLOR_GREY, string);

	Iter_Remove(Iter_Entrance, id);
	return 1;
}

flags:entrancecmds(CMD_MM)
CMD:entrancecmds(playerid) {
    SendClientMessage(playerid, COLOR_GRAD1, "�����: /makeentrance, /viewentrances, /removeentrance");
    return 1;
}

flags:makeentrance(CMD_MM)
CMD:makeentrance(playerid, params[])
{
	new
        id,
		name[60],
        query[256];

	if (sscanf(params, "s[60]", name))
	{
        SendClientMessage(playerid, COLOR_GREEN,    "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1,    "�����: /makeentrance [����]");
		return 1;
	}

    if((id = Iter_Free(Iter_Entrance)) != -1) {

	    format(entranceData[id][eName], 60, name);
        GetPlayerPos(playerid, entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ]);
        GetPlayerFacingAngle(playerid, entranceData[id][extA]);
        entranceData[id][extInt] = GetPlayerInterior(playerid);
        entranceData[id][extWorld] = GetPlayerVirtualWorld(playerid);
        entranceData[id][eExtPickupModel] = DEFAULT_ENTRANCE_PICKUP;

        mysql_format(dbCon, query, sizeof query, "INSERT INTO `entrance` (`name`) VALUES('%e')", name);
	    mysql_tquery(dbCon, query, "OnEntranceCreated", "d", id);

        SendFormatMessage(playerid, COLOR_GREY, "���������: "EMBED_WHITE"�س�����ҧ�ҧ����ʹ� "EMBED_ORANGE"%d", id + 1);

        Iter_Add(Iter_Entrance, id);
    }
    else {
        SendFormatMessage(playerid, COLOR_RED,   "�Դ��Ҵ: "EMBED_WHITE"�������ö���ҧ�ҧ������ҡ���ҹ������ �ӡѴ����� "EMBED_ORANGE"%d", MAX_ENTRANCE);
    }
	return 1;
}

flags:viewentrances(CMD_MM)
CMD:viewentrances(playerid) {
    ViewEntrances(playerid);
    return 1;
}

flags:removeentrance(CMD_MM)
CMD:removeentrance(playerid, params[]) {
	new string[128], objectid;
	if(sscanf(params,"d",objectid)) {
        SendClientMessage(playerid, COLOR_GREEN,    "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1,    "�����: /removeentrance [�ʹ� (/viewentrances)]");
		return 1;
	}
    objectid--;
    
	if(Iter_Contains(Iter_Entrance, objectid))
	{
		format(string, sizeof(string), "DELETE FROM `entrance` WHERE `id` = %d", entranceData[objectid][eID]);
		mysql_tquery(dbCon, string, "OnEntranceRemove", "ii", playerid, objectid);
	}
	else
	{
		SendClientMessage(playerid, COLOR_RED,"�Դ��Ҵ: "EMBED_WHITE"��辺�ҧ����ʹշ���к�");
	}
	return 1;
}


ViewEntrances(playerid)
{
	new string[2048], menu[20], count;

	format(string, sizeof(string), "%s{B4B5B7}˹�� 1\n", string);

	SetPVarInt(playerid, "page", 1);

	foreach(new i : Iter_Entrance) {
		if(count == 20)
		{
			format(string, sizeof(string), "%s{B4B5B7}˹�� 2\n", string);
			break;
		}
		format(menu, 20, "menu%d", ++count);
		SetPVarInt(playerid, menu, i);
		format(string, sizeof(string), "%s({FFBF00}%i"EMBED_WHITE") | "EMBED_LIGHTGREEN"%s\n", string, i + 1, entranceData[i][eName]);
	}
	if(!count) Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_MSGBOX, "��ª��ͷҧ���", "��辺�����Ţͧ�ҧ���..", "�Դ", "");
	else Dialog_Show(playerid, EntrancesList, DIALOG_STYLE_LIST, "��ª��ͷҧ���", string, "���", "��Ѻ");
	return 1;
}

Dialog:EntrancesList(playerid, response, listitem, inputtext[])
{
	if(response) {

		new menu[20];
		//Navigate
		if(listitem != 0 && listitem != 21) {
			new str_biz[20];
			format(str_biz, 20, "menu%d", listitem);

			SetPVarInt(playerid, "EntranceEditID", GetPVarInt(playerid, str_biz));
			ShowPlayerEditEntrance(playerid);
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

		foreach(new i : Iter_Entrance) {

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
			format(string, sizeof(string), "%s({FFBF00}%i"EMBED_WHITE") | "EMBED_LIGHTGREEN"%s\n", string, i + 1, entranceData[i][eName]);

		}

		Dialog_Show(playerid, EntrancesList, DIALOG_STYLE_LIST, "��ª��ͷҧ���", string, "���", "��Ѻ");
	}
	return 1;
}


ShowPlayerEditEntrance(playerid)
{
    new id = GetPVarInt(playerid, "EntranceEditID");
	if(Iter_Contains(Iter_Entrance, id))
	{
		new caption[128], dialog_str[1024];
		format(caption, sizeof(caption), "���ῤ���: "EMBED_LIGHTGREEN"%s"EMBED_WHITE"(SQLID:%d)", entranceData[id][eName], entranceData[id][eID]);
        format(dialog_str, sizeof dialog_str, "���ͷҧ���\t%s\n", entranceData[id][eName]);
        format(dialog_str, sizeof dialog_str, "%s��ͤ��������\t%s\n", dialog_str, entranceData[id][eExtName]);
        format(dialog_str, sizeof dialog_str, "%s��ͤ������͡\t%s\n", dialog_str, entranceData[id][eIntName]);
        format(dialog_str, sizeof dialog_str, "%s�ͤ͹�����\t%d\n", dialog_str, entranceData[id][eExtPickupModel]);
        format(dialog_str, sizeof dialog_str, "%s�ͤ͹���͡\t%d\n", dialog_str, entranceData[id][eIntPickupModel]);
        format(dialog_str, sizeof dialog_str, "%s��駤�ҷҧ������ѧ���˹觢ͧ�س\t\n", dialog_str);
        format(dialog_str, sizeof dialog_str, "%s��駤�ҷҧ�͡���ѧ���˹觢ͧ�س\t", dialog_str);
		Dialog_Show(playerid, EntranceEdit, DIALOG_STYLE_TABLIST, caption, dialog_str, "���", "��Ѻ");
	}
	return 1;
}

Dialog:EntranceEdit(playerid, response, listitem, inputtext[])
{
	if(response) {

		new caption[128];    
        new id = GetPVarInt(playerid, "EntranceEditID");
		switch(listitem)
		{
			case 0: // ��䢪���
			{
				format(caption, sizeof(caption), "��� -> ����: "EMBED_LIGHTGREEN"%s", entranceData[id][eName]);
				Dialog_Show(playerid, EntranceEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_ORANGE"0 "EMBED_WHITE"�������Թ "EMBED_ORANGE"60 "EMBED_WHITE"����ѡ��\n\n��͡����ῤ��蹷���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 1:
			{
				format(caption, sizeof(caption), "��� -> ��ͤ��������: "EMBED_LIGHTGREEN"%s", entranceData[id][eExtName]);
				Dialog_Show(playerid, EntranceEdit_EnterName, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_ORANGE"0 "EMBED_WHITE"�������Թ "EMBED_ORANGE"60 "EMBED_WHITE"����ѡ��\n\n��͡����ῤ��蹷���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 2:
			{
				format(caption, sizeof(caption), "��� -> ��ͤ������͡: "EMBED_LIGHTGREEN"%s", entranceData[id][eIntName]);
				Dialog_Show(playerid, EntranceEdit_ExitName, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_ORANGE"0 "EMBED_WHITE"�������Թ "EMBED_ORANGE"60 "EMBED_WHITE"����ѡ��\n\n��͡����ῤ��蹷���ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 3:
			{
				format(caption, sizeof(caption), "��� -> �ͤ͹�����: "EMBED_LIGHTGREEN"%d", entranceData[id][eExtPickupModel]);
				Dialog_Show(playerid, EntranceEdit_ExtIcon, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"�� "EMBED_ORANGE"0"EMBED_WHITE" ���ͫ�͹�ͤ͹\n\n��͡�ʹ��ͤ͹����ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 4:
			{
				format(caption, sizeof(caption), "��� -> �ͤ͹���͡: "EMBED_LIGHTGREEN"%d", entranceData[id][eIntPickupModel]);
				Dialog_Show(playerid, EntranceEdit_IntIcon, DIALOG_STYLE_INPUT, caption, ""EMBED_WHITE"�� "EMBED_ORANGE"0"EMBED_WHITE" ���ͫ�͹�ͤ͹\n\n��͡�ʹ��ͤ͹����ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
			}
			case 5:
			{
				format(caption, sizeof(caption), "��� -> ��䢷ҧ���");
				Dialog_Show(playerid, EntranceEdit_Enter, DIALOG_STYLE_MSGBOX, caption, ""EMBED_WHITE"�س������ͷ��л�Ѻ"EMBED_YELLOW"�ҧ���"EMBED_WHITE"������ѧ���˹觻Ѩ�غѹ�ͧ�س", "�׹�ѹ", "��Ѻ");
			}
			case 6:
			{
				format(caption, sizeof(caption), "��� -> ��䢷ҧ�͡");
				Dialog_Show(playerid, EntranceEdit_Exit, DIALOG_STYLE_MSGBOX, caption, ""EMBED_WHITE"�س������ͷ��л�Ѻ"EMBED_YELLOW"�ҧ�͡"EMBED_WHITE"���ѧ���˹觻Ѩ�غѹ�ͧ�س", "�׹�ѹ", "��Ѻ");
			}
		}
	}
	else
	{
	    DeletePVar(playerid, "EntranceEditID");
        ViewEntrances(playerid);
	}
    return 1;
}

Dialog:EntranceEdit_Name(playerid, response, listitem, inputtext[])
{
	if(response) {
		new caption[128];
		new id = GetPVarInt(playerid, "EntranceEditID");

		if(isnull(inputtext) || strlen(inputtext) >= 60) {
			format(caption, sizeof(caption), "��� -> ����: "EMBED_LIGHTGREEN"%s", entranceData[id][eName]);
			Dialog_Show(playerid, EntranceEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"����ͼԴ��Ҵ:\n"EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_YELLOW"0 "EMBED_WHITE"�������Թ "EMBED_YELLOW"60 "EMBED_WHITE"����ѡ��", "����¹", "��Ѻ");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_GRAD, " �ҧ��Ҫ��� "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", entranceData[id][eName], inputtext);
		Log(a_action_log, INFO, "%s: ����¹���ͷҧ��� %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), entranceData[id][eName], entranceData[id][eID], entranceData[id][eName], inputtext);

		format(entranceData[id][eName], 60, inputtext);
		Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}

Dialog:EntranceEdit_EnterName(playerid, response, listitem, inputtext[])
{
	if(response) {
		new caption[128];
		new id = GetPVarInt(playerid, "EntranceEditID");

		if(isnull(inputtext) || strlen(inputtext) >= 60) {
			format(caption, sizeof(caption), "��� -> ��ͤ��������: "EMBED_LIGHTGREEN"%s", entranceData[id][eExtName]);
			Dialog_Show(playerid, EntranceEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"����ͼԴ��Ҵ:\n"EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_YELLOW"0 "EMBED_WHITE"�������Թ "EMBED_YELLOW"60 "EMBED_WHITE"����ѡ��", "����¹", "��Ѻ");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ��ͤ�������Ҩҡ "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", entranceData[id][eExtName], inputtext);
		Log(a_action_log, INFO, "%s: ��ͤ�������� %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), entranceData[id][eExtName], entranceData[id][eID], entranceData[id][eExtName], inputtext);

		format(entranceData[id][eExtName], 60, inputtext);

		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

		Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}

Dialog:EntranceEdit_ExitName(playerid, response, listitem, inputtext[])
{
	if(response) {
		new caption[128];
		new id = GetPVarInt(playerid, "EntranceEditID");

		if(isnull(inputtext) || strlen(inputtext) >= 60) {
			format(caption, sizeof(caption), "��� -> ��ͤ��������: "EMBED_LIGHTGREEN"%s", entranceData[id][eIntName]);
			Dialog_Show(playerid, EntranceEdit_Name, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"����ͼԴ��Ҵ:\n"EMBED_WHITE"������Ǣͧ���͵�ͧ�ҡ���� "EMBED_YELLOW"0 "EMBED_WHITE"�������Թ "EMBED_YELLOW"60 "EMBED_WHITE"����ѡ��", "����¹", "��Ѻ");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_GRAD, " ��ͤ�������Ҩҡ "EMBED_WHITE"%s"EMBED_GRAD" �� "EMBED_WHITE"%s"EMBED_GRAD"", entranceData[id][eIntName], inputtext);
		Log(a_action_log, INFO, "%s: ��ͤ�������� %s(%d) �ҡ %s �� %s", ReturnPlayerName(playerid), entranceData[id][eIntName], entranceData[id][eID], entranceData[id][eIntName], inputtext);

		format(entranceData[id][eIntName], 60, inputtext);

		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);

		Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}

Dialog:EntranceEdit_ExtIcon(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "EntranceEditID");
	if(response) {
		new typeint = strval(inputtext);
		if(typeint < 0) {
            new caption[128];
            format(caption, sizeof(caption), "��� -> �ͤ͹�����: "EMBED_LIGHTGREEN"%d", entranceData[id][eExtPickupModel]);
			return Dialog_Show(playerid, EntranceEdit_ExtIcon, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"��ͼԴ��Ҵ: "EMBED_WHITE"�ʹյ�ͧ����ӡ��� "EMBED_ORANGE"0\n\n"EMBED_WHITE"�� "EMBED_ORANGE"0"EMBED_WHITE" ���ͫ�͹�ͤ͹\n\n��͡�ʹ��ͤ͹����ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
		}
		SendFormatMessage(playerid, COLOR_GRAD, " �ͤ͹����� "EMBED_WHITE"%s"EMBED_GRAD" �ҡ "EMBED_WHITE"%d"EMBED_GRAD" �� "EMBED_WHITE"%d"EMBED_GRAD"", entranceData[id][eName], entranceData[id][eExtPickupModel], typeint);
		Log(a_action_log, INFO, "%s: ����¹�ͤ͹����Ңͧ %s(%d) �ҡ %d �� %d", ReturnPlayerName(playerid), entranceData[id][eName], entranceData[id][eID], entranceData[id][eExtPickupModel], typeint);

	    entranceData[id][eExtPickupModel] = typeint;
		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
	    Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}


Dialog:EntranceEdit_IntIcon(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "EntranceEditID");
	if(response) {
		new typeint = strval(inputtext);
		if(typeint < 0) {
            new caption[128];
            format(caption, sizeof(caption), "��� -> �ͤ͹���͡: "EMBED_LIGHTGREEN"%d", entranceData[id][eIntPickupModel]);
			return Dialog_Show(playerid, EntranceEdit_ExtIcon, DIALOG_STYLE_INPUT, caption, ""EMBED_LIGHTRED"��ͼԴ��Ҵ: "EMBED_WHITE"�ʹյ�ͧ����ӡ��� "EMBED_ORANGE"0\n\n"EMBED_WHITE"�� "EMBED_ORANGE"0"EMBED_WHITE" ���ͫ�͹�ͤ͹\n\n��͡�ʹ��ͤ͹����ͧ���㹪�ͧ��ҧ��ҹ��ҧ���:", "����¹", "��Ѻ");
		}
		SendFormatMessage(playerid, COLOR_GRAD, " �ͤ͹���͡ "EMBED_WHITE"%s"EMBED_GRAD" �ҡ "EMBED_WHITE"%d"EMBED_GRAD" �� "EMBED_WHITE"%d"EMBED_GRAD"", entranceData[id][eName], entranceData[id][eIntPickupModel], typeint);
		Log(a_action_log, INFO, "%s: ����¹�ͤ͹���͡�ͧ %s(%d) �ҡ %d �� %d", ReturnPlayerName(playerid), entranceData[id][eName], entranceData[id][eID], entranceData[id][eIntPickupModel], typeint);

	    entranceData[id][eIntPickupModel] = typeint;
		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
	    Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}

Dialog:EntranceEdit_Enter(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new id = GetPVarInt(playerid, "EntranceEditID");
		new Float:px, Float:py, Float:pz, Float:pa, pint = GetPlayerInterior(playerid), pworld = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(playerid, px, py, pz);
		GetPlayerFacingAngle(playerid, pa);

		SendFormatMessage(playerid, COLOR_GRAD, " �ҧ��Ңͧ "EMBED_WHITE"%s"EMBED_GRAD" �١����¹���ѧ�������Ѩ�غѹ�ͧ�س����", entranceData[id][eName]);
		Log(a_action_log, INFO, "%s: ����¹�ҧ��Ңͧ %s(%d) �ҡ %f,%f,%f (int:%d|world:%d) �� %f,%f,%f (int:%d|world:%d)", ReturnPlayerName(playerid), entranceData[id][eName], entranceData[id][eID], entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ], entranceData[id][extInt], entranceData[id][extWorld], px, py, pz, pint, pworld);

        entranceData[id][extX]=px;
        entranceData[id][extY]=py;
        entranceData[id][extZ]=pz;
		entranceData[id][extA]=pa;
        entranceData[id][extInt]=pint;
        entranceData[id][extWorld]=pworld;

		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
	   	Entrance_Save(id);
	}
	return ShowPlayerEditEntrance(playerid);
}

Dialog:EntranceEdit_Exit(playerid, response, listitem, inputtext[])
{
	if (response)
	{
		new id = GetPVarInt(playerid, "EntranceEditID");
		new Float:px, Float:py, Float:pz, Float:pa, pint = GetPlayerInterior(playerid), pworld = ENTRANCE_WORLD + entranceData[id][eID];
		GetPlayerPos(playerid, px, py, pz);
		GetPlayerFacingAngle(playerid, pa);

		SendFormatMessage(playerid, COLOR_GRAD, " �ҧ�͡�ͧ "EMBED_WHITE"%s"EMBED_GRAD" �١����¹���ѧ�������Ѩ�غѹ�ͧ�س����", entranceData[id][eName]);
		Log(a_action_log, INFO, "%s: ����¹�ҧ�͡�ͧ %s(%d) �ҡ %f,%f,%f (int:%d) �� %f,%f,%f (int:%d)", ReturnPlayerName(playerid), entranceData[id][eName], entranceData[id][eID], entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ], entranceData[id][extInt], px, py, pz, pint);

        entranceData[id][intX]=px;
        entranceData[id][intY]=py;
        entranceData[id][intZ]=pz;
		entranceData[id][intA]=pa;
        entranceData[id][eInt]=pint;
        entranceData[id][eWorld]=pworld;

		Entrance_Update(id);
		Streamer_Update(playerid, STREAMER_TYPE_3D_TEXT_LABEL);
	   	Entrance_Save(id);

        SetPlayerVirtualWorld(playerid, pworld);
	}
	return ShowPlayerEditEntrance(playerid);
}

hook OP_KeyStateChange(playerid, newkeys, oldkeys) {
	if(Pressed(KEY_SECONDARY_ATTACK)) {
	    foreach(new id : Iter_Entrance)
	    {
	        if (entranceData[id][intX] != 0.0 && entranceData[id][intY] != 0.0 && IsPlayerInRangeOfPoint(playerid, 2.5, entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ])) {
	        	SetPlayerPos(playerid, entranceData[id][intX], entranceData[id][intY], entranceData[id][intZ]);
	        	SetPlayerInterior(playerid, entranceData[id][eInt]);
	        	SetPlayerVirtualWorld(playerid, entranceData[id][eWorld]);
                SetPlayerFacingAngle(playerid, entranceData[id][intA]);
	        }
	        else if (IsPlayerInRangeOfPoint(playerid, 2.5, entranceData[id][intX], entranceData[id][intY], entranceData[id][intZ])) {
	        	SetPlayerPos(playerid, entranceData[id][extX], entranceData[id][extY], entranceData[id][extZ]);
	        	SetPlayerInterior(playerid, entranceData[id][extInt]);
	        	SetPlayerVirtualWorld(playerid, entranceData[id][extWorld]);
                SetPlayerFacingAngle(playerid, entranceData[id][extA]);
	        }
	    }
	}
    return 1;
}
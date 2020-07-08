flags:adminhelp(CMD_ADM1)
CMD:adminhelp(playerid, params[])
{
	if (playerData[playerid][pAdmin] >= 1)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "___________________________ASISSTANT COMMANDS___________________________");
		SendClientMessage(playerid, COLOR_GRAD1, "[Level 1]: /adminhelp, /goto(sf,ls)");
	}
	if (playerData[playerid][pAdmin] >= 2)
	{
		SendClientMessage(playerid, COLOR_GREEN, "___________________________MODERATOR COMMANDS___________________________");

		SendClientMessage(playerid, COLOR_GRAD1,"[Level 2]: /sethp, /setarmor, /settospawn");
	}
	if (playerData[playerid][pAdmin] >= 3)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "___________________________ADMINISTRATOR COMMANDS___________________________");

		SendClientMessage(playerid, COLOR_GRAD1,"[Level 3]: /givegun, /veh, /daveh (źö�ʡ), /davehs (źö�ʡ������)");
	}
	if (playerData[playerid][pAdmin] >= 4)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "___________________________LEAD ADMIN COMMANDS___________________________");

		SendClientMessage(playerid, COLOR_GRAD1,"[Level 4]: /viewfactions, /makeleader");
		SendClientMessage(playerid, COLOR_GRAD1,"[Level 4]: ");
	}
	if (playerData[playerid][pAdmin] >= 5)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "___________________________MANAGEMENT COMMANDS___________________________");
		SendClientMessage(playerid, COLOR_GRAD1,"[Level 5]: /factioncmds, /vehcmds, /entrancecmds");
	}
	if (playerData[playerid][pAdmin] >= 6)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "___________________________DEVELOPER COMMANDS___________________________");
		SendClientMessage(playerid, COLOR_GRAD1,"[Level X]: /gmx");
	}
	SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
	return 1;
}
alias:adminhelp("ahelp", "acmds")

flags:gmx(CMD_DEV)
CMD:gmx(playerid, params[])
{
	new time;

	if (sscanf(params, "d", time)) {
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
        SendClientMessage(playerid, COLOR_GRAD1, "�����: /gmx [�Թҷ�]");
        SendClientMessage(playerid, COLOR_GRAD1, "���й�: ¡��ԡ������ 0 ���������Ţ�����������͹����");
        return 1;
    }

    if (time == 0) {
        if(!g_ServerRestart) return SendClientMessage(playerid, COLOR_LIGHTRED, "����������ѧ�����������Ѻ���Ҷ����ѧ");
	    TextDrawHideForAll(g_ServerRestartCount);
	    g_ServerRestart = false;
	    g_RestartTime = 0;
		Log(system_log, INFO, "Server cancel restart.");
	    return SendFormatMessageToAll(COLOR_LIGHTRED, "SERVER:"EMBED_WHITE" %s ��¡��ԡ�����ʵ������������", ReturnPlayerName(playerid));
	}
    else if (time < 3 || time > 600) return SendClientMessage(playerid, COLOR_LIGHTRED, "�Թҷշ���к�����õ�ӡ��� 3 �����ҡ���� 600");

    TextDrawShowForAll(g_ServerRestartCount);
    
	Log(system_log, INFO, "The %s %d sec.", g_ServerRestart ? ("server restart change time to"):("server will restart in"), time);
    SendFormatMessageToAll(COLOR_LIGHTRED, "SERVER:"EMBED_WHITE" %s %s��ա %d �Թҷ�", ReturnPlayerName(playerid), g_ServerRestart ? ("������͹������ʵ������������������"):("���������ʵ����Կ�����"), time);

	g_ServerRestart = true;
	g_RestartTime = time;
	return 1;
}

flags:sethp(CMD_ADM2)
CMD:sethp(playerid, params[])
{
	new userid, health;

	if (sscanf(params, "ud", userid, health)) {
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
		return SendClientMessage(playerid, COLOR_GRAD1, "�����: /sethp [�ʹ�/���ͺҧ��ǹ] [�ӹǹ���ʹ]");
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹��������������͡Ѻ���������");

	if(userid != playerid) { 
		SendFormatMessage(playerid, COLOR_YELLOW, "�س���Ѻ���ʹ %s �� %d !", ReturnPlayerName(userid), health);
		SendFormatMessage(userid, COLOR_GRAD1, "���ʹ�ͧ�س�١��Ѻ�� %d �¼������к� %s", health, ReturnPlayerName(playerid));
	}
	else {
		SendFormatMessage(playerid, COLOR_YELLOW, "�س���Ѻ���ʹ�ͧ����ͧ�� %d !", health);
	}
	SetPlayerHealth(userid, health);

	return 1;
}

flags:setarmor(CMD_ADM2)
CMD:setarmor(playerid, params[])
{
	new userid, health;

	if (sscanf(params, "ud", userid, health)) {
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
		return SendClientMessage(playerid, COLOR_GRAD1, "�����: /setarmor [�ʹ�/���ͺҧ��ǹ] [�ӹǹ����]");
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹��������������͡Ѻ���������");

	if(userid != playerid) { 
		SendFormatMessage(playerid, COLOR_GRAD1, "   �س���Ѻ���� %s �� %d", ReturnPlayerName(userid), health);
		SendFormatMessage(userid, COLOR_YELLOW, "���Тͧ�س�١��Ѻ�� %d �¼������к� %s", health, ReturnPlayerName(playerid));
	}
	else {
		SendFormatMessage(playerid, COLOR_GRAD1, "�س���Ѻ���Тͧ����ͧ�� %d", health);
	}
	SetPlayerArmour(userid, health);
	return 1;
}

flags:settospawn(CMD_ADM2)
CMD:settospawn(playerid, params[])
{
	new userid;

	if (sscanf(params, "u", userid)) {
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
		return SendClientMessage(playerid, COLOR_GRAD1, "�����: /settospawn [�ʹ�/���ͺҧ��ǹ]");
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹��������������͡Ѻ���������");

	if(userid != playerid) { 
		SendFormatMessage(playerid, COLOR_GRAD1, "   �س���� %s ��Ѻ�ش�Դ", ReturnPlayerName(userid));
		SendFormatMessage(userid, COLOR_YELLOW, "�س�١�觡�Ѻ�ش�Դ�¼������к� %s", ReturnPlayerName(playerid));
	}
	else {
		SendClientMessage(playerid, COLOR_GRAD1, "�س���觵���ͧ��Ѻ�ش�Դ");
	}
	SpawnPlayer(userid);
	return 1;
}

flags:givegun(CMD_ADM3)
CMD:givegun(playerid, params[])
{
	new userid, gunid, ammo;

	if(sscanf(params, "uii", userid, gunid, ammo))
	{
		SendClientMessage(playerid, COLOR_GREEN, "___________________________[�����]___________________________");
		SendClientMessage(playerid, COLOR_GRAD1, "�����: /givegun [�ʹ�/���ͺҧ��ǹ] [�ʹ����ظ] [�ӹǹ]");
		SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");
		SendClientMessage(playerid, COLOR_GREY, "1: Brass Knuckles 2: Golf Club 3: Nite Stick 4: Knife 5: Baseball Bat 6: Shovel 7: Pool Cue 8: Katana 9: Chainsaw");
		SendClientMessage(playerid, COLOR_GREY, "10: Purple Dildo 11: Small White Vibrator 12: Large White Vibrator 13: Silver Vibrator 14: Flowers 15: Cane 16: Frag Grenade");
		SendClientMessage(playerid, COLOR_GREY, "17: Tear Gas 18: Molotov Cocktail 19: Vehicle Missile 20: Hydra Flare 21: Jetpack 22: 9mm 23: Silenced 9mm 24: Desert Eagle 25: Shotgun");
		SendClientMessage(playerid, COLOR_GREY, "26: Sawnoff Shotgun 27: SPAS-12 28: Micro SMG (Mac 10) 29: SMG (MP5) 30: AK-47 31: M4 32: Tec9 33: Rifle");
		SendClientMessage(playerid, COLOR_GREY, "25: Shotgun 34: Sniper Rifle 35: Rocket Launcher 36: HS Rocket Launcher 37: Flamethrower 38: Minigun 39: Satchel Charge");
		SendClientMessage(playerid, COLOR_GREY, "40: Detonator 41: Spraycan 42: Fire Extinguisher 43: Camera 44: Nightvision Goggles 45: Infared Goggles 46: Parachute");
		SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");

		return 1;
	}

	if(userid == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, COLOR_GRAD1, "   �����蹹��������������͡Ѻ���������");

	if(gunid < 0 || gunid > 46 || gunid == 19 || gunid == 20 || gunid == 21) return SendClientMessage(playerid, COLOR_GREY, "Invalid weapon id.");

	if(userid != playerid) { 
		SendFormatMessage(playerid, COLOR_GRAD1, "   �س����� %s �ӹǹ %d �Ѻ %s", ReturnWeaponNameEx(gunid), ammo, ReturnPlayerName(userid));
		SendFormatMessage(userid, COLOR_YELLOW, "�س���Ѻ %s �ӹǹ %d �ҡ�������к� %s", ReturnWeaponNameEx(gunid), ammo, ReturnPlayerName(playerid));
	}
	else {
		SendFormatMessage(playerid, COLOR_GRAD1, "   �س���Ѻ %s �ӹǹ %d", ReturnWeaponNameEx(gunid), ammo);
	}

	GivePlayerWeapon(userid, gunid, ammo);
	
	return 1;
}

flags:gotols(CMD_ADM1)
CMD:gotols(playerid)
{
	SetPlayerPos(playerid, 1529.6,-1691.2,13.3);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);

	playerData[playerid][pInterior] = 0;
	playerData[playerid][pVWorld] = 0;
			
	SendClientMessage(playerid, COLOR_GRAD, "�س��������ѧ���ͧ "EMBED_YELLOW"Los Santos"EMBED_GRAD"!");
	return 1;
}

flags:gotosf(CMD_ADM1)
CMD:gotosf(playerid)
{
	SetPlayerPos(playerid, -1973.3322,138.0420,27.6875);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	
	playerData[playerid][pInterior] = 0;
	playerData[playerid][pVWorld] = 0;

	SendClientMessage(playerid, COLOR_GRAD, "�س��������ѧ���ͧ "EMBED_YELLOW"San Fierro"EMBED_GRAD"!");
	return 1;
}
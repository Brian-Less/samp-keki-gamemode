//--------------------------------[TIMERS.PWN]--------------------------------

ptask PlayerTimer[1000](playerid) {

	if(bf_get(player_bf[playerid], IS_SPAWNED)) {
	
		if(delayLeg[playerid]) {
			delayLeg[playerid]--;
		}
		
		if(isDeathmode{playerid}) {
			SetPlayerChatBubble(playerid, "(( �����蹹�������� ))", 0xFF6347FF, 20.0, 1500);
		}
		
		if(InjuredTime[playerid] > 0) {
			InjuredTime[playerid]--;
		}
		
		if(isInjuredmode{playerid} && InjuredTime[playerid] == 0) {
		
			if(!isDeathmode{playerid})
			{
				isDeathmode{playerid} = true;
				InjuredTime[playerid] = 60;
				
				if (!IsPlayerInAnyVehicle(playerid)) {
					ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 0, 0, 1, 0, 1);
				}	
				SendClientMessage(playerid, COLOR_YELLOW, "-> �س�������㹢�й�� �س���繵�ͧ�� 60 �Թҷ������ѧ�ҡ��鹤س�֧������ö /respawnme");
			}
			else {
				SendClientMessage(playerid, COLOR_YELLOW, "-> ���ҵ�¢ͧ�س���ŧ���� �س����ö /respawnme ��㹢�й��");
				InjuredTime[playerid]=-1;
			}
		}
	}
	return 1;
}

task RestartCheck[1000]()
{
	if (g_ServerRestart)
	{	
		if(g_RestartTime) {
			new string[32];
			format(string, 32, "~r~Server Restart:~w~ %02d:%02d", g_RestartTime / 60, g_RestartTime % 60);
			TextDrawSetString(g_ServerRestartCount, string);
			TextDrawShowForAll(g_ServerRestartCount);
			g_RestartTime--;
		}
		else {
			if(g_RestartTime == 0) {
				foreach (new i : Player) {
					OnAccountUpdate(i, false, MYSQL_UPDATE_TYPE_SINGLE);
				}
			}
			SendRconCommand("gmx");

            SendClientMessageToAll(COLOR_BLUE, " ");
            SendClientMessageToAll(COLOR_DARKGREEN, "Keki Project");
            SendClientMessageToAll(COLOR_BLUE, "    Copyright (C) 2018 Ak-kawit \"Aktah\" Tahae");
            SendClientMessageToAll(COLOR_BLUE, "    �����������١���ҧ��������������");
            SendClientMessageToAll(COLOR_BLUE, "    �ء������ö�ʴ������Դ��������ҧ�������������������������Թ�㹷ҧ���բ��");
            SendClientMessageToAll(COLOR_BLUE, " ");
            SendClientMessageToAll(COLOR_BLUE, " ");
            SendClientMessageToAll(COLOR_BLUE, " ");
            SendClientMessageToAll(COLOR_BLUE, "-------------------------------------------------------------------------------------------------------------------------");
            SendClientMessageToAll(COLOR_YELLOW, " >  �����������ѧ��ʵ��� �ô���ѡ����...");
            SendClientMessageToAll(COLOR_BLUE, "-------------------------------------------------------------------------------------------------------------------------");
		}
	}
	return 1;
}
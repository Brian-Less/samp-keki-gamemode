#define MAX_AIRDROP_BOX 5
#define FLOAT_INFINITY   (Float:0x7F800000)

enum E_BOX_DATA {
    bool:IsExist,
    ObjectBox,
    ObjectFlash
}

new BoxInfo[MAX_AIRDROP_BOX][E_BOX_DATA];
new bool:IsGetBox[MAX_PLAYERS][MAX_AIRDROP_BOX];

CMD:box(playerid, params[])
{
    if (playerData[playerid][pAdmin])
    {
        new bool:checked;
        for(new i=0; i != MAX_AIRDROP_BOX; i++) {
            if(!BoxInfo[i][IsExist]) {
                BoxInfo[i][IsExist]=true;

                new Float:x ,Float:y ,Float:z;
                GetPlayerPos(playerid, x, y, z);

                BoxInfo[i][ObjectBox] = CreateDynamicObject(19054, x, y, z+90, 0, 0, 0);
                BoxInfo[i][ObjectFlash] = CreateDynamicObject(18728, x, y, z+85, 0, 0, 0); 
                MoveDynamicObject(BoxInfo[i][ObjectBox], x, y, z-0.4, 10.00);
                MoveDynamicObject(BoxInfo[i][ObjectFlash], x, y, z-1.2, 10.00);
                SetTimerEx("Box2",20000 , 0, "d", i);

                SendClientMessage(playerid, -1, "���������: �س�����ҧ Airdrop �ʹ� "EMBED_ORANGE"%d"EMBED_WHITE"", i);

                checked = true;

                break;
            }
        }
        if(!checked) SendClientMessage(playerid, COLOR_LIGHTRED, "���������: �֧�մ�ӡѴ㹡�����ҧ���ͧ Airdrop ����");
    }
    else
    {
        SendClientMessage(playerid, -1, "���������: �س������ʹ�Թ�������ö����¡��ͧ��");
    }
    return 1;
}

forward Box2(id); // index from BoxInfo
public Box2(id)
{  
    DestroyDynamicObject(BoxInfo[id][ObjectBox]);     //�繡��źObject Box1
    DestroyDynamicObject(BoxInfo[id][ObjectFlash]);   //�繡��źObject flash1
    BoxInfo[id][IsExist]=false;

    foreach(new i : Player) {
        if(IsGetBox[i][id]) {
            IsGetBox[i][id]=false;
        }
        SendClientMessage(i, -1, "���������: Airdrop ID "EMBED_ORANGE"%d"EMBED_WHITE" ��١���������", id);
    }
    return 1;
}

CMD:getbox(playerid, params[])
{
    new
        Float:fDistance = FLOAT_INFINITY,
        iIndex = -1
    ;

    for(new i=0; i != MAX_AIRDROP_BOX; i++) {
        if(BoxInfo[i][IsExist]) { // ੾�С��ͧ���١���ҧ

            new Float:x ,Float:y ,Float:z;
            GetDynamicObjectPos(BoxInfo[i][ObjectBox], x, y, z); 

            new
                Float:temp = GetPlayerDistanceFromPoint(playerid, x, y, z);

            if (temp < fDistance && temp <= 5.0)
            {
                fDistance = temp;
                iIndex = i;
            }
        }
    }

    if(iIndex != -1) {
        if(!IsGetBox[playerid][iIndex]) 
        {
            IsGetBox[playerid][iIndex] = true;

            switch(random(10))
            {
            case 0:
            {
                SendClientMessage(playerid, -1, "Server : �س��ͧ��鹷�� 1"); //���ͧ�ҧ���
            }
            case 1:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 2 ");//���ͧ�ҧ���
            }
            case 2:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 3");//���ͧ�ҧ���
            }
            case 3:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 4");//���ͧ�ҧ���
            }
            case 4:
            {
                SendClientMessage(playerid, -1, "Server : �س��ͧ��鹷�� 5");//���ͧ�ҧ���
            }
            case 5:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 6");//���ͧ�ҧ���
            }
            case 6:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 7");//���ͧ�ҧ���
            }
            case 7:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 8");//���ͧ�ҧ���
            }
            case 8:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 9");//���ͧ�ҧ���
            }
            case 9:
            {
                SendClientMessage(playerid, -1, "Server :  �س��ͧ��鹷�� 10");//���ͧ�ҧ���
            }
            }
        }
        else return SendClientMessage(playerid, -1, "Server : �س�Ѻ�ͧ����� �������ö�Ѻ�ͧ���ա");
    }
    else {
        SendClientMessage(playerid, -1, "Server : �س���������ش�����ͧ��ͻ���͡��ͧ�ѧ������ͻ");
    }
    return 1;
}
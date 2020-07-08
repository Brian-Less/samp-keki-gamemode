//--------------------------------[DEFINES.PWN]--------------------------------

// ������ BitFlag
#define bf_get(%0,%1)            ((%0) & (%1))   // �觤�ҡ�Ѻ 0 (��)�ҡ�ѧ������駤������ѹ
#define bf_on(%0,%1)             ((%0) |= (%1))  // ��Ѻ����� �Դ
#define bf_off(%0,%1)            ((%0) &= ~(%1)) // ��Ѻ����� �Դ
#define bf_toggle(%0,%1)         ((%0) ^= (%1))  // ��Ѻ��� (��Ѻ ��ԧ/��)

// ������ Key
#define Pressed(%0)	\
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define Holding(%0) \
	((newkeys & (%0)) == (%0))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

// Weapon Skill
#define NORMAL_SKILL		1
#define MEDIUM_SKILL		2
#define FULL_SKILL			3

#define WEAPON_UNARMED 		0
#define WEAPON_PISTOLWHIP 	48
#define WEAPON_CARPARK 		52

#define MAX_DAMAGES			30 // Damage System

#define	MAX_FACTIONS		20
#define MAX_FACTION_RANKS	21
#define MAX_FACTION_SKINS	20
#define MAX_FACTION_WEAPONS	10

// MYSQL UPDATE
#define MYSQLUPDATE_TYPE_SINGLE	0
#define MYSQLUPDATE_TYPE_THREAD	1

// BODY PARTS
#define BODY_PART_TORSO 	3
#define BODY_PART_GROIN 	4
#define BODY_PART_RIGHT_ARM 5
#define BODY_PART_LEFT_ARM 	6
#define BODY_PART_RIGHT_LEG 7
#define BODY_PART_LEFT_LEG 	8
#define BODY_PART_HEAD 		9

// Spawn points:
#define SPAWN_POINT_DEFAULT		(0)
#define SPAWN_POINT_PROPERTY	(1)
#define SPAWN_POINT_FACTION		(2)

#define MAX_STRING	255
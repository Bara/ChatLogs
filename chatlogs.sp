#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#include <autoexecconfig>

#undef REQUIRE_PLUGIN
#undef REQUIRE_EXTENSIONS
#tryinclude <sourcetvmanager>

#pragma newdecls required

// sql stuff
#define CNAME "Chat Logs"
Database g_dDB = null;
bool bLogMessage = true;
bool bDebug = true;

ConVar g_cEnable = null;
ConVar g_cSay = null;
ConVar g_cChat = null;
ConVar g_cCsay = null;
ConVar g_cTsay = null;
ConVar g_cMsay = null;
ConVar g_cHsay = null;

bool g_bSourceTV = false;

public Plugin myinfo = 
{
	name = "SQL ChatLogs",
	author = "Bara (Credits: McFlurry, Keith Warren (Drixevel)",
	description = "",
	version = "2.0",
	url = "github.com/Bara"
}

public void OnPluginStart()
{
	AutoExecConfig_SetCreateDirectory(true);
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_SetFile("plugin.chatlogs");
	g_cEnable = AutoExecConfig_CreateConVar("sql_chatlogs_enable", "1", "Enable Chat Logging", _, true, 0.0, true, 1.0);
	g_cSay = AutoExecConfig_CreateConVar("sql_chatlogs_sm_say", "1", "Log sm_say in chat log?", _, true, 0.0, true, 1.0);
	g_cChat = AutoExecConfig_CreateConVar("sql_chatlogs_sm_chat", "1", "Log sm_chat in chat log?", _, true, 0.0, true, 1.0);
	g_cCsay = AutoExecConfig_CreateConVar("sql_chatlogs_sm_csay", "1", "Log sm_csay in chat log?", _, true, 0.0, true, 1.0);
	g_cTsay = AutoExecConfig_CreateConVar("sql_chatlogs_sm_tsay", "1", "Log sm_tsay in chat log?", _, true, 0.0, true, 1.0);
	g_cMsay = AutoExecConfig_CreateConVar("sql_chatlogs_sm_msay", "1", "Log sm_msay in chat log?", _, true, 0.0, true, 1.0);
	g_cHsay = AutoExecConfig_CreateConVar("sql_chatlogs_sm_hsay", "1", "Log sm_hsay in chat log?", _, true, 0.0, true, 1.0);
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	AddCommandListener(Command_Say, "sm_say");
	AddCommandListener(Command_CSay, "sm_csay");
	AddCommandListener(Command_TSay, "sm_tsay");
	AddCommandListener(Command_MSay, "sm_msay");
	AddCommandListener(Command_HSay, "sm_hsay");
		
	SQL_TConnect(sqlConnect, "chatlogs");

	g_bSourceTV = LibraryExists("sourcetvmanager");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "sourcetvmanager"))
	{
		g_bSourceTV = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "sourcetvmanager"))
	{
		g_bSourceTV = false;
	}
}

public void sqlConnect(Handle owner, Handle hndl, const char[] error, any data)
{
	if(hndl == null)
	{
		SetFailState("[%s] (sqlConnect) Can't connect to mysql", CNAME);
		return;
	}
	
	g_dDB = view_as<Database>(CloneHandle(hndl));
	
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `chat_logs` (`id` INT NOT NULL AUTO_INCREMENT, `time` INT NOT NULL, `ip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL, `port` int(6) NOT NULL, `map` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL, `command` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL, `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL, `communityid` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL, `alive` tinyint(1) COLLATE utf8mb4_unicode_ci NOT NULL, `team` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL, `text` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL, PRIMARY KEY (`id`), `tick` int(12) DEFAULT NULL, KEY `communityid` (`communityid`), KEY `text` (`text`), KEY `communityid_2` (`communityid`,`text`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");
	
	if(bLogMessage && bDebug)
		LogMessage(sQuery);
	
	g_dDB.Query(sqlCreateTable, sQuery);
}

public void sqlCreateTable(Database db, DBResultSet results, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		SetFailState("[%s] (sqlCreateTable) Fail at Query: %s", CNAME, error);
		return;
	}
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
	if (!g_cEnable.BoolValue || !g_cChat.BoolValue)
	{
		return;
	}
	
	if (strlen(sArgs) == 0)
	{
		return;
	}
	
	if (sArgs[0] == '@')
	{
		if (!CheckCommandAccess(client, "sm_say", ADMFLAG_CHAT))
		{
			return;
		}
		
		addToSQL(command, client, sArgs[1], true);
		return;
	}
	
	addToSQL(command, client, sArgs);
}

public Action Command_Say(int client, const char[] command, int args)
{
	if(!g_cEnable.BoolValue || !g_cSay.BoolValue)
	{
		return;
	}
	
	char Chat[256];
	GetCmdArgString(Chat, sizeof(Chat));
	
	if (strlen(Chat) == 0)
	{
		return;
	}
	
	addToSQL(command, client, Chat, true);
}

public Action Command_CSay(int client, const char[] command, int args)
{
	if(!g_cEnable.BoolValue || !g_cCsay.BoolValue)
	{
		return;
	}
	
	char Chat[256];
	GetCmdArgString(Chat, sizeof(Chat));
	
	if (strlen(Chat) == 0)
	{
		return;
	}
	
	addToSQL(command, client, Chat, true);
}

public Action Command_TSay(int client, const char[] command, int args)
{
	if(!g_cEnable.BoolValue || !g_cTsay.BoolValue)
	{
		return;
	}
	
	char Chat[256];
	GetCmdArgString(Chat, sizeof(Chat));
	
	if (strlen(Chat) == 0)
	{
		return;
	}
	
	addToSQL(command, client, Chat, true);
}

public Action Command_MSay(int client, const char[] command, int args)
{
	if(!g_cEnable.BoolValue || !g_cMsay.BoolValue)
	{
		return;
	}
	
	char Chat[256];
	GetCmdArgString(Chat, sizeof(Chat));
	
	if (strlen(Chat) == 0)
	{
		return;
	}

	if (client == 0)
	{
		return;
	}
	
	addToSQL(command, client, Chat, true);
}

public Action Command_HSay(int client, const char[] command, int args)
{
	if(!g_cEnable.BoolValue || !g_cHsay.BoolValue)
	{
		return;
	}
	
	char Chat[256];
	GetCmdArgString(Chat, sizeof(Chat));
	
	if (strlen(Chat) == 0)
	{
		return;
	}
	
	addToSQL(command, client, Chat, true);
}

void addToSQL(const char[] command, int client, const char[] text, bool adminText = false)
{
	char sTeam[12], sAuth[18], sName[MAX_NAME_LENGTH];
	bool bAlive = false;
	
	if (IsClientValid(client))
	{
		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sAuth, sizeof(sAuth));
		bAlive = IsPlayerAlive(client);
		
		int team = GetClientTeam(client);
		
		if (team == CS_TEAM_T)
		{
			Format(sTeam, sizeof(sTeam), "t");
		}
		else if (team == CS_TEAM_CT)
		{
			Format(sTeam, sizeof(sTeam), "ct");
		}
		else
		{
			Format(sTeam, sizeof(sTeam), "spec");
		}
		
		if (adminText)
		{
			Format(sTeam, sizeof(sTeam), "admin");
		}
	}
	else
	{
		Format(sName, sizeof(sName), "Console");
		Format(sTeam, sizeof(sTeam), "console");
	}
	
	char sMap[24];
	GetCurrentMap(sMap, sizeof(sMap));

	int iPort = GetConVarInt(FindConVar("hostport"));

	char sIP[18];
	int ips[4];
	int iIP = GetConVarInt(FindConVar("hostip"));
	ips[0] = (iIP >> 24) & 0x000000FF;
	ips[1] = (iIP >> 16) & 0x000000FF;
	ips[2] = (iIP >> 8) & 0x000000FF;
	ips[3] = iIP & 0x000000FF;
	Format(sIP, sizeof(sIP), "%d.%d.%d.%d", ips[0], ips[1], ips[2], ips[3]);

	int iTick = 0;

	if (g_bSourceTV)
	{
		iTick = SourceTV_GetBroadcastTick();
	}
	
	char sQuery[1024];
	g_dDB.Format(sQuery, sizeof(sQuery), "INSERT INTO `chat_logs` (`time`, `tick`, `ip`, `port`, `map`, `command`, `name`, `communityid`, `alive`, `team`, `text`) VALUES (UNIX_TIMESTAMP(), %d, \"%s\", %d, \"%s\", \"%s\", \"%s\", \"%s\", %d, \"%s\", \"%s\")", iTick, sIP, iPort, sMap, command, sName, sAuth, bAlive, sTeam, text);

	if(bLogMessage && bDebug)
		LogMessage(sQuery);

	g_dDB.Query(sqlInsert, sQuery);
}

public void sqlInsert(Database db, DBResultSet results, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		SetFailState("[%s] (sqlInsert) Fail at Query: %s", CNAME, error);
		return;
	}
	delete results;
}

stock bool IsClientValid(int client, bool bots = false)
{
	if (client > 0 && client <= MaxClients)
	{
		if(IsClientInGame(client) && (bots || (!IsFakeClient(client)) && !IsClientSourceTV(client)))
		{
			return true;
		}
	}
	
	return false;
}

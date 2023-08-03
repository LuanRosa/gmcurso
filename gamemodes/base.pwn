#define SSCANF_NO_NICE_FEATURES

//                          INCLUDES
 
#include        < a_samp >
#include 		< sscanf2 >
#include 		< streamer >
#include        < DOF2>
#include        < ZCMD >

#include 		"../mapas/mapserver.inc"

//                          CONFIGS

#define Callback::%0(%1) 		forward %0(%1);\
							public %0(%1)

#define Kick(%0) 					SetTimerEx("KickPlayer", 500, false, "i", %0)
#define SpawnPlayer(%0) 			SetTimerEx("SpawnP", 500, false, "i", %0)
#define SERVERFORUM     			"www.embreve.com.br" 	//Site do seu servidor
#define MAX_PING        			800	                    //Altere o máximo Ping antes do jogador ser kickado
#define SEGUNDOS_SEM_FALAR  		2                       //Quantidade de segundos sem poder enviar mensagens após enviar uma (PADRÃO = 2)

//                           CORES

#define		CorSucesso      0x00FFFFFF
#define     CorErro         0xFF4500FF
#define     CorErroNeutro   0xFFFFFFFF
#define     Branco          0xFFFFFFFF
#define     CinzaClaro      0xD3D3D3FF
#define     CinzaEscuro     0xE64022FF
#define     Azul            0x0000FFFF 
#define     AzulClaro       0x1E90FFFF
#define     AzulRoyal       0x4169E1FF
#define     Verde           0x00FF00FF
#define     Amarelo         0xFFFF00FF
#define     Vermelho        0xFF0000FF
#define     VermelhoEscuro  0xB22222FF

//                          DEFINES

enum
{
	DIALOG_LOGIN,
	DIALOG_REGISTRO,
	DIALOG_BANIDO,
	DIALOG_POS,
	DIALOG_PRESOS
}

//                      ENUM JOGADOR

enum pInfo
{
	pSenha[24],
	pLevel,
	pSkin,
	pDinheiro,
	pSegundosJogados,
	pAvisos,
	pCadeia,
	pAdmin,
	pLastLogin[24],
	pInterior,
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	Float:pPosA,
	Float:pCamX,
	Float:pCamY,
	Float:pCamZ,
	bool:pCongelado,
	bool:pCalado
}
new	PlayerInfo[MAX_PLAYERS][pInfo];

//                      TEXTDRAWS

new Text:Textdraw0;
new	Text:Textdraw1;
new	PlayerText:Textdraw2[MAX_PLAYERS];
new Text:DataC, Text:HoraC;

//                      VARIAVEIS

new UltimaFala[MAX_PLAYERS];
new AvisosPing[MAX_PLAYERS];
new	Assistindo[MAX_PLAYERS] = -1;
new	Erro[MAX_PLAYERS];
new	File[255];
new	Motivo[255];
new	Str[256];
new	ID;
new	Numero;
new	Float:Pos[3];


//                      BOOLS

new	bool:AntiAFK_Ativado = true;
new	bool:Moved[MAX_PLAYERS];
new	bool:FoiCriado[MAX_VEHICLES] = false;
new	bool:AparecendoNoAdmins[MAX_PLAYERS] = true;
new	bool:FirstLogin[MAX_PLAYERS];
new	bool:SpawnPos[MAX_PLAYERS] = false;
new	bool:pJogando[MAX_PLAYERS] = true;
new	bool:pLogado[MAX_PLAYERS] = false;
new	bool:IsAssistindo[MAX_PLAYERS] = false;
new	bool:ContagemIniciada = false;
new	bool:ChatLigado = true;

//                      TIMERS

new TimerHacker[MAX_PLAYERS];

//                      DEFINES FLOAT

new Float:Entradas[][3] =
{
    {000.000000,000.000000000,000.000000}//Nenhum
};



main()
{
	print("'Gamemode Base Iniciada Com Sucesso'");
	print("     Criada por Luan_Rosa (RosaScripter).");
}

//                          PUBLICS

Callback::TimerHack(playerid)
{
	if(!IsPlayerConnected(playerid))
		return true;

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][pDinheiro]);
	SetTimerEx("TimerHack", 500, false, "i", playerid);
	return true;
}

Callback::AntiAway()
{
	if(AntiAFK_Ativado == false) return 0;
	new Float:X, Float:Y, Float:Z;
	new Float:CX, Float:CY, Float:CZ;
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i) || pLogado[i] == false) return 0;
	    GetPlayerPos(i, X, Y, Z);
	    GetPlayerCameraPos(i, CX, CY, CZ);
	    if(X == PlayerInfo[i][pPosX] && Y == PlayerInfo[i][pPosY] && Z == PlayerInfo[i][pPosZ]) SetTimerEx("TestAway", 1000, false, "ii", i, 10), Moved[i] = false;
		GetPlayerPos(i, PlayerInfo[i][pPosX], PlayerInfo[i][pPosY], PlayerInfo[i][pPosZ]);
		GetPlayerCameraPos(i, PlayerInfo[i][pCamX], PlayerInfo[i][pCamY], PlayerInfo[i][pCamZ]);
	}
	return 1;
}

Callback::TestAway(playerid, TimeTo)
{
    if(AntiAFK_Ativado == false)
	{
		TextDrawHideForPlayer(playerid, Textdraw0);
		TextDrawHideForPlayer(playerid, Textdraw1);
		PlayerTextDrawHide(playerid, Textdraw2[playerid]);
	 	return 0;
	}
	if(Moved[playerid] == true)
	{
		TextDrawHideForPlayer(playerid, Textdraw0);
		TextDrawHideForPlayer(playerid, Textdraw1);
		PlayerTextDrawHide(playerid, Textdraw2[playerid]);
		return 0;
	}
	new Float:X, Float:Y, Float:Z;
	new Float:CX, Float:CY, Float:CZ;
	GetPlayerPos(playerid, X, Y, Z);
    GetPlayerCameraPos(playerid, CX, CY, CZ);
	if(X != PlayerInfo[playerid][pPosX] || Y != PlayerInfo[playerid][pPosY] || Z != PlayerInfo[playerid][pPosZ] || CX != PlayerInfo[playerid][pCamX] || CY != PlayerInfo[playerid][pCamY] || CZ != PlayerInfo[playerid][pCamZ])
	{
		TextDrawHideForPlayer(playerid, Textdraw0);
		TextDrawHideForPlayer(playerid, Textdraw1);
		PlayerTextDrawHide(playerid, Textdraw2[playerid]);
 		return 0;
	}
	if(TimeTo == 0)
	{
	    SendClientMessage(playerid, VermelhoEscuro, "Voce foi Kickado por estar AFK");
		TextDrawHideForPlayer(playerid, Textdraw0);
		TextDrawHideForPlayer(playerid, Textdraw1);
		PlayerTextDrawHide(playerid, Textdraw2[playerid]);
		PlayerTextDrawDestroy(playerid, Textdraw2[playerid]);
		Kick(playerid);
		return 0;
	}
	TextDrawShowForPlayer(playerid, Textdraw0);
	TextDrawShowForPlayer(playerid, Textdraw1);
	format(Motivo, sizeof(Motivo), "%i", TimeTo);
	PlayerTextDrawSetString(playerid, Textdraw2[playerid], Motivo);
	PlayerTextDrawShow(playerid, Textdraw2[playerid]);
	return SetTimerEx("TestAway", 1000, false, "ii", playerid, TimeTo - 1);
}

Callback::SpawnP(playerid)
{
    #undef SpawnPlayer
	SpawnPlayer(playerid);
	#define SpawnPlayer(%0) SetTimerEx("SpawnP", 500, false, "i", %0)
    return 1;
}

Callback::KickPlayer(playerid)
{
	#undef Kick
	Kick(playerid);
	#define Kick(%0) SetTimerEx("KickPlayer", 500, false, "i", %0)
	return 1;
}

Callback::CheckCadeia()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i) || pLogado[i] == false) return 0;
		if(GetPlayerPing(i) > MAX_PING)
		{
		    AvisosPing[i]++;
			format(Str, sizeof(Str), "Seu Ping esta maior que o limite. Por favor, ajuste sua conexao. (AVISO %i/3)", AvisosPing[i]);
			SendClientMessage(i, CorErro, Str);
			if(AvisosPing[i] >= 3)
			{
			 	format(Str, sizeof(Str), "O Jogador %s foi kickado pelo servidor. Motivo: Ping alto (LIMITE: %i)", Name(i), MAX_PING);
				SendClientMessageToAll(VermelhoEscuro, Str);
				Kick(i);
				return 0;
			}
		}
	    PlayerInfo[i][pSegundosJogados] += 2;
	    if(PlayerInfo[i][pCadeia] > 0)
	    {
	        PlayerInfo[i][pCadeia]-= 2;
	        SetPlayerHealth(i, 99999);
	        if(PlayerInfo[i][pCadeia] == 0)
	        {
	            SpawnPlayer(i);
	            SetPlayerInterior(i, 0);
	            SetPlayerVirtualWorld(i, 0);
	            SetPlayerHealth(i, 100);
				SendClientMessage(i, Verde, "Voce esta livre.");
			}
			else
			{
				if(!IsPlayerInRangeOfPoint(i, 50.0, 322.197998, 302.497985, 999.148437))
				{
				    SetPlayerVirtualWorld(i, i);
				    SetPlayerPos(i, 322.197998,302.497985,999.148437);
				    SetPlayerInterior(i, 5);
					SendClientMessage(i, VermelhoEscuro, "Voce ainda nao terminou seu tempo na cadeia.");
				}
			}
		}
	}
	return 1;
}

Callback::DiminuirTempo(Time)
{
        if(Time == 0)
        {
            GameTextForAll("~r~VAAAIII !", 1000, 6);
            ContagemIniciada = false;
        }
        else
        {
	        format(Str, sizeof(Str), "~g~%d", Time);
	        GameTextForAll(Str, 1000, 6);
	        SetTimerEx("DiminuirTempo", 1000, false, "i", Time - 1);
		}
        return 1;
}

Callback::ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                new playerworld, player2world;
                playerworld = GetPlayerVirtualWorld(playerid);
                player2world = GetPlayerVirtualWorld(i);
                if(playerworld == player2world)
                {
                    if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
                    {
                        SendClientMessage(i, col1, string);
                    }
                    else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
                    {
                        SendClientMessage(i, col2, string);
                    }
                    else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
                    {
                        SendClientMessage(i, col3, string);
                    }
                    else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
                    {
                        SendClientMessage(i, col4, string);
                    }
                    else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
                    {
                        SendClientMessage(i, col5, string);
                    }
                }
                else
                {
                    SendClientMessage(i, col1, string);
                }
            }
        }
    }
    return 1;
}

Callback::Relogio()
{
    new string[128], string2[128];

    new minuto, hora, segundo, dia, mes, ano;

    getdate(ano, mes, dia);
    gettime(hora, minuto, segundo);

    new convertermes[20];

    switch(mes)
    {
        case 1:
            { convertermes = "Janeiro"; }
        case 2:
            { convertermes = "Fevereiro"; }
        case 3:
            { convertermes = "Marco"; }
        case 4:
            { convertermes = "Abril"; }
        case 5:
            { convertermes = "Maio"; }
        case 6:
            { convertermes = "Junho"; }
        case 7:
            { convertermes = "Julho"; }
        case 8:
            { convertermes = "Agosto"; }
        case 9:
            { convertermes = "Setembro"; }
        case 10:
            { convertermes = "Outubro"; }
        case 11:
            { convertermes = "Novembro"; }
        case 12:
            { convertermes = "Dezembro"; }
    }

    format(string, sizeof(string), "%d de %s de %d", dia, convertermes, ano);
    TextDrawSetString(DataC, string);
    format(string2, sizeof(string2), "%02d:%02d:%02d", hora, minuto, segundo);
    TextDrawSetString(HoraC, string2);

    switch(hora)
    {
        case 6:
            { SetWorldTime(8); }
        case 9:
            { SetWorldTime(10); }
        case 12:
            { SetWorldTime(12); }
        case 13:
            { SetWorldTime(15); }
        case 14:
            { SetWorldTime(16); }
        case 15:
            { SetWorldTime(18); }
        case 17:
            { SetWorldTime(20); }
        case 18:
            { SetWorldTime(21); }
        case 19:
            { SetWorldTime(23); }
        case 23:
            { SetWorldTime(0); }
        case 22:
            { SetWorldTime(0); }
        case 0:
            { SetWorldTime(3); }
        case 5:
            { SetWorldTime(2); }
    }
    return 1;
}

//                          STOCKS

stock AdminCargo(playerid)
{
	new LipeStrondaAdmin[64];
	if(PlayerInfo[playerid][pAdmin] == 0) { LipeStrondaAdmin = "Civil"; }
	else if(PlayerInfo[playerid][pAdmin] == 1) { LipeStrondaAdmin = "Moderador"; }
	else if(PlayerInfo[playerid][pAdmin] == 2) { LipeStrondaAdmin = "Ajudante"; }
	else if(PlayerInfo[playerid][pAdmin] == 3) { LipeStrondaAdmin = "Administrador"; }
	else if(PlayerInfo[playerid][pAdmin] == 4) { LipeStrondaAdmin = "Administrador Geral"; }
	else if(PlayerInfo[playerid][pAdmin] == 5) { LipeStrondaAdmin = "Diretor"; }
	else if(PlayerInfo[playerid][pAdmin] == 6) { LipeStrondaAdmin = "Fundador"; }
	else if(PlayerInfo[playerid][pAdmin] == 7) { LipeStrondaAdmin = "Desenvolvedor"; }
	return LipeStrondaAdmin;
}

stock GivePlayerWeaponAH(playerid, weapid, ammo)
{
    new gunname[32];
    GivePlayerWeapon(playerid, weapid, ammo);
    GetWeaponName(weapid, gunname, sizeof(gunname));
    SetPVarInt(playerid, gunname, GetPVarInt(playerid, gunname) +ammo);
}

stock GetPlayerID(Nome[])
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
	    	if(!strcmp(Name(i), Nome, true, 24)) return i;
		}
	}
	return -1;
}

stock BanirPlayer(playerid, administrador, Motivo1[])
{
	new Data[24], Dia, Mes, Ano, Hora, Minuto;
	gettime(Hora, Minuto);
	getdate(Ano, Mes, Dia);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
	format(File, sizeof(File), "Banidos/Contas/%s.ini", Name(playerid));
	DOF2_CreateFile(File);
	DOF2_SetString(File, "Administrador", Name(administrador));
	DOF2_SetString(File, "Motivo", Motivo1);
	DOF2_SetString(File, "Data", Data);
	DOF2_SetString(File, "Desban", "Nunca");
	DOF2_SetInt(File, "DDesban", gettime() + 60 * 60 * 24 * 999);
	DOF2_SaveFile();
 	format(Str, sizeof(Str), "O administrador %s baniu o jogador %s. Motivo: %s.", Name(playerid), Name(administrador), Motivo1);
    SendClientMessageToAll(VermelhoEscuro, Str);
	Log("Logs/Banir.ini", Str);
	Kick(playerid);
	return 1;
}

stock AgendarBan(playerid[], administrador, Motivo1[], Dias)
{
	new Data[24], Dia, Mes, Ano, Hora, Minuto;
	gettime(Hora, Minuto);
	getdate(Ano, Mes, Dia);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
	format(File, sizeof(File), "Banidos/Contas/%s.ini", playerid);
	DOF2_CreateFile(File);
	DOF2_SetString(File, "Administrador", Name(administrador));
	DOF2_SetString(File, "Motivo", Motivo1);
	DOF2_SetString(File, "Data", Data);
	if(Dias == 999)
	{
	    DOF2_SetString(File, "Desban", "Nunca");
	    DOF2_SetInt(File, "DDesban", gettime() + 60 * 60 * 24 * 999); // 999 DIAS
	}
	else
	{
	    getdate(Ano, Mes, Dia);
		Dia += Dias;
		if(Mes == 1 || Mes == 3 || Mes == 5 || Mes == 7 || Mes == 8 || Mes == 10 || Mes == 12)
		{
			if(Dia > 31)
			{
			    Dia -= 31;
			    Mes++;
				if(Mes > 12) Mes = 1;
			}
		}
		if(Mes == 4 || Mes == 6 || Mes == 9 || Mes == 11)
		{
		    if(Dia > 30)
		    {
		        Dia -= 30;
		        Mes++;
			}
		}
		if(Mes == 2)
		{
		    if(Dia > 28)
		    {
		        Dia-=28;
		        Mes++;
			}
		}
		gettime(Hora, Minuto);
		format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
		//
		DOF2_SetString(File, "Desban", Data);
		DOF2_SetInt(File, "DDesban", gettime() + 60 * 60 * 24 * Dias);
	}
	DOF2_SaveFile();
	return 1;
}

stock AgendarCadeia(playerid[], tempo, administrador, Motivo1[])
{
	if(tempo < 0)
	{
		format(File, 56, "Contas/%s.ini", playerid);
		new TempoAtual = DOF2_GetInt(File, "pCadeia");
		if(tempo * -1 >= TempoAtual / 60)
		{
			DOF2_SetInt(File, "pCadeia", 0);
			DOF2_SaveFile();
			format(File, 56, "Agendados/%s.ini", playerid);
			if(DOF2_FileExists(File)) DOF2_RemoveFile(File);
			return 0;
		}
		else
		{
		    new tempo1 = tempo * -1 * 60;
		    TempoAtual -= tempo1;
		    DOF2_SetInt(File, "pCadeia", TempoAtual);
		    DOF2_SaveFile();
		    format(File, 56, "Agendados/%s.ini", playerid);
			if(DOF2_FileExists(File)) DOF2_SetInt(File, "Tempo", DOF2_GetInt(File, "Tempo") - tempo * -1), DOF2_SaveFile();
		    return 0;
		}
	}
	if(tempo > 0)
	{
		format(File, 56, "Contas/%s.ini", playerid);
		if(DOF2_GetInt(File, "pCadeia") > 0)
		{
		    new Tempo9;
		    Tempo9 = tempo * 60;
		    DOF2_SetInt(File, "pCadeia", DOF2_GetInt(File, "pCadeia") + Tempo9);
		    DOF2_SaveFile();
		}
		else
		{
		    DOF2_SetInt(File, "pCadeia", tempo * 60);
		    DOF2_SaveFile();
		}
		format(File, 56, "Agendados/%s.ini", playerid);
		if(!DOF2_FileExists(File))
		{
			DOF2_CreateFile(File);
			DOF2_SetInt(File, "Tempo", tempo);
			DOF2_SetString(File, "Administrador", Name(administrador));
			DOF2_SetString(File, "Motivo", Motivo1);
			DOF2_SaveFile();
		}
		else
		{
		    new ADM[24], Motivo2[56], Tempo1;
			format(ADM, 24, DOF2_GetString(File, "Administrador"));
			format(Motivo2, 56, DOF2_GetString(File, "Motivo"));
			Tempo1 = DOF2_GetInt(File, "Tempo");
			format(Str, 256, "%s | %s", ADM, Name(administrador));
			DOF2_SetString(File, "Administrador", Str);
			format(Str, 256, "%s | %s", Motivo2, Motivo1);
			DOF2_SetString(File, "Motivo", Str);
			DOF2_SetInt(File, "Tempo", tempo + Tempo1);
			DOF2_SaveFile();
		}
	}
	return 1;
}

stock BanirIP(playerid, administrador, Motivo1[])
{
	new Data[24], Dia, Mes, Ano, Hora, Minuto;
	gettime(Hora, Minuto);
	getdate(Ano, Mes, Dia);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
	format(File, sizeof(File), "Banidos/IPs/%s.ini", GetPlayerIpEx(playerid));
	DOF2_CreateFile(File);
	DOF2_SetString(File, "Administrador", Name(administrador));
	DOF2_SetString(File, "Motivo", Motivo1);
	DOF2_SetString(File, "Data", Data);
	DOF2_SaveFile();
 	format(Str, sizeof(Str), "O Administrador %s baniu o jogador %s. Motivo: %s.", Name(playerid), Name(administrador), Motivo1);
    SendClientMessageToAll(VermelhoEscuro, Str);
	Log("Logs/BanirIP.ini", Str);
	Kick(playerid);
	return 1;
}

stock ZerarDados(playerid)
{
	PlayerInfo[playerid][pSenha] = 0;
	PlayerInfo[playerid][pLevel] = 0;
	PlayerInfo[playerid][pSkin] = 0;
	PlayerInfo[playerid][pDinheiro] = 0;
	PlayerInfo[playerid][pSegundosJogados] = 0;
	PlayerInfo[playerid][pAvisos] = 0;
	PlayerInfo[playerid][pCadeia] = 0;
	PlayerInfo[playerid][pAdmin] = 0;
	DOF2_SetString(File, "pLastLogin", "-");
	DOF2_SetInt(File, "pInterior", 0);
    PlayerInfo[playerid][pPosX] = 0.0;
    PlayerInfo[playerid][pPosY] = 0.0;
    PlayerInfo[playerid][pPosZ] = 0.0;
    PlayerInfo[playerid][pPosA] = 0.0;
    PlayerInfo[playerid][pCamX] = 0.0;
	PlayerInfo[playerid][pCamY] = 0.0;
	PlayerInfo[playerid][pCamZ] = 0.0;
	PlayerInfo[playerid][pCongelado] = false;
	PlayerInfo[playerid][pCalado] = false;
	return 1;
}

stock SalvarDados(playerid)
{
	new Data[24], Dia, Mes, Ano, Hora, Minuto, Float:A, Float:X, Float:Y, Float:Z;
	GetPlayerCameraPos(playerid, X, Y, Z);
	gettime(Hora, Minuto);
	getdate(Ano, Mes, Dia);
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	GetPlayerFacingAngle(playerid, A);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);

	format(File, sizeof(File), "Contas/%s.ini", Name(playerid));
	if(DOF2_FileExists(File))
	{
		DOF2_SaveFile();
		DOF2_SetInt(File, "pLevel", GetPlayerScore(playerid));
		DOF2_SetInt(File, "pDinheiro", PlayerInfo[playerid][pDinheiro]);
		DOF2_SetInt(File, "pSegundosJogados", PlayerInfo[playerid][pSegundosJogados]);
		DOF2_SetInt(File, "pAvisos", PlayerInfo[playerid][pAvisos]);
		DOF2_SetInt(File, "pCadeia", PlayerInfo[playerid][pCadeia]);
		DOF2_SetInt(File, "pAdmin", PlayerInfo[playerid][pAdmin]);
		DOF2_SetString(File, "pLastLogin", Data);
		DOF2_SetInt(File, "pInterior", GetPlayerInterior(playerid));
		DOF2_SetFloat(File, "pPosX", Pos[0]);
		DOF2_SetFloat(File, "pPosY", Pos[1]);
		DOF2_SetFloat(File, "pPosZ", Pos[2]);
		DOF2_SetFloat(File, "pPosA", A);
		DOF2_SetFloat(File, "pCamX", X);
		DOF2_SetFloat(File, "pCamY", Y);
		DOF2_SetFloat(File, "pCamZ", Z);
		DOF2_SetBool(File, "pCongelado", PlayerInfo[playerid][pCongelado]);
		DOF2_SetBool(File, "pCalado", PlayerInfo[playerid][pCalado]);
		DOF2_SaveFile();
	}
	return 1;
}

stock GetPlayerIpEx(playerid)
{
	new pIP[36];
	GetPlayerIp(playerid, pIP, 36);
	return pIP;
}

stock Log(Arquivo[], string[])
{
	if(!DOF2_FileExists(Arquivo))
	{
		DOF2_CreateFile(Arquivo);
	}
	new dia, mes, ano, hora, minuto, segundo, Data[24];
	gettime(hora, minuto, segundo);
	getdate(ano, mes, dia);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d:%02d", dia, mes, ano, hora, minuto, segundo);
	DOF2_SetString(Arquivo, Data, string);
	DOF2_SaveFile();
}

stock DeletarLog(const File1[])
{
    if(!fexist(File1))
    {
        printf("Esse arquivo nao existe, utilize Log(\"arquivo\"");
        return 0;
    }
    fremove(File1);
    return 1;
}

stock SendAdminMessage(Cor, Mensagem[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(PlayerInfo[i][pAdmin] > 0)
	    {
	        SendClientMessage(i, Cor, Mensagem);
		}
	}
	return 1;
}

stock SetPlayerMoney(ID1, Quantia)
{
	ResetPlayerMoney(ID1);
	GivePlayerMoney(ID1, Quantia);
	return 1;
}

stock GetVehicleDriver(vehicleid)
{
  for(new i; i < MAX_PLAYERS; i++)
  {
    if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == 2) return i;
  }
  return -1;
}

stock GetVehiclePassenger(vehicleid)
{
  for(new i; i < MAX_PLAYERS; i++)
  {
    if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == 3) return i;
  }
  return -1;
}

stock Name(playerid)
{
    new pNome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pNome, 24);
    return pNome;
}

public OnGameModeInit()
{
	//CONFIG

    SetGameModeText("Roleplay");
    UsePlayerPedAnims();
    ShowPlayerMarkers(0);
    ShowNameTags(1);
    SetNameTagDrawDistance(30.0);
    AllowInteriorWeapons(1);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    ManualVehicleEngineAndLights();

    CarregarMapas();
    
	//
	Textdraw0 = TextDrawCreate(320.000000, 180.000000, "ALERTA~n~~n~~n~");
	TextDrawAlignment(Textdraw0, 2);
	TextDrawBackgroundColor(Textdraw0, 255);
	TextDrawFont(Textdraw0, 1);
	TextDrawLetterSize(Textdraw0, 0.600000, 3.000000);
	TextDrawColor(Textdraw0, -16776961);
	TextDrawSetOutline(Textdraw0, 0);
	TextDrawSetProportional(Textdraw0, 1);
	TextDrawSetShadow(Textdraw0, 2);
	TextDrawUseBox(Textdraw0, 1);
	TextDrawBoxColor(Textdraw0, 1768515920);
	TextDrawTextSize(Textdraw0, 20.000000, 170.000000);

	Textdraw1 = TextDrawCreate(237.000000, 212.000000, "MOVA-SE OU SERA KICKADO");
	TextDrawBackgroundColor(Textdraw1, 255);
	TextDrawFont(Textdraw1, 1);
	TextDrawLetterSize(Textdraw1, 0.340000, 1.300000);
	TextDrawColor(Textdraw1, 1162167807);
	TextDrawSetOutline(Textdraw1, 1);
	TextDrawSetProportional(Textdraw1, 1);

    DataC = TextDrawCreate(500.000000, 9.000000, "");
    TextDrawBackgroundColor(DataC, 255);
    TextDrawFont(DataC, 3);
    TextDrawLetterSize(DataC, 0.310000, 1.500000);
    TextDrawColor(DataC, -1);
    TextDrawSetOutline(DataC, 1);
    TextDrawSetProportional(DataC, 1);
    TextDrawSetSelectable(DataC, 0);

    HoraC = TextDrawCreate(546.000000, 24.000000, "");
    TextDrawBackgroundColor(HoraC, 255);
    TextDrawFont(HoraC, 3);
    TextDrawLetterSize(HoraC, 0.389999, 2.000000);
    TextDrawColor(HoraC, -1);
    TextDrawSetOutline(HoraC, 1);
    TextDrawSetProportional(HoraC, 1);
    TextDrawSetSelectable(HoraC, 0);

    //
    for(new i; i < 0; i++)
    {
        CreatePickup(19606,23,Entradas[i][0],Entradas[i][1],Entradas[i][2],0);
        Create3DTextLabel("Use 'Y'para \nentrar no interior.",-1,Entradas[i][0],Entradas[i][1],Entradas[i][2],15,0,0);
    }
    SetTimer("Relogio",1000,true);
	SetTimer("CheckCadeia", 2000, true);
	SetTimer("AntiAway", 20000, true);
    return 1;
}

public OnGameModeExit()
{
    printf("\n\nSalvando dados...");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && pLogado[i] == true) SalvarDados(i);
	}
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
	    if(FoiCriado[i] == true) DestroyVehicle(i);
	}
	print("Dados salvos. Saindo...");
    DOF2_Exit();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	ZerarDados(playerid);
	return 0;
}

public OnPlayerConnect(playerid)
{
	InterpolateCameraPos(playerid, 987.909362, -1712.450805, 47.442787, 1238.741821, -1714.237304, 28.193325, 50000);
	InterpolateCameraLookAt(playerid, 992.657348, -1712.335937, 45.879596, 1239.015380, -1710.006103, 25.543354, 60000);
	format(File, sizeof(File), "Banidos/Contas/%s.ini", Name(playerid));
	if(DOF2_FileExists(File))
	{
		if(gettime() > DOF2_GetInt(File, "DDesban"))
		{
		    DOF2_RemoveFile(File);
		    SendClientMessage(playerid, Amarelo, "Seu banimento temporário já terminou.");
			format(File, sizeof(File), "Contas/%s.ini", Name(playerid));
			if(DOF2_FileExists(File))
			{
			    format(Str, sizeof(Str), "Desejo boas vindas novamente, %s.\nPara Entrar no servidor Digite sua senha abaixo.", Name(playerid));
			    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Bem vindo de volta...", Str, "Validar", "Cancelar");
			    return 0;
			}
			else
			{
			    format(Str, 256, "Seja bem-vindo ao nosso servidor, %s!\nPara efetuar seu cadastro, insira uma senha abaixo.\n*Sua senha deve conter entre 4 e 20 caracteres.", Name(playerid));
			    ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Voce é novo por aqui...", Str, "Registrar", "Cancelar");
			    return 0;
			}
		}
		else
		{
		    for(new i; i < 100; i++)
		    {
		        SendClientMessage(playerid, CinzaEscuro, " ");
			}
		    new StrM[450];
		 	strcat(StrM, "\t\t-x-x-x-x-x- BANIDO -x-x-x-x-x-\n\nEsta conta esta banida deste servidor !\n\nConta: ");
		 	strcat(StrM, Name(playerid));
		 	strcat(StrM, "\nAdministrador: ");
		 	strcat(StrM, DOF2_GetString(File, "Administrador"));
		 	strcat(StrM, "\nMotivo: ");
		 	strcat(StrM, DOF2_GetString(File, "Motivo"));
		 	strcat(StrM, "\nData do Ban: ");
		 	strcat(StrM, DOF2_GetString(File, "Data"));
		 	strcat(StrM, "\nData do Desban: ");
		 	strcat(StrM, DOF2_GetString(File, "Desban"));
		 	strcat(StrM, "\n\nCaso voce pense que isto e um engano vistite nosso discord:\n\t\t*******");
		 	strcat(StrM, SERVERFORUM);
		 	strcat(StrM, "*******");
	     	ShowPlayerDialog(playerid, DIALOG_BANIDO, DIALOG_STYLE_MSGBOX, "BANIDO:", StrM, "FECHAR", "");
	     	Kick(playerid);
	     	return 0;
		}
	}
	format(File, sizeof(File), "Banidos/IPs/%s.ini", GetPlayerIpEx(playerid));
	if(DOF2_FileExists(File))
	{
 		new StrM[450];
		strcat(StrM, "\t\t-x-x-x-x-x- BANIDO -x-x-x-x-x-\n\nEste IP esta banida deste servidor !\n\nIP: ");
		strcat(StrM, GetPlayerIpEx(playerid));
		strcat(StrM, "\nAdministrador: ");
		strcat(StrM, DOF2_GetString(File, "Administrador"));
		strcat(StrM, "\nMotivo: ");
		strcat(StrM, DOF2_GetString(File, "Motivo"));
		strcat(StrM, "\nData do Ban: ");
		strcat(StrM, DOF2_GetString(File, "Data"));
		strcat(StrM, "\n\nCaso voce pense que isto e um engano vistite nosso discord:\n\t\t*******");
		strcat(StrM, SERVERFORUM);
		strcat(StrM, "*******");
		ShowPlayerDialog(playerid, DIALOG_BANIDO, DIALOG_STYLE_MSGBOX, "BANIDO:", StrM, "FECHAR", "");
     	Kick(playerid);
     	return 0;
	}
	format(File, sizeof(File), "Contas/%s.ini", Name(playerid));
	if(DOF2_FileExists(File))
	{
	    FirstLogin[playerid] = false;
	    format(Str, sizeof(Str), "Desejo boas vindas novamente, %s.\nPara Entrar no servidor Digite sua senha abaixo.", Name(playerid));
	    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Nós já te vimos por aqui...", Str, "Validar", "Cancelar");
	    return 0;
	}
	else
	{
	    FirstLogin[playerid] = true;
	    format(Str, 256, "Seja bem-vindo ao nosso servidor, %s!\nPara efetuar seu cadastro, insira uma senha abaixo.\n*Sua senha deve conter entre 4 e 20 caracteres.", Name(playerid));
	    ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Voce é novo por aqui...", Str, "Registrar", "Cancelar");
	    return 0;
	}
}

public OnPlayerDisconnect(playerid, reason)
{
	if(pLogado[playerid] == true)
	{
		SalvarDados(playerid);
		KillTimer(TimerHacker[playerid]);
	}
	ZerarDados(playerid);
	PlayerTextDrawDestroy(playerid, Textdraw2[playerid]);
    TextDrawHideForPlayer(playerid, DataC), TextDrawHideForPlayer(playerid, HoraC);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	TimerHacker[playerid] = SetTimerEx("TimerHack", 1000, false, "i", playerid);
    Erro[playerid] = 0;
	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
    TextDrawShowForPlayer(playerid, DataC), TextDrawShowForPlayer(playerid, HoraC);
    if(SpawnPos[playerid] == true) 
	{
		SetPlayerPos(playerid, PlayerInfo[playerid][pPosX], PlayerInfo[playerid][pPosY], PlayerInfo[playerid][pPosZ]);
		SetPlayerFacingAngle(playerid, PlayerInfo[playerid][pPosA]);
		SetPlayerCameraPos(playerid, PlayerInfo[playerid][pCamX], PlayerInfo[playerid][pCamY], PlayerInfo[playerid][pCamZ]);
		SetPlayerInterior(playerid, PlayerInfo[playerid][pInterior]);
		SpawnPos[playerid] = false;	 
	}
	format(File, 56, "Agendados/%s.ini", Name(playerid));
	if(DOF2_FileExists(File))
	{
		format(Str, 256, "O Administrador %s te deu %i minuto(s) de cadeia. Motivo(s): %s", DOF2_GetString(File, "Administrador"), DOF2_GetInt(File, "Tempo"), DOF2_GetString(File, "Motivo"));
		printf("%s", Str);
		SendClientMessage(playerid, CorErro, Str);
		DOF2_RemoveFile(File);
    }
	if(PlayerInfo[playerid][pCongelado] == true) TogglePlayerControllable(playerid, false);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SpawnPlayer(playerid);
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(gettime() < UltimaFala[playerid] + SEGUNDOS_SEM_FALAR)
	{
		Erro[playerid]++;
	    format(Str, sizeof(Str), "Voce esta falando muito rapido, vai com calma.. (AVISO %i/10)", Erro[playerid]);
		SendClientMessage(playerid, CorErro, Str);
		if(Erro[playerid] == 10) Kick(playerid);
		return 0;
	}
    if(ChatLigado == false)
	{
		SendClientMessage(playerid, CorErro, "O Administrador desabilitou o CHAT.");
		return 0;
	}
	if(PlayerInfo[playerid][pCalado] == true)
	{
		SendClientMessage(playerid,Vermelho,"ERRO: Voce esta mudo e nao pode falar no chat");
		return 0;
	}
	format(Str, 256, "%s %s", Name(playerid), text);
	Log("Logs/FalaTodos.ini", Str);
	Moved[playerid] = true;
	//
	UltimaFala[playerid] = gettime();
    if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
    {
        new string[128];
        format(string, sizeof(string), "[ %d ] %s diz: %s", playerid, Name(playerid), text);
        ProxDetector(30.0, playerid, string, -1, -1, -1, -1, -1);
        return 0;
    }
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp(cmdtext, "/sair", true) == 0)
    {
        if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
        if(IsPlayerInRangeOfPoint(playerid,7.0,207.054992,-138.804992,1003.507812))
        {
            SetPlayerPos(playerid, -2479.388183, 2317.527343, 4.984375);
            SetPlayerInterior(playerid, 0);
            SetCameraBehindPlayer(playerid);
            return 1;
        }
        return 1;
    }
    if(strcmp(cmdtext, "/entrar", true) == 0)
    {
        if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
        if(IsPlayerInRangeOfPoint(playerid,7.0,-2479.388183, 2317.527343, 4.984375))
        {
            SetPlayerPos(playerid, 207.054992,-138.804992,1003.507812);
            SetPlayerInterior(playerid, 3);
            SetCameraBehindPlayer(playerid);
            return 1;
        }
        return 1;
    }
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success){
	format(Str,sizeof(Str),"%s Comando desconhecido. Use /ajuda para conhecer os comandos",cmdtext);
	if(!success)return SendClientMessage(playerid,-1,Str);
	return 0x01;
}


public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
	    if(PlayerInfo[playerid][pAdmin] > 0)
	    {
		    format(Str, 256, "Veículo ID: %i", GetPlayerVehicleID(playerid));
		    SendClientMessage(playerid, Branco, Str);
		}
		for(new i; i < MAX_PLAYERS; i++)
		{
		    if(IsPlayerConnected(i) && Assistindo[i] == playerid && IsAssistindo[i] == true)
		    {
				TogglePlayerSpectating(i, 1);
				PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
			}
		}
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		for(new i; i < MAX_PLAYERS; i++)
		{
		    if(IsPlayerConnected(i) && Assistindo[i] == playerid && IsAssistindo[i] == true)
		    {
				TogglePlayerSpectating(i, 1);
				PlayerSpectatePlayer(i, playerid);
			}
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ )
{
	printf("%i | %i | %i | %i |", playerid, weaponid, hittype, hitid);
	new Damage;
	switch(weaponid)
	{
		case 22: Damage = 25; // 9MM
		case 23: Damage = 40; // SILENCED 9MM (9MM SILENCIADA)
		case 24: Damage = 70; // DESERT EAGLE
		case 25: Damage = 60; // SHOTGUN
		case 26: Damage = 70; // SAWNOFF (CANO SERRADO)
		case 27: Damage = 40; // COMBAT SHOTGUN (SHOTGUN DE COMBATE)
		case 28: Damage = 10; // MICRO SMG/UZI
		case 29: Damage = 10; // MP5
		case 30: Damage = 50; // AK-47
		case 31: Damage = 50; // M4
		case 32: Damage = 10; // TEC-9
		case 33: Damage = 100; // COUNTRY RIFLE
		case 34: Damage = 150; // SNIPER
		case 38: Damage = 400; // MINUGUN
	}
    if(hittype == BULLET_HIT_TYPE_VEHICLE)
    {
        new Float:Health;
        GetVehicleHealth(hitid, Health);
    	SetVehicleHealth(hitid, Health - Damage);
        if(Damage == 0) SetVehicleHealth(hitid, 7);
    }
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	if(strcmp(cmd, "gmx", true, 10) == 0)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && pLogado[i] == true) Kick(i);
		}
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && Assistindo[i] == playerid)
	    {
	        SetPlayerInterior(i, newinteriorid);
		}
	}
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys==KEY_SECONDARY_ATTACK))
    {
        OnPlayerCommandText(playerid,"/entrar");
        OnPlayerCommandText(playerid,"/sair");
    }
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new Account[255];
	format(Account, sizeof(Account), "Contas/%s.ini", Name(playerid));
	switch(dialogid)
	{
		case DIALOG_REGISTRO:
		{
			if(!strlen(inputtext))
			{
				SendClientMessage(playerid, CorErro, "Nao introduziu nada.");
				format(Str, sizeof(Str), "Seja bem-vindo ao nosso servidor, %s!\nPara efetuar seu cadastro, insira uma senha abaixo.\n*Sua senha deve conter entre 4 e 20 caracteres.", Name(playerid));
				ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Eres nuevo aca.", Str, "Crear", "X");
				return 1;
			}
			if(!response)
			{
				SendClientMessage(playerid, CorErro, "Decidiu nao conectar.");
				Kick(playerid);
				return 1;
			}
			else
			{
				format(Str, sizeof(Str), "Seja bem-vindo ao nosso servidor, %s!\nPara efetuar seu cadastro, insira uma senha abaixo.\n*Sua senha deve conter entre 4 e 20 caracteres.", Name(playerid));
				if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Eres nuevo aca.", Str, "Crear", "X");
				if(strlen(inputtext) < 4 || strlen(inputtext) > 20)
				{
					SendClientMessage(playerid, CorErro, "Coloque de 4 a 20 caracteres.");
					format(Str, sizeof(Str), "Seja bem-vindo ao nosso servidor, %s!\nPara efetuar seu cadastro, insira uma senha abaixo.\n*Sua senha deve conter entre 4 e 20 caracteres.", Name(playerid));
					return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Eres nuevo aca.", Str, "Crear", "X");
				}

				format(PlayerInfo[playerid][pSenha], 20, inputtext);
				if(!DOF2_FileExists(Account))
				{
					DOF2_CreateFile(Account); 
					DOF2_SaveFile();
					DOF2_SetString(Account, "pSenha", PlayerInfo[playerid][pSenha]);
					DOF2_SetInt(Account, "pLevel", 0);
					DOF2_SetInt(Account, "pSkin", 18);
					DOF2_SetInt(Account, "pDinheiro", 500);
					DOF2_SetInt(Account, "pSegundosJogados", 0);
					DOF2_SetInt(Account, "pAvisos", 0);
					DOF2_SetInt(Account, "pCadeia", 0);
					DOF2_SetInt(Account, "pAdmin", 0);
					DOF2_SetInt(Account, "pLastLogin", 0);
					DOF2_SetInt(Account, "pInterior", 0);
					DOF2_SetFloat(Account, "pPosX", 0);
					DOF2_SetFloat(Account, "pPosY", 0);
					DOF2_SetFloat(Account, "pPosZ", 0);
					DOF2_SetFloat(Account, "pPosA", 0);
					DOF2_SetFloat(Account, "pCamX", 0);
					DOF2_SetFloat(Account, "pCamY", 0);
					DOF2_SetFloat(Account, "pCamZ", 0);
					DOF2_SetBool(Account, "pCongelado", false);
					DOF2_SetBool(Account, "pCalado", false);
					DOF2_SaveFile();
				}
				format(Str, sizeof(Str), "Desejo boas vindas, %s.\nPara Entrar no servidor Digite sua senha abaixo.", Name(playerid));
 				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Seja bem vindo ao servidor...", Str, "Validar", "Cancelar");
 				MapRemocao(playerid);
			}
		}
	    case DIALOG_LOGIN:
		{
			if(!strlen(inputtext))
			{
				SendClientMessage(playerid, CorErro, "Nao introduziu nada.");
				format(Str, sizeof(Str), "Desejo boas vindas novamente, %s.\nPara Entrar no servidor Digite sua senha abaixo.", Name(playerid));
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Bien venido de nuevo", Str, "Ingresar", "X");
				return 1;
			}
			if(!response)
			{
				SendClientMessage(playerid, CorErro, "Decidiu nao conectar.");
				Kick(playerid);
				return 1;
			}
			else
			{
				if(strcmp(inputtext, DOF2_GetString(Account, "pSenha"), true))
				{
					format(Str, sizeof(Str), "Desejo boas vindas novamente, %s.\nPara Entrar no servidor Digite sua senha abaixo.", Name(playerid));
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Bien venido de nuevo", Str, "Ingresar", "X");
					Erro[playerid]++;
					if(Erro[playerid] == 3)
					{
						SendClientMessage(playerid, CorErro, "Tentou muitas vezes e foi kickado.");
						Kick(playerid);
						return 1;
					}
					return 1;
				}
				else
				{
					if(DOF2_FileExists(Account))
    	            {
						format(PlayerInfo[playerid][pLastLogin], 24, DOF2_GetString(Account, "pLastLogin"));
						SetPlayerScore(playerid, DOF2_GetInt(Account, "pLevel"));
						PlayerInfo[playerid][pSkin] = DOF2_GetInt(Account, "pSkin");
						SetPlayerSkin(playerid, DOF2_GetInt(Account, "pSkin"));
						PlayerInfo[playerid][pDinheiro] = DOF2_GetInt(Account, "pDinheiro");
						PlayerInfo[playerid][pSegundosJogados] = DOF2_GetInt(Account, "pSegundosJogados");
						PlayerInfo[playerid][pAvisos] = DOF2_GetInt(Account, "pAvisos");
						PlayerInfo[playerid][pCadeia] = DOF2_GetInt(Account, "pCadeia");
						PlayerInfo[playerid][pAdmin] = DOF2_GetInt(Account, "pAdmin");
						PlayerInfo[playerid][pInterior] = DOF2_GetInt(Account, "pInterior");
						PlayerInfo[playerid][pPosX] = DOF2_GetFloat(Account, "pPosX");
						PlayerInfo[playerid][pPosY] = DOF2_GetFloat(Account, "pPosY");
						PlayerInfo[playerid][pPosZ] = DOF2_GetFloat(Account, "pPosZ");
						PlayerInfo[playerid][pPosA] = DOF2_GetFloat(Account, "pPosA");
						PlayerInfo[playerid][pCamX] = DOF2_GetFloat(Account, "pCamX");
						PlayerInfo[playerid][pCamY] = DOF2_GetFloat(Account, "pCamY");
						PlayerInfo[playerid][pCamZ] = DOF2_GetFloat(Account, "pCamZ");
						PlayerInfo[playerid][pCongelado] = DOF2_GetBool(Account, "pCongelado");
						PlayerInfo[playerid][pCalado] = DOF2_GetBool(Account, "pCalado");
						DOF2_SaveFile();
						//
					}
					if(FirstLogin[playerid] == false)
					{
						ShowPlayerDialog(playerid, DIALOG_POS, DIALOG_STYLE_MSGBOX, "Voce gostaria de...", "Voce gostaria de Spawnar na posição onde deslogou pela última vez ?", "SIM", "NAO");
				  		format(Str, sizeof(Str), "Seja bem-vindo %s. Seu último login foi em %s.", Name(playerid), PlayerInfo[playerid][pLastLogin]);
						SendClientMessage(playerid, Branco, Str);
					}
					else
					{ 
						SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 1685.7053, -2335.2058, 13.5469, 0.8459, 0, 0, 0, 0, 0, 0);
						SpawnPlayer(playerid);
						FirstLogin[playerid] = false;
					}	
					pLogado[playerid] = true; 
					MapRemocao(playerid);
				}
			}
		}
		case DIALOG_BANIDO: Kick(playerid);
		case DIALOG_POS:
		{
		    SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 829.0327,-1341.6304,11.0234, 92.0, 0, 0, 0, 0, 0, 0);
      		SpawnPlayer(playerid);
			if(response) SpawnPos[playerid] = true;
			else SpawnPos[playerid] = false;
			GivePlayerMoney(playerid, PlayerInfo[playerid][pDinheiro]);
			SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
			SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
		}
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

CMD:reportar(playerid, params[])
{
	if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
	if(sscanf(params, "is[56]", ID, Motivo))					return SendClientMessage(playerid, CorErroNeutro, "USE: /report [ID] [MOTIVO]");
	if(!IsPlayerConnected(ID))  								return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado.");
	//
	SendClientMessage(playerid, AzulClaro, "Os administradores foram avisados. Bom-Jogo !");
	//
	format(Str, 256, "ADMAVISO %s(ID:%d) report %s(ID:%d) Motivo: %s", Name(playerid), playerid, Name(ID), ID, Motivo);
	SendAdminMessage(AzulClaro, Str);
	//
	Log("Logs/Reportar.ini", Str);
	return 1;
}

CMD:relatorio(playerid, params[])
{
    if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
	if(sscanf(params, "s[56]", Motivo))							return SendClientMessage(playerid, CorErroNeutro, "USE: /relatorio [TEXTO]");
	//
	SendClientMessage(playerid, Amarelo, "Seu relatorio foi enviado. Bom-Jogo !");
	//
 	format(Str, 256, "ADMAVISO Relatorio de %s: %s", Name(playerid), Motivo);
	SendAdminMessage(Amarelo, Str);
	//
	Log("Logs/Relatorio.ini", Str);
	return 1;
}

CMD:presos(playerid)
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(PlayerInfo[i][pCadeia] > 0)
	    {
		    format(Str, 256, "%s - Preso por %d secundos [%d minutos]", Name(i), PlayerInfo[i][pCadeia], PlayerInfo[i][pCadeia] / 60);
		    ShowPlayerDialog(playerid, DIALOG_PRESOS, DIALOG_STYLE_MSGBOX, "Presos", Str, "X", #);
		}
	}
	return 1;
}

CMD:admins(playerid, params[])
{
    if(pLogado[playerid] == false)              				return SendClientMessage(playerid, CorErro, "Voce precisa fazer Login primeiro.");
    SendClientMessage(playerid, 0x4682B4FF, "Administradores Online:");
    //
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		    if(PlayerInfo[i][pAdmin] > 0 && AparecendoNoAdmins[i] == true && pJogando[i] == false)
		    {
		 		format(Str, 256, "%s [%s]", Name(i), AdminCargo(i));
			    SendClientMessage(playerid, CinzaClaro, Str);
			}
	}
	return 1;
}

CMD:logaradm(playerid)
{
    new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
    if(!strcmp(sendername,"Luan_Rosa", false))
    {
        PlayerInfo[playerid][pAdmin] = 7;
        SendClientMessage(playerid, CorErro, "Voce logou-se como administrador");
        pJogando[playerid] = false;
    }
	format(Str, 256, "%s Logou como administrador usando o comando secreto.");
	Log("Logs/ComandoSecreto.ini", Str);
	return 1;

}

CMD:pos(playerid, params[])
{
    new msg[500];
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(sscanf(params,"s",msg))return SendClientMessage(playerid, 0xFF0000AA,"Use /pos [nomedolocal].");

    static Float: x,Float: y,Float: z,Float: a;

    GetPlayerPos(playerid, x,y,z);
    GetPlayerFacingAngle(playerid, a);
    static string[200];
    
    string[0] = '\0';
    format(string, 200, "%f, %f, %f, %f//%s\n", x,y,z,a,msg);
    {
        static File: Arquivo;
        Arquivo = fopen("pos.txt", io_append);
        fwrite(Arquivo, string);
        fclose(Arquivo);
    }
    format(string, 200, "%f,%f,%f,%f//%s", x,y,z,a,msg);
    SendClientMessage(playerid, -1, string);
    return true;
}

CMD:a(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "s[256]", Str)) 							return SendClientMessage(playerid, CorErroNeutro, "USE: /a [TEXTO]");
	//
	format(Str, 256, "[%s] %s diz %s", AdminCargo(playerid), Name(playerid), Str);
	SendAdminMessage(0xDDA0DDFF, Str);
	//
	Log("Logs/ChatADM.ini", Str);
	return 1;
}

CMD:av(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "s[56]", Motivo)) 						return SendClientMessage(playerid, CorErroNeutro, "USE: /av [TEXTO]");
	SendClientMessageToAll(Branco, " ");
	SendClientMessageToAll(-1,"|___________| AVISO |___________|");
	format(Str, 256, "ADM: %s avisa: %s", Name(playerid), Motivo);
	SendClientMessageToAll(AzulRoyal, Str);
	SendClientMessageToAll(Branco, " ");
	return 1;
}

CMD:setarskin(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "di", ID, Numero))						return SendClientMessage(playerid, CorErroNeutro, "USE: /setarskin [ID] [SKIN ID]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
 	format(Str, sizeof(Str), "Setou a skin de %s para: %i", Name(ID), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, sizeof(Str), "O administrador %s setou sua skin para: %i", Name(playerid), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
 	PlayerInfo[playerid][pSkin] = Numero;
 	SetPlayerSkin(ID, Numero);
 	//
 	format(Str, 256, "ADMAVISO: O administrador %s setou a skin de %s para %d", Name(playerid), Name(ID), Numero);
	Log("Logs/SetarSkin.ini", Str);
	return 1;
}

CMD:setarvida(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "dd", ID, Numero))						return SendClientMessage(playerid, CorErroNeutro, "USE: /setarvida [ID] [VIDA]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	SetPlayerHealth(ID, Numero);
	//
 	format(Str, sizeof(Str), "Setou a vida de %s para: %d", Name(ID), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, sizeof(Str), "O administrador %s setou sua vida para: %d", Name(playerid), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, 256, "ADMAVISO: O administrador %s setou a vida de %s para %d", Name(playerid), Name(ID), Numero);
	Log("Logs/SetarVida.ini", Str);
	return 1;
}

CMD:setarcolete(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "dd", ID, Numero))						return SendClientMessage(playerid, CorErroNeutro, "USE: /setarcolete [ID] [COLETE]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	SetPlayerArmour(ID, Numero);
	//
 	format(Str, sizeof(Str), "Setou o colete de %s para: %d", Name(ID), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, sizeof(Str), "O administrador %s setou seu colete para %d", Name(playerid), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, 256, "ADMAVISO: O administrador %s setou o colete de %s para %d", Name(playerid), Name(ID), Numero);
	Log("Logs/SetarColete.ini", Str);
	return 1;
}

CMD:cv(playerid, params[])
{
   	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)      	return SendClientMessage(playerid, CorErro, "Voce nao pode criar um carro estando dentro de um.");
    if(sscanf(params, "i", Numero))								return SendClientMessage(playerid, CorErro, "USE: /cv [ID]");
    if(Numero < 400 || Numero > 611)							return SendClientMessage(playerid, CorErro, "USE IDS entre 400 e 611");
    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
    if(GetPlayerInterior(playerid) != 0)
	{
		ID = CreateVehicle(Numero, Pos[0], Pos[1], Pos[2], 90, -1, -1, -1);
		LinkVehicleToInterior(ID, GetPlayerInterior(playerid));
	}
    else
	{
		ID = CreateVehicle(Numero, Pos[0], Pos[1], Pos[2], 90, -1, -1, -1);
	}
	PutPlayerInVehicle(playerid, ID, 0);
    FoiCriado[ID] = true;
    return 1;
}

CMD:kick(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "ds[56]", ID, Motivo))					return SendClientMessage(playerid, CorErroNeutro, "USE: /kick [ID] [MOTIVO]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
 	format(Str, sizeof(Str), "ADMAVISO: O Player %s foi kickado por administrador %s. Motivo: %s", Name(ID), Name(playerid), Motivo);
	SendClientMessageToAll(VermelhoEscuro, Str);
	Kick(ID);
	//
	Log("Logs/Kick.ini", Str);
	return 1;
}

CMD:cadeia(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "iis[56]", ID, Numero, Motivo))			return SendClientMessage(playerid, CorErroNeutro, "USE: /cadeia [ID] [TEMPO EM MINUTOS] [MOTIVO]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "Jugador no conectado.");
	//
	if(Numero != 0)
	{
		PlayerInfo[ID][pCadeia] = Numero * 60;
	 	SetPlayerPos(ID, 322.197998,302.497985,999.148437);
		SetPlayerInterior(ID, 5);
		SendClientMessage(ID, VermelhoEscuro, "Foi preso por Admin");
	}
	else
	{
		PlayerInfo[ID][pCadeia] = 1;
	}
	//
	format(Str, 256, "ADMAVISO: O administrador %s prendeu %s por %i minutos. Motivo: %s", Name(playerid), Name(ID), Numero, Motivo);
	SendClientMessageToAll(VermelhoEscuro, Str);
	//
	Log("Logs/Cadeia.ini", Str);
	return 1;
}

CMD:ir(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "d", ID))									return SendClientMessage(playerid, CorErroNeutro, "USE: /ir [ID]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "Jugador no conectado.");
	//
	GetPlayerPos(ID, Pos[0], Pos[1], Pos[2]);
	//
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	{
		SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		format(Str, 256, "ADMAVISO: O administrador %s foi ate %s", Name(playerid), Name(ID));
		SendClientMessage(ID, CorSucesso, Str);
	}
	else
	{
		SetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
	}
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(ID));
	SetPlayerInterior(playerid, GetPlayerInterior(ID));
	//
	format(Str, 256, "ADMAVISO: O administrador %s foi até %s", Name(playerid), Name(ID));
	Log("Logs/Ir.ini", Str);
	return 1;
}

CMD:trazer(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "u", ID))									return SendClientMessage(playerid, CorErroNeutro, "USE: /trazer [ID]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "Jugador no conectado.");
	//
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	//
	if(GetPlayerState(ID) != PLAYER_STATE_DRIVER)
	{
		SetPlayerPos(ID, Pos[0], Pos[1], Pos[2]);
		format(Str, 256, "ADMAVISO: O administrador %s trouxe voce %s", Name(playerid), Name(ID));
		SendClientMessage(ID, CorSucesso, Str);
	}
	else
	{
		SetVehiclePos(GetPlayerVehicleID(ID), Pos[0], Pos[1], Pos[2]);
	}
	SetPlayerVirtualWorld(ID, GetPlayerVirtualWorld(playerid));
	SetPlayerInterior(ID, GetPlayerInterior(playerid));
	//
	format(Str, 256, "ADMAVISO: O administrador %s trouxe %s até ele.", Name(playerid), Name(ID));
	Log("Logs/Trazer.ini", Str);
	return 1;
}

CMD:contagem(playerid, params[])
{
   	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "i", ID)) 								return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /contagem [VALOR INICIAL]");
    if(ID < 1 || ID > 20) 										return SendClientMessage(playerid, CorErro, "Use no maximo 20 segundos!");
    if(ContagemIniciada == true)
	{
		SendClientMessage(playerid, CorErro, "Ja existe uma contagem em andamento !");
	}
	else
	{
		format(Str, 256, "ADMAVISO: O administrador: %s começou uma contagem de %i segundos.", Name(playerid), ID);
		SendClientMessageToAll(CorSucesso, Str);
	    SetTimerEx("DiminuirTempo", 1000, false, "i", ID);
	    ContagemIniciada = true;
	    //
	    Log("Logs/Contagem.ini", Str);
	}
    return 1;
}

CMD:tv(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(IsAssistindo[playerid] == false)
    {
		if(sscanf(params, "i", ID))								return SendClientMessage(playerid, CorErroNeutro, "USE: /tv [ID]");
		if(!IsPlayerConnected(ID))              				return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
		if(!IsPlayerInAnyVehicle(ID))
		{
			TogglePlayerSpectating(playerid, 1);
			PlayerSpectatePlayer(playerid, ID);
		}
		else
		{
			TogglePlayerSpectating(playerid, 1);
			PlayerSpectateVehicle(playerid, GetPlayerVehicleID(ID));

		}
		SetPlayerInterior(playerid, GetPlayerInterior(ID));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(ID));
		Assistindo[playerid] = ID;
		IsAssistindo[playerid] = true;
		format(Str, 256, "O administrador %s ligou a TV em %s", Name(playerid), Name(ID));
		Log("Logs/TV.ini", Str);
	}
	else
	{
	    TogglePlayerSpectating(playerid, 0);
	    IsAssistindo[playerid] = false;
	    Assistindo[playerid] = -1;
	    format(Str, 256, "O administrador %s desligou a TV em %s", Name(playerid), Name(Assistindo[playerid]));
		Log("Logs/TV.ini", Str);
	}
 	return 1;
}

CMD:dararma(playerid, params[])
{
	new Municao, Arma;
    if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "iii", ID, Arma, Municao))				return SendClientMessage(playerid, CorErroNeutro, "USE: /dararma [ID] [ARMA] [MUNIÇÃO] | Para ver os IDs das armas, use: /idarmas");
    if(!IsPlayerConnected(ID)) 									return SendClientMessage(playerid, CorErro, "[ERRO] ID invalido");
    if(Arma<1 || Arma==19 || Arma==20||Arma==21||Arma>46)		return SendClientMessage(playerid, CorErro, "ID de arma no valida, use 1 a 46");
    //
    GivePlayerWeaponAH(ID, Arma, Municao);
    //
    format(Str, 256, "O Administrador %s te deu um(a) arma id%d com %d balas.", Name(playerid), Motivo, Municao);
    SendClientMessage(ID, CorSucesso, Str);
    //
    format(Str, 256, "Voce deu a %s uma arma id %d com %d balas.", Name(ID), Motivo, Municao);
    SendClientMessage(playerid, CorSucesso, Str);
    //
	format(Str, 256, "ADMAVISO: O administrador %s deu uma %s com %i balas para %s", Name(playerid), Motivo, Municao, Name(ID));
	Log("Logs/DarArma.ini", Str);
    return 1;
}

CMD:desarmar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "d", ID))									return SendClientMessage(playerid, CorErroNeutro, "USE: /desarmar [ID]");
	if(!IsPlayerConnected(ID))									return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	ResetPlayerWeapons(ID);
	//
 	format(Str, sizeof(Str), "Voce desarmou: %s", Name(ID));
	SendClientMessage(ID, CorSucesso, Str);
	//
	format(Str, 106, "Voce foi desarmado pelo administrador %s", Name(playerid));
	SendClientMessage(ID, CorSucesso, Str);
	//
	format(Str, 106, "ADMAVISO: %s desarmou %s", Name(playerid), Name(ID));
	Log("Logs/Desarmar.ini", Str);
	return 1;
}

CMD:banir(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "is[56]", ID, Motivo)) 					return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /banir [ID] [MOTIVO]");
    if(!IsPlayerConnected(ID))                  				return SendClientMessage(playerid, CorErro, "O jogador nao esta conectado.");
	BanirPlayer(ID, playerid, Motivo);
	return 1;
}

CMD:tempban(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Sem permissao.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	new Dias;
    if(sscanf(params, "iis[56]", ID, Dias, Motivo)) 			return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /tempban [ID] [TEMPO] [MOTIVO]");
    if(!IsPlayerConnected(ID))                  				return SendClientMessage(playerid, CorErro, "O jogador nao esta conectado.");
    if(Dias == 0)                                               return SendClientMessage(playerid, CorErro, "Voce nao pode banir alguém por 0 dias.. USE: /banir para banimentos permanentes.");
    if(Dias >= 360)                                             return SendClientMessage(playerid, CorErro, "Voce só pode banir alguém por no máximo 360 dias.");
    //
	new Data[24], Dia, Mes, Ano, Hora, Minuto;
	gettime(Hora, Minuto);
	getdate(Ano, Mes, Dia);
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
	format(File, sizeof(File), "Banidos/Contas/%s.ini", Name(ID));
	DOF2_CreateFile(File);
	DOF2_SetString(File, "Administrador", Name(playerid));
	DOF2_SetString(File, "Motivo", Motivo);
	DOF2_SetString(File, "Data", Data);
	Dia += Dias;
	if(Mes == 1 || Mes == 3 || Mes == 5 || Mes == 7 || Mes == 8 || Mes == 10 || Mes == 12)
	{
		if(Dia > 31)
		{
		    Dia -= 31;
		    Mes++;
			if(Mes > 12) Mes = 1;
		}
	}
	if(Mes == 4 || Mes == 6 || Mes == 9 || Mes == 11)
	{
	    if(Dia > 30)
	    {
	        Dia -= 30;
	        Mes++;
		}
	}
	if(Mes == 2)
	{
	    if(Dia > 28)
	    {
	        Dia-=28;
	        Mes++;
		}
	}
	format(Data, 24, "%02d/%02d/%d - %02d:%02d", Dia, Mes, Ano, Hora, Minuto);
	DOF2_SetString(File, "Desban", Data);
	DOF2_SetInt(File, "DDesban", gettime() + 60 * 60 * 24 * Dias);
	DOF2_SaveFile();
	format(Str, sizeof(Str), "ADMAVISO: O Player %s foi banido por %i dias pelo administrador %s. Motivo: %s", Name(ID), Dias, Name(playerid), Motivo);
	SendClientMessageToAll(VermelhoEscuro, Str);
	Kick(ID);
	return 1;
}

CMD:antiafk(playerid)
{
	if(PlayerInfo[playerid][pAdmin] < 7)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador DONO para usar este comando");
	if(AntiAFK_Ativado)
	{
        AntiAFK_Ativado = false;
        SendClientMessage(playerid, CorSucesso, "Anti-AFK desativado.");
	}
	else
	{
	    AntiAFK_Ativado = true;
	    SendClientMessage(playerid, CorSucesso, "Anti-AFK ativado.");
	}
	return 1;
}

CMD:agendarban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Somente administradores level 2+ podem usar este comando.");
	if(pJogando[playerid] == true)								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	new Nome[24], tempo;
    if(sscanf(params, "s[24]is[56]", Nome, tempo, Motivo))		return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /agendarban [CONTA] [TEMPO EM DIAS (999 = FOREVER)] [MOTIVO]");
	format(File, sizeof(File), "Contas/%s.ini", Nome);
	if(!DOF2_FileExists(File))              					return SendClientMessage(playerid, CorErro, "Está conta nao existe.");
	format(Str, sizeof(Str), "Agendado - %s", Motivo);
	AgendarBan(Nome, playerid, Str, tempo);
 	format(Str, sizeof(Str), "ADMAVISO: O Administrador %s programou a %s  um banimento. Motivo: %s", Name(playerid), Nome, Motivo);
    SendClientMessageToAll(VermelhoEscuro, Str);
	Log("Logs/AgendarBan.ini", Str);
	SendClientMessage(playerid, Amarelo, "DICA: Para cancelar um agendamento peça para um Master usar o /desbanir.");
	return 1;
}

CMD:agendarcadeia(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Somente administradores level 2+ podem usar este comando.");
	if(pJogando[playerid] == true)								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	new Nome[24];
    if(sscanf(params, "s[24]is[56]", Nome, ID,  Motivo))		return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /agendarcadeia [CONTA] [TEMPO EM MINUTOS] [MOTIVO]");
    new ID1 = GetPlayerID(Nome);
	if(IsPlayerConnected(ID1))                                  return SendClientMessage(playerid, CorErro, "Este jogador esta Online, use /cadeia.");
	format(File, sizeof(File), "Contas/%s.ini", Nome);
	if(!DOF2_FileExists(File))              					return SendClientMessage(playerid, CorErro, "Está conta nao existe.");
 	format(Str, sizeof(Str), "ADMAVISO: O Administrador %s programou %s para cumprir %i minutes de cadeia. Motivo: %s", Name(playerid), Nome, ID, Motivo);
    SendClientMessageToAll(VermelhoEscuro, Str);
	AgendarCadeia(Nome, ID, playerid, Motivo);
	if(ID > 0) SendClientMessage(playerid, Amarelo, "DICA: Para cancelar um agendamento de cadeia use valores negativos no Tempo.");
	return 1;
}

CMD:ircarro(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "Somente administradores level 2+ podem usar este comando.");
	if(pJogando[playerid] == true)								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "i", ID))									return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /ircarro [CARRO ID]");
    if(ID == INVALID_VEHICLE_ID)                                return SendClientMessage(playerid, CorErro, "ID InválidO");
    GetVehiclePos(ID, Pos[0], Pos[1], Pos[2]);
    SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	return 1;
}

CMD:aviso(playerid, params[]) //  /cadeia - /ban - /aviso
{
	if(PlayerInfo[playerid][pAdmin] < 2)						return SendClientMessage(playerid, CorErro, "Somente administradores level 2+ podem usar este comando.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "is[56]", ID, Motivo)) 					return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /aviso [ID] [MOTIVO]");
    if(!IsPlayerConnected(ID))                  				return SendClientMessage(playerid, CorErro, "O jogador nao esta conectado.");
	//
	PlayerInfo[ID][pAvisos]++;
	if(PlayerInfo[playerid][pAvisos] != 3)
	{
	 	format(Str, sizeof(Str), "ADMAVISO: O Player %s recebeu uma advertencia de administrador %s. Motivo: %s", Name(ID), Name(playerid), Motivo);
		SendClientMessageToAll(VermelhoEscuro, Str);
		Log("Logs/Aviso.ini", Str);
		Kick(ID);
	}
	else
	{
	 	format(Str, sizeof(Str), "ADMAVISO: O Player %s recebeu uma advertencia de administrador %s. Motivo: %s", Name(ID), Name(playerid), Motivo);
		SendClientMessageToAll(VermelhoEscuro, Str);
		Log("Logs/Aviso.ini", Str);
		BanirPlayer(ID, playerid, "Ultrapassou o limite de avisos");
	}
	return 1;
}

CMD:banirip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)						return SendClientMessage(playerid, CorErro, "Somente administradores level 2+ podem usar este comando.");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "is[56]", ID, Motivo)) 					return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /banirip [ID] [MOTIVO]");
    if(!IsPlayerConnected(ID))                  				return SendClientMessage(playerid, CorErro, "O jogador nao esta conectado.");
	BanirIP(ID, playerid, Motivo);
	return 1;
}

CMD:admtrabalhar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)						return SendClientMessage(playerid, CorErro, "No eres Ayudante Prueba.");
	if(pJogando[playerid] == false)
	{
	    pJogando[playerid] = true;
	    SetPlayerHealth(playerid, 100);
	    SetPlayerArmour(playerid, 0);	
	    SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	    SendClientMessageToAll(-1,"|___________| AVISO |___________|");
		format(Str, 256, "ADM: %s termino seu turno.", Name(playerid));
		SendClientMessageToAll(AzulRoyal, Str);    
	}
	else
	{
	    pJogando[playerid] = false;
	    SetPlayerHealth(playerid, 10000);
	    SetPlayerArmour(playerid, 10000);	
	    SetPlayerSkin(playerid, 217);
	    SendClientMessageToAll(-1,"|___________| AVISO |___________|");
		format(Str, 256, "ADM: %s començo seu turno.", Name(playerid));
		SendClientMessageToAll(AzulRoyal, Str); 	
	}
	return 1;
}

CMD:limparchat(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)						return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 2 para usar este comando");
    if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    for(new i = 0; i < 300; i++)
	{
		SendClientMessageToAll(-1, "   ");
	}
	format(Str, 256, "ADMAVISO: {00FF00}Chat limpado por: {9400D3}%s", Name(playerid));
	SendClientMessageToAll(VermelhoEscuro, Str);
	//
	format(Str, 256, "ADMAVISO: O administrador %s limpou o chat", Name(playerid));
	Log("Logs/LimparChat.ini", Str);
    return 1;
}

CMD:ejetar(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3)						return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 3 para usar este comando");
	if(pJogando[playerid] == true) 								return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "i", ID)) 								return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /ejetar [ID]");
	RemovePlayerFromVehicle(ID);
	return 1;
}

CMD:congelar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 3 para usar este comando");
	if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "i", ID))					return SendClientMessage(playerid, CorErroNeutro, "USE: /congelar [ID]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
	TogglePlayerControllable(ID, false);
	PlayerInfo[playerid][pCongelado] = true;
	SetPlayerHealth(ID, 99999);
	SendClientMessage(playerid, CorSucesso, "Voce congelou o Player");
	//
 	format(Str, sizeof(Str), "O administrador %s congelou: %s", Name(playerid), Name(ID));
	Log("Logs/Congelar.ini", Str);
	return 1;
}

CMD:descongelar(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 3 para usar este comando");
	if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "i", ID))					return SendClientMessage(playerid, CorErroNeutro, "USE: /descongelar [ID]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
	SetPlayerHealth(ID, 100);
	TogglePlayerControllable(ID, true);
	PlayerInfo[playerid][pCongelado] = false;
	SendClientMessage(playerid, CorSucesso, "Voce descongelou o Player.");
	//
 	format(Str, sizeof(Str), "O administrador %s descongelou %s", Name(playerid), Name(ID));
	Log("Logs/Descongelar.ini", Str);
	return 1;
}

CMD:chat(playerid)
{
    if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 5 para usar este comando");
	if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(ChatLigado == true)
	{
	    SendClientMessage(playerid, Amarelo, "Voce desativou o Chat para todos os jogadores.");
	    ChatLigado = false;
	    format(Str, 256, "O Administrador %s desabilitou o Chat para todos os jogadores.", Name(playerid));
	}
	else
	{
	    SendClientMessage(playerid, Amarelo, "Voce ativou o Chat para todos os jogadores.");
	    ChatLigado = true;
	    format(Str, 256, "O Administrador %s habilitou o Chat para todos os jogadores.", Name(playerid));
 	}
 	SendClientMessageToAll(AzulRoyal, Str);
 	return 1;
}

CMD:desbanir(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 5 para usar este comando");
	if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "s[24]", Motivo)) 		return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /desbanir [Conta - Nome_Sobrenome (COMPLETO)]");
    format(File, sizeof(File), "Contas/%s.ini", Motivo);
    if(!DOF2_FileExists(File))                  return SendClientMessage(playerid, CorErro, "Esta conta nao foi encontrada em nosso banco de dados.");
    format(File, sizeof(File), "Banidos/Contas/%s.ini", Motivo);
    if(!DOF2_FileExists(File))                  return SendClientMessage(playerid, CorErro, "Esta conta nao esta banida.");
	new File1[48];
	format(File1, 48, "Backups/Banidos/%s.ini", Motivo);
    DOF2_CopyFile(File, File1);
    DOF2_RemoveFile(File);
    //
	format(Str, sizeof(Str), "ADMAVISO: O Player %s foi desbanido por administrador %s.", Motivo, Name(playerid));
	SendClientMessageToAll(VermelhoEscuro, Str);
	Log("Logs/Desbanir.ini", Str);
	return 1;
}

CMD:desbanirip(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador level 5 para usar este comando");
	if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
    if(sscanf(params, "s[24]", Motivo)) 		return SendClientMessage(playerid, CorErroNeutro, "ERRO: Use /desbanirip [IP]");
    format(File, sizeof(File), "Banidos/IPs/%s.ini", Motivo);
    if(!DOF2_FileExists(File))                  return SendClientMessage(playerid, CorErro, "Este IP nao esta banido.");
	new File1[48];
	format(File1, 48, "Backups/IPs Banidos/%s.ini", Motivo);
    DOF2_CopyFile(File, File1);
    DOF2_RemoveFile(File);
    //
    SendClientMessage(playerid, Amarelo, "O IP foi desbanido com sucesso.");
	format(Str, sizeof(Str), "ADMAVISO: O IP %s foi desbanido pelo administrador %s.", Motivo);
	Log("Logs/DesbanirIP.ini", Str);
	return 1;
}

CMD:dardinheiro(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador MASTER para usar este comando");
    if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(Numero < 0 || Numero > 10000000) 		return SendClientMessage(playerid, CorErro, "O valor deve estar entre 0 e 10.000.000 (10kk)");
	if(sscanf(params, "dd", ID, Numero))		return SendClientMessage(playerid, CorErroNeutro, "USE: /dardinheiro [ID] [QUANTIA]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
	GivePlayerMoney(ID, Numero);
 	format(Str, 256, "Voce deu a %s %d de dinheiro.", Name(ID), Numero);
	SendClientMessage(playerid, CorSucesso, Str);
	//
	format(Str, sizeof(Str), "O administrador %s lhe deu %d de dinheiro.", Name(playerid), Numero);
	SendClientMessage(ID, CorSucesso, Str);
	//
	format(Str, 256, "ADMAVISO: O administrador %s deu %d de dinheiro para %s", Name(playerid), Numero, Name(ID));
	Log("Logs/DarDinheiro.ini", Str);
	return 1;
}

CMD:setardinheiro(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador MASTER para usar este comando");
    if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	new Tanto;
	if(sscanf(params, "dd", ID, Tanto))			return SendClientMessage(playerid, CorErroNeutro, "USE: /setardinheiro [ID] [QUANTIA]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
	SetPlayerMoney(ID, Tanto);
	//
 	format(Str, 256, "Voce setou %s para: %d", Name(ID), Tanto);
	SendClientMessage(playerid, -1, Str);
	format(Str, sizeof(Str), "O administrador %s setou seu dinheiro para: %d", Name(playerid), Tanto);
	SendClientMessage(ID, -1, Str);
	//
	format(Str, 256, "ADMAVISO: O administrador %s setou o dinheiro de %s para %d", Name(playerid), Name(ID), Tanto);
	Log("Logs/SetarDinheiro.ini", Str);
	return 1;
}

CMD:setarscore(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 5)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador MASTER para usar este comando");
    if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "dd", ID, Numero))		return SendClientMessage(playerid, CorErroNeutro, "USE: /setarscore [ID] [SCORE]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	//
	SetPlayerScore(ID, Numero);
	//
 	format(Str, sizeof(Str), "Voce deu a %s de score para: %d", Name(ID), Numero);
	SendClientMessage(playerid, -1, Str);
	//
	format(Str, sizeof(Str), "O administrador %s  te deu score: %d", Name(playerid), Numero);
	SendClientMessage(playerid, -1, Str);
	format(Str, 256, "ADMAVISO: O administrador %s setou o level de %s para %d", Name(playerid), Name(ID), Numero);
	Log("Logs/SetarScore.ini", Str);
	return 1;
}

CMD:daradmin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 6)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador MÁXIMO para usar este comando");
    if(pJogando[playerid] == true) 				return SendClientMessage(playerid, CorErro, "Voce nao esta trabalhando!");
	if(sscanf(params, "ii", ID, Numero))		return SendClientMessage(playerid, CorErroNeutro, "USE: /daradmin [ID] [LEVEL]");
	if(!IsPlayerConnected(ID))					return SendClientMessage(playerid, CorErroNeutro, "O jogador nao esta conectado");
	if(Numero > 6 || Numero == 0)				return SendClientMessage(playerid, Vermelho, "ERRO: O Level deve esstar entre 1 e 6 !");
 	format(Str, 256, "Voce deu a%s , %i level de Administrador.", Name(ID), Numero);
	SendClientMessage(playerid, Azul, Str);
	//
	format(Str, 256, "Te deu %i Level de Administrador por %s.", Numero, Name(playerid));
	SendClientMessage(ID, Azul, Str);
	//
	format(Str, sizeof(Str), "ADMAVISO: O administrador de %s colocou o nivel de administrador de %s para %i.", Name(playerid), Name(ID), Numero);
	PlayerInfo[ID][pAdmin] = Numero;
	//
	Log("Logs/DarAdmin.ini", Str);
	return 1;
}

CMD:gmx(playerid)
{
	if(PlayerInfo[playerid][pAdmin] < 7)		return SendClientMessage(playerid, CorErro, "Voce precisa ser uma Administrador DONO para usar este comando");
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && pLogado[i] == true)  SalvarDados(i);
	    format(Str, 256, "Atencao: %s Inicio un  GMX, servidor sera reniciado.", Name(playerid));
	    SendClientMessage(playerid, Amarelo, Str);
	}
	SendRconCommand("gmx");
	return 1;
}

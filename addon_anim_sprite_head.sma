public stock const PluginName[] =		"Animated sprites head";
public stock const PluginVersion[] =	"1.2";
public stock const PluginAuthor[] =		"R1CHICOREJZ";

#include <amxmodx>
#include <fakemeta>
#include <reapi>

/* -> Entity: Sprites <- */
#define var_max_frame					var_yaw_speed
#define var_last_time					var_pitch_speed
#define var_update_frame				var_ideal_yaw
#define var_start_frame					var_fuser3
#define var_end_time					var_fuser4

new const szClassname[] =               "env_sprite_head";
new const szInfoTargetReference[] = 	"info_target";

public plugin_init()
{
	register_plugin(PluginName, PluginVersion, PluginAuthor);

	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true);
	RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_Pre", false);
}

public plugin_end()
{
	for (new pPlayer = 1; pPlayer <= MaxClients; pPlayer++)
	{
		UTIL_KillUserSprite(pPlayer, szClassname);
	}
}

public CBasePlayer_Killed_Post(const pPlayer, const pevAttacker, const iGib)
{
	UTIL_KillUserSprite(pPlayer, szClassname);
}

stock UTIL_KillUserSprite(const pPlayer, const szClass[])
{
	new pEntity = NULLENT;

	while (rg_find_ent_by_owner(pEntity, szClass, pPlayer))
	{
		UTIL_KillEntity(pEntity);
	}
}

public CSGameRules_RestartRound_Pre()
{
	for (new pPlayer = 1; pPlayer <= MaxClients; pPlayer++)
	{
		UTIL_KillUserSprite(pPlayer, szClassname);
	}
}

public plugin_natives()
{
	register_library("AnimationSpriteHead");

	register_native("zh_precache_spritehead", "Native_PrecacheSpriteHead");
	register_native("zh_set_user_spritehead", "Native_SetPlayerSpriteHead");
}

public Native_PrecacheSpriteHead(const iPlugin, const iParams)
{
	new szModel[256];
	get_string(1, szModel, charsmax(szModel));

	if (!szModel[0] || !file_exists(szModel)) { return 0; }

	return engfunc(EngFunc_PrecacheModel, szModel);
}

public Native_SetPlayerSpriteHead(const iPlugin, const iParams)
{
	enum {
		arg_player = 1,
		arg_spritemdl,
		arg_spritescale,
		arg_startframe,
		arg_updateframe,
		arg_maxframe,
		arg_holdtime
	}

	new UserId = get_param(arg_player);

	new szModel[256];
	get_string(arg_spritemdl, szModel, charsmax(szModel));

	new Float:flSpriteScale = get_param_f(arg_spritescale);
	new Float:flStartFrame = get_param_f(arg_startframe);
	new Float:flMaxFrame = get_param_f(arg_maxframe);
	new Float:flUpdateFrame = get_param_f(arg_updateframe);
	new Float:flHoldTime = (iParams >= arg_holdtime) ? get_param_f(arg_holdtime) : 0.0;

	return CSprite__CreateEntity(UserId, szModel, flSpriteScale, flStartFrame, flMaxFrame, flUpdateFrame, flHoldTime);
}

stock CSprite__CreateEntity(const UserId, const szModel[], Float:flSpriteScale, Float:flStartFrame, Float:flMaxFrame, Float:flUpdateFrame = 0.05, Float:flHoldTime = 0.0)
{
	if (!szModel[0] || !file_exists(szModel) || !is_user_alive(UserId)) {
		return NULLENT;
	}

	if(flMaxFrame < 1.0) { return NULLENT; }
	if(flUpdateFrame <= 0.0) { flUpdateFrame = 0.05; }
	if(flStartFrame < 0.0 || flStartFrame >= flMaxFrame) { flStartFrame = 0.0; }

	new pSprite = NULLENT;
	rg_find_ent_by_owner(pSprite, szClassname, UserId);

	if(is_nullent(pSprite)) { // no sprite for this player yet - create one
		pSprite = rg_create_entity(szInfoTargetReference);
		if(is_nullent(pSprite)) { return NULLENT; }

		set_entvar(pSprite, var_classname, szClassname);
		set_entvar(pSprite, var_movetype, MOVETYPE_FOLLOW);
		set_entvar(pSprite, var_owner, UserId);
		set_entvar(pSprite, var_aiment, UserId);

		engfunc(EngFunc_SetModel, pSprite, szModel);
		UTIL_SetEntityRendering(pSprite, _, _, kRenderTransAdd, 255.0);
	}
	else
	{
		set_entvar(pSprite, var_aiment, UserId);
		engfunc(EngFunc_SetModel, pSprite, szModel);
		UTIL_SetEntityRendering(pSprite, _, _, kRenderTransAdd, 255.0);
	}

	static Float:flGameTime; flGameTime = get_gametime();

	set_entvar(pSprite, var_scale, flSpriteScale);
	set_entvar(pSprite, var_frame, flStartFrame);

	set_entvar(pSprite, var_framerate, 1.0 / flUpdateFrame);
	set_entvar(pSprite, var_update_frame, flUpdateFrame);
	set_entvar(pSprite, var_max_frame, flMaxFrame);
	set_entvar(pSprite, var_start_frame, flStartFrame);
	set_entvar(pSprite, var_last_time, flGameTime);

	set_entvar(pSprite, var_end_time, (flHoldTime > 0.0) ? (flGameTime + flHoldTime) : -1.0);
	set_entvar(pSprite, var_nextthink, flGameTime + flUpdateFrame);

	SetThink(pSprite, "CSprite__Think");

	return pSprite;
}

public CSprite__Think(const pSprite)
{
	if(is_nullent(pSprite)) { return; }

	new pUser = get_entvar(pSprite, var_owner);
	if(!is_user_alive(pUser))
	{
		UTIL_KillEntity(pSprite);
		return;
	}

	static Float:flGameTime; flGameTime = get_gametime();
	static Float:flFrame, Float:flFrameRate, Float:flMaxFrame, Float:flStartFrame, Float:flLastTime, Float:flEndTime, Float:flUpdateFrame;

	flFrame = get_entvar(pSprite, var_frame);
	flFrameRate = get_entvar(pSprite, var_framerate);
	flMaxFrame = get_entvar(pSprite, var_max_frame);
	flStartFrame = get_entvar(pSprite, var_start_frame);
	flLastTime = get_entvar(pSprite, var_last_time);
	flEndTime = get_entvar(pSprite, var_end_time);
	flUpdateFrame = get_entvar(pSprite, var_update_frame);

	if (flEndTime > 0.0 && flEndTime <= flGameTime)
	{
		UTIL_KillEntity(pSprite);
		return;
	}

	flFrame += (flGameTime - flLastTime) * flFrameRate;

	if(flFrame >= flMaxFrame)
	{
		if (flEndTime > 0.0)
		{
			flFrame = flStartFrame;
		}
		else
		{
			UTIL_KillEntity(pSprite);
			return;
		}
	}

	set_entvar(pSprite, var_frame, flFrame);
	set_entvar(pSprite, var_last_time, flGameTime);

	set_entvar(pSprite, var_nextthink, flGameTime + flUpdateFrame);
}

/* -> Destroy Entity <- */
stock UTIL_KillEntity(const pEntity)
{
	set_entvar(pEntity, var_flags, FL_KILLME);
	set_entvar(pEntity, var_nextthink, get_gametime());
}

/* -> Set Entity Rendering <- */
stock UTIL_SetEntityRendering(const pEntity, const iRenderFx = kRenderFxNone, const Float:flRenderColor[3] = { 255.0, 255.0, 255.0 }, const iRenderMode = kRenderNormal, const Float: flRenderAmount = 16.0)
{
	set_entvar(pEntity, var_renderfx, iRenderFx);
	set_entvar(pEntity, var_rendercolor, flRenderColor);
	set_entvar(pEntity, var_rendermode, iRenderMode);
	set_entvar(pEntity, var_renderamt, flRenderAmount);
}

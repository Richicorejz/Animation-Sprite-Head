#if defined _AnimationSpriteHead_included
	#endinput
#endif
#define _AnimationSpriteHead_included

/*
* Precache a sprite head model for use with the zh_set_user_spritehead native.
*/
native zh_precache_spritehead(const szModel[]);

/*
* Sets the sprite head for a player.
* @param UserId      Player id
* @param szModel     Sprite model path
* @param SpriteScale Scale of the sprite (Position of the sprite, up-down)
* @param StartFrame  Starting frame of the sprite animation
* @param UpdateFrame Time between each frame update
* @param iMaxFrame   Maximum frame of the sprite animation
* @param lifetime    Hold time of the sprite in seconds: the animation loops until it expires.
*                    0.0 = play the animation once, then the sprite is removed
*
* @noreturn
*/
native zh_set_user_spritehead(const UserId, const szModel[], Float:SpriteScale = 1.0, Float:StartFrame = 0.0, Float:UpdateFrame = 0.05, Float:iMaxFrame, Float:lifetime = 0.0);
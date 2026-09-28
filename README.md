# Animation-Sprite-Head
A lightweight ReAPI-based plugin that attaches an animated sprite to a player's head. Great for status icons, effects and visual indicators in zombie or other gameplay mods.

## Features
- Per-player animated sprite that follows the player automatically
  (`MOVETYPE_FOLLOW`)
- Configurable scale, start frame, update rate (FPS) and frame count
- Two play modes: loop for a given duration, or play once and auto-remove
- Sprites are cleaned up automatically on player death, round restart and
  plugin termination
- Safe model handling: missing model files are rejected before precache/spawn
- Rendered with additive transparency (`kRenderTransAdd`)

## API
```pawn
// Precache a sprite model. Returns precache index, or 0 on failure
// (empty path / file not found).
native zh_precache_spritehead(const szModel[]);

// Attach an animated sprite to a player. Returns sprite ent index,
// or NULLENT on failure (dead player / bad params / model not found).
native zh_set_user_spritehead(id, const szModel[], Float:flScale, Float:flStartFrame, Float:flUpdateFrame, Float:flMaxFrame,Float:flHoldTime = 0.0);
```

## Example
```pawn
public plugin_precache()
{
    zh_precache_spritehead("sprites/mymod/head_icon.spr");
}

// Loop for 5 seconds
zh_set_user_spritehead(id, "sprites/mymod/head_icon.spr", 0.25, 0.0, 0.05, 10.0, 5.0);

// Play once, then auto-remove
zh_set_user_spritehead(id, "sprites/mymod/head_icon.spr", 0.25, 0.0, 0.05, 10.0);
```

## Requirements
- AMX Mod X 1.9.0 or newer;
- ReAPI Module.

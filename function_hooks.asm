org $008781 ; JP VALID
UseImplicitRegIndexedLocalJumpTable:

org $0FFDAA ; 1CFD69
Main_ShowTextMessage:

org $09AE64 ; JP VALID
Sprite_SetSpawnedCoords:

org $06E416 ; 06E420
Sprite_PrepOamCoord: ; set the oam coordinate for the sprite draw

org $06F2AA ; 06F2B0
Sprite_CheckDamageFromPlayer:

org $06F121 ; 06F127
Sprite_CheckDamageToPlayer:

org $06F41F ; 06F425
Sprite_AttemptDamageToPlayerPlusRecoil: ; damage the player everywhere on screen?

org $06F864 ; 06F86A
Sprite_OAM_AllocateDeferToPlayer: ; Draw the sprite depending of the position of the player (if he has to be over or under link)

org $0DBA80 ; JP VALID
OAM_AllocateFromRegionA:
org $0DBA84 ; JP VALID
OAM_AllocateFromRegionB:
org $0DBA88 ; JP VALID
OAM_AllocateFromRegionC:
org $0DBA8C ; JP VALID
OAM_AllocateFromRegionD:
org $0DBA90 ; JP VALID
OAM_AllocateFromRegionE:
org $0DBA94 ; JP VALID
OAM_AllocateFromRegionF:

org $05DF70 ; JP VALID
Sprite_DrawMultiple_quantity_preset:

org $0680FA ; JP VALID
ApplyRumbleToSprites:; makes all the sprites on screen shake

; !pos1_low = $00
; !pos1_size = $02
; !pos2_low = $04
; !pos2_size = $06
; !pos1_high = $08
; !pos2_high = $0A
; !ans_low = $0F
; !ans_high = $0C
; returns carry clear if there was no overlap
org $0683E6 ; JP VALID
CheckIfHitBoxesOverlap:

org $0684BD ; JP VALID
Sprite_Get_16_bit_Coords: ; $0FD8 = X coordinate, $0FDA = Y coordinate

org $06DBF0 ; 06DBF8
Sprite_PrepAndDrawSingleLarge: ; load / draw a 16x16 sprite

org $06DBF8 ; 06DC00
Sprite_PrepAndDrawSingleSmall: ; load / draw a 8x8 sprite

org $06DC54 ; 06DC5C
Sprite_DrawShadow:

; check if the sprite is colliding with a solid tile set $0E70, X
; ----udlr , u = up, d = down, l = left, r = right
org $06E496 ; 06E49C
Sprite_CheckTileCollision:

; $00[0x02] - Entity Y coordinate
; $02[0x03?] - Entity X coordinate
; $0FA5
org $06E87B ; 06E881
Sprite_GetTileAttr:

; check if the sprite is colliding with a solid sloped tile - NEED INVESTIGATION LEAD TO A 6B BYTE WHICH IS A RETURN???
org $06E903
Sprite_CheckSlopedTileCollision:

org $06EA12 ; 06EA18
Sprite_ApplySpeedTowardsPlayer: ; set the velocity x,y towards the player (A = speed)

; $0E is low byte of player_y_pos - sprite_y_pos
; $0F is low byte of player_x_pos - sprite_x_pos
org $06EAA0 ; 06EAA6
Sprite_DirectionToFacePlayer:

org $06EACD ; 06EAD3
Sprite_IsToRightOfPlayer: ; if Link is to the left of the sprite, Y = 1, otherwise Y = 0

org $06EAE4 ; 06EAEA
Sprite_IsBelowPlayer: ; return Y=1 sprite is below player, otherwise Y = 0

org $06F129 ; 06F12F
Sprite_CheckDamageToPlayerSameLayer: ; check damage done to player if they collide and if they are on same layer

org $06F131 ; 06F137
Sprite_CheckDamageToPlayerIgnoreLayer: ; check damage done to player if they collide even if they are not on same layer

org $0DBB7C ; JP VALID
Sound_SetSfx2PanLong: ; play a sound loaded in A

; =================================================================
; spawn a new sprite on screen, A = sprite id
; when using this function you have to set the position yourself
; these values belong to the sprite who used that function not the new one
; $00 low x, $01 high x
; $02 low y, $03 high y
; $04 height, $05 low x (overlord)
; $06 high x (overlord), $07 low y (overlord)
; $08 high y (overlord)
org $1DF65D ; JP VALID
Sprite_SpawnDynamically:

org $07F1A3 ; 07F18C
Player_ResetState:

org $1D8010 ; JP VALID
Sprite_ApplyConveyorAdjustment: ; move the sprite if he stand on a conveyor belt

org $0683EA ; JP VALID
SetupHitBox: ; set the hitbox of the player (i think)

org $01E7A9 ; 01E7A7
Dungeon_SpriteInducedTilemapUpdate: ; set tile of dungeon

org $0DBA71 ; JP VALID
GetRandomInt:

org $1EF4F3 ; 1EF4E7
Sprite_PlayerCantPassThrough:

org $0FF540 ; 1CF500
Sprite_NullifyHookshotDrag:

org $0791B9 ; 0791B3
Player_HaltDashAttack:

org $0799AD
Link_ReceiveItem: ; Y = item id

org $00D463
Tagalong_LoadGfx:

; For messages: Y = high byte; A = low byte
org $05E219
Sprite_ShowMessageUnconditional:

org $05E1A7
Sprite_ShowSolicitedMessageIfPlayerFacing: ; show a message if we press A and face the sprite

org $05E1F0
Sprite_ShowMessageFromPlayerContact: ; show a message if we touch the sprite should be used with Sprite_PlayerCantPassThrough

!SEED_X = $7C ; [0x02]
!SEED_Y = $7E ; [0x02]
!PRNG_init = $0127

org $0CCF3E ; Selecting a file
JSL InitializePRNG : NOP

org $0CCC6C ; Module_SelectFile
JSL AdvancePRNG_FileSelect

org $00F804 ; Module_Message : JP1.0 valid
JSL AdvancePRNG_MessageModuleIndoors

org $00F81B ; Module_Message : JP1.0 valid
JSL AdvancePRNG_MessageModuleOutdoors

org $07800A ; Player_Main : JP1.0 valid
JSL AdvancePRNG_Movement : NOP

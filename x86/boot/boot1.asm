;################################################
;#                                              #
;#                                              #
;#       Project: SIZES @ 2017 - boot1.asm      #
;#                                              #
;#               Made by: Lucas P.              #
;#                                              #
;#                                              #
;################################################


org 0x7C00      ;BIOS put us here
bits 16         ;We start in 16 bits mode


;       FAT 32 FS just for now


Begin: jmp Main                           ;Jump to executable area
OEMName               db "SIZES P>"       ;OS Name, can be whatever
BytespSector          

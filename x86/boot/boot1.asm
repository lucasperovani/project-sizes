;#################################################
;#                                               #
;#                                               #
;#       Project: SIZES @ 2017 - boot1.asm       #
;#                                               #
;#               Made by: Lucas P.               #
;#                                               #
;#                                               #
;#################################################


org 0x7C00                                ; BIOS put us here
bits 16                                   ; We start in 16 bits mode
                                          

;       FAT 32 FS just for now

                                          
jmp short Main                            ; Jump to executable area
nop

OEMName               db "SIZES P>"       ; OS Name, can be whatever
BytespSector          dw 512
SectorspCluster       db 8
ReservedSectors       dw 32
FATs                  db 2
DirectoryEntries      dw 0                ; FAT 32
TotalSectors          dw 0                ; FAT 32
MediaDescriptor       db 0xF8             ; Fixed Disk

;       Disk related

SectorspFAT           dw 0                ; Only for FAT 12 or 16
SectorspTrack         dw 63
TotalHeads            dw 255              ; Max 255, 256 can cause a bug (???)
HiddenSectors         dd 128
SectorsBig            dd 0x0077DF00       ; 4GB Flash Drive



SectorspFAT           dd 0x00001DE8
Flags                 dw 0


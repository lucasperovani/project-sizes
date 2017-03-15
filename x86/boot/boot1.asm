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

OEMName               db "SIZES P>"       ; OS Name, can be whatever, must be 8 bytes length
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
SectorsBig            dd 0x77DF00         ; 4GB Flash Drive


                      
SectorspFAT           dd 0x1DE8
Flags1                dw 0
FATVersion            dw 0                ; Should be always 0 in FAT 32
RootCluster           dd 2                ; Where the Root directory is in Cluster Number
*FSISector             dw 1                ; Sector of FS Information Sector, usually 1, speeds up access
*BackupSector          dw 6                ; Sector that is located the Backup of the three FAT 32 Boot Sectors
TIMES 12              db 0                ; Reserved
DiveNumber            db 0x80             ; Hard Disks or Fixed Disks (Flash Drive)
Flags2                db 0
BootSignature         db 0x29             ; Always this value for FAT 12/FAT 16/FAT 32
VolumeID              dd 0x2914F5BD       ; Used to track the volume, can be anything
VolumeLabel           db "SIZES P    "    ; Label of the Volume, must be 11 bytes length
FSString              db "FAT 32  "       ; FS String, never trust, must be 8 bytes length


;       Allocate some messages


BootFail1             db "Could not find BootLoader!!!", 0
BootFail2             db "Am I missing something???", 0
KernelFail1           db "Could not find Kernel!!!
KernelFail2           db "Did I mess up with my files???", 0


;       Bootloader starts here


Main:


TIMES 510 - ($-$$) db 0                   ; Fill the rest of the file with 0 untill the Boot Signature
db 0xAA55


;       1.5 Bootloader Continues here





;       FS Information Sector

                      
FSISSignature1        dd 0x52526141       ; RRaA
TIMES 476             db 0                ; Reserved
FSISSignature2        dd 0x72724161       ; rrAa
FreeDataClusters      dd 0xDCF30E00       ; Last know number of Free Data Clusters, mine was it
AllocDataCluster      dd 6                ; Last modified cluster, it was the Backup Boot Sector
TIMES 18              db 0
db 0xAA55                                 ; The last four bytes must be 0x000055AA











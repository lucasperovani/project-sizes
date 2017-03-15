;#################################################
;#                                               #
;#                                               #
;#       Project: SIZES @ 2017 - boot1.asm       #
;#                                               #
;#               Made by: Lucas P.               #
;#                                               #
;#                                               #
;#################################################


;------------------------------------------------------------------------------
;                   |                                                         |
;     0050:0000     |     Stack End (for now, end is just a abstraction)      |
;     0050:01FE     |     Stack Start                                         |
;                   |                                                         |
;------------------------------------------------------------------------------
;                   |                                                         |
;     0050:01FF     |     Stage 1 Bootloader Start (512 bytes)                |
;     0050:03FF     |     Stage 1 Bootloader End                              |
;                   |                                                         |
;------------------------------------------------------------------------------
;                   |                                                         |
;     0050:0400     |     Stage 1.5 Bootloader Start (xxx Bytes)              |
;     0050:----     |     Stage 1.5 Bootloader End                            |
;                   |                                                         |
;------------------------------------------------------------------------------


org 0x06FF                                ; BIOS put us in 0x7C00, but we will move itself to this location
                                          ; Make every Register based on this
                                          
bits 16                                   ; We start in 16 bits mode
                                          

;       FAT 32 FS just for now

                                          
jmp short Start                           ; Jump to executable area
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


SectorspFAT1          dw 0                ; Only for FAT 12 or 16
SectorspTrack         dw 63
TotalHeads            dw 255              ; Max 255, 256 can cause a bug (???)
HiddenSectors         dd 128
SectorsBig            dd 0x77DF00         ; 4GB Flash Drive


                      
SectorspFAT2          dd 0x1DE8
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


;       Allocate some useful things


BootFail              db "Could not find BootLoader!!!", 0x0D, 0x0A
                         "Am I missing something???", 0
                          
KernelFail            db "Could not find Kernel!!!", 0x0D, 0x0A
                         "Did I mess up with my files???", 0
                         
BootDrive             db 0                ; Drive where we Boot
SizeBoot15            db 0                ; Size of the 1.5 Bootloader in Sectors

TmpLBA                db 0
TmpSec                db 0                ; Temporary Location to hadle those vars
TmpHead               db 0
TempCyl               db 0
                                          

;       Bootloader starts here


Start:


cli                                       ; Clear Interrupts, avoid getting interrupt
                                          
xor ax, ax                                ; Clear AX

mov ds, ax                                ; Setup Data Registers
mov es, ax

mov ax, 50h
mov ss, ax                                ; Setup Stack Registers
mov sp, 01FEh


mov cx, 200h                              ; Copy all this Boot
mov si, 7C00h                             ; BIOS put us on this location
mov di, 6FFh                              ; Where to copy

rep movsw                                 ; Move us untill CX reach 0


jmp 0000:Main                             ; Jump to the new address


LBAtoCHS:

;Sector = (LBA mod SectorspTrack) + 1
;Head = (LBA / SectorspTrack) mod TotalHeads
;Cylinder = (LBA / SectorspTrack) / TotalHeads

push ax
push dx

xor ax, ax
xor dx, dx

mov ax, BYTE [TmpLBA]
div WORD [SectorspTrack]
inc dl
mov BYTE [TmpSec], dl                     ; Store Sector CHS

xor dx, dx

div TotalHeads
mov BYTE [TmpHead], dl                    ; Store Head CHS
mov BYTE [TempCyl], al                    ; Store Cylinder CHS

xor dx, dx                                ; Just to make sure they will receive the right Data
xor ax, ax

pop dx
pop ax

ret


CHStoLBA:

ret


ReadSectors:                              ; AL = Size in Sectors to Read, CH = Low 8 bits Track/Cylinder
                                          ; CL = 2 High bits Track/Cylinder and 3 bits Sector Number
                                          ; DH = Head Number, DL = Driver Number, ES:BX = Point of Memory (Buffer)
push al
xor ax, ax                                ; Reset Driver, AH = 00h and DL = Drive
int 13h

pop al
mov ah, 0x02                              ; Function to Read Sectors
int 13h                                   ; Call Interrupt

ret


Main:


sti                                       ; Bring back Interrupts
mov BYTE [BootDrive], dl                  ; Get the Drive we Boot

                                          
TIMES (510 - ($-$$))  db 0                ; Fill the rest of the file with 0 untill the Boot Signature
db 0xAA55


;       1.5 Bootloader Continues here





;       FS Information Sector

                                          
FSISSignature1        dd 0x41615252       ; RRaA
TIMES 476             db 0                ; Reserved
FSISSignature2        dd 0x61417272       ; rrAa
FreeDataClusters      dd 0xE0F3DC         ; Last know number of Free Data Clusters, mine was it
AllocDataCluster      dd 6                ; Last modified cluster, it was the Backup Boot Sector
TIMES 18              db 0
db 0xAA55                                 ; The last four bytes must be 0x000055AA











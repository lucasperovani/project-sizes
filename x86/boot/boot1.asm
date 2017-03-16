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
;     0050:0200     |     Stage 1 Bootloader Start (512 bytes)                |
;     0050:0400     |     Stage 1 Bootloader End                              |
;                   |                                                         |
;------------------------------------------------------------------------------
;                   |                                                         |
;     0050:0401     |     Stage 1.5 Bootloader Start (xxx Bytes)              |
;     0050:----     |     Stage 1.5 Bootloader End                            |
;                   |                                                         |
;------------------------------------------------------------------------------


org 0x0700                                ; BIOS put us in 0x7C00, but we will move itself to 0x0700
                                          ; Make every Register based on this
                                          
bits 16                                   ; We start in 16 bits mode
                                          

;       FAT 32 FS just for now

                                          
jmp short Start                           ; Jump to executable area
nop

OEMName               db "SIZES P>"       ; OS Name, can be whatever, must be 8 bytes length
BytespSector          dw 512
SectorspCluster       db 8
ReservedSectors       dw 0x0430
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
FSISector             dw 2                ; Sector of FS Information Sector, usually 1, speeds up access              *
BackupSector          dw 7                ; Sector that is located the Backup of the three FAT 32 Boot Sectors        *
TIMES 12              db 0                ; Reserved
DiveNumber            db 0x80             ; Hard Disks or Fixed Disks (Flash Drive)
Flags2                db 0
BootSignature         db 0x29             ; Always this value for FAT 12/FAT 16/FAT 32
VolumeID              dd 0x2914F5BD       ; Used to track the volume, can be anything
VolumeLabel           db "SIZES P    "    ; Label of the Volume, must be 11 bytes length
FSString              db "FAT 32  "       ; FS String, never trust, must be 8 bytes length
                                          

;       Bootloader starts here


Start:

cli                                       ; Clear Interrupts, avoid getting interrupt
                                          
xor ax, ax                                ; Clear AX

mov ax, 70h                               ; Setup Segment Registers
mov ds, ax                                
mov es, ax
mov fs, ax
mov gs, ax

mov ax, 70h
mov ss, ax                                ; Setup Stack Registers
mov sp, 0h


mov cx, 100h                              ; Copy all this Boot
mov si, 7C00h                             ; BIOS put us on this location
mov di, 0700h                             ; Where to copy

rep movsw                                 ; Move us untill CX reach 0

jmp 0:Main                                ; Jump to the new address

mov si, BootFail                          ; Teste
call Print

LBAtoCHS:

;Sector = (LBA mod SectorspTrack) + 1
;Head = (LBA / SectorspTrack) mod TotalHeads
;Cylinder = (LBA / SectorspTrack) / TotalHeads

push ax
push dx

xor ax, ax
xor dx, dx

mov ax, WORD [TmpLBA]
div WORD [SectorspTrack]
inc dl
mov BYTE [TmpSec], dl                     ; Store Sector CHS

xor dx, dx

div WORD [TotalHeads]
mov BYTE [TmpHead], dl                    ; Store Head CHS
mov BYTE [TmpCyl], al                    ; Store Cylinder CHS

xor dx, dx                                ; Just to make sure they will receive the right Data
xor ax, ax

pop dx
pop ax
ret


ClustertoLBA:


ret


ReadSectors:


; AL = Size in Sectors to Read, CH = Low 8 bits Track/Cylinder
; CL = 2 High bits Track/Cylinder and 3 bits Sector Number
; DH = Head Number, DL = Driver Number, ES:BX = Point of Memory (Buffer)

push ax
mov di, 5h

.Retry:
xor ax, ax                                ; Reset Driver, AH = 00h and DL = Drive
int 13h

pop ax
mov ah, 0x02                              ; Function to Read Sectors
int 13h                                   ; Call Interrupt

jnc .Done
dec di                                    ; Give 5 chances
jnz .Retry

.Fail:

mov si, ErrorRead
call Print

.Done:

ret


Print:


push ax
push bx

xor bx, bx

.Next:

lodsb                                     ; Load next Byte in al
or al, al
jz .Printed
mov ah, 0Eh
int 10h
jmp .Next

.Printed:

pop bx
pop ax
ret


Main:


sti                                       ; Bring back Interrupts
mov BYTE [BootDrive], dl                  ; Get the Drive we Boot
mov WORD [SizeBoot15], End15 - Start15    ; Get Size of 1.5 Boot

mov si, KernelFail                        ; Teste
call Print

mov ax, WORD [SizeBoot15]
div WORD [BytespSector]
cmp dx, 0h
je .Read
inc ax                                    ; Get Sectors

.Read:

mov WORD [TmpLBA], 0002h                  ; Second Sector
call LBAtoCHS

mov ch, BYTE [TmpCyl]
mov cl, BYTE [TmpSec]
mov dh, BYTE [TmpHead]
mov dl, BYTE [BootDrive]

mov bx, 0201h                             ; Where to place what we are reading, ES:BX, ES already ready
call ReadSectors

mov si, teste
call Print

mov al, 0
int 16h

cli
hlt


;       Allocate some useful things


BootFail              db "Could not find BootLoader!!!", 0Dh, 0Ah
                      db "Am I missing something???", 0
                          
KernelFail            db "Could not find Kernel!!!", 0Dh, 0Ah
                      db "Did I mess up with my files???", 0
                      
ErrorRead             db "Fail to Read the Driver!!!", 0Dh, 0Ah
                      db "It said: Leave me Alone!!!", 0
                         
BootDrive             db 0                ; Drive where we Boot
SizeBoot15            dw 0                ; Size of the 1.5 Bootloader in Sectors

TmpLBA                dw 0
TmpSec                db 0                ; Temporary Location to hadle those vars
TmpHead               db 0
TmpCyl                db 0

                                          
TIMES (510 - ($-$$))  db 0                ; Fill the rest of the file with 0 untill the Boot Signature
dw 0xAA55


;       1.5 Bootloader Continues here

Start15:

teste db "teste", 0 

End15:

TIMES (512-(End15-Start15)) db 0

;       FS Information Sector

                                          
FSISSignature1        dd 0x41615252       ; RRaA
TIMES 480             db 0                ; Reserved
FSISSignature2        dd 0x61417272       ; rrAa
FreeDataClusters      dd 0x00E0F3DC       ; Last know number of Free Data Clusters, mine was it
AllocDataCluster      dd 6                ; Last modified cluster, it was the Backup Boot Sector
TIMES 14              db 0
dw 0xAA55                                 ; The last four bytes must be 0x000055AA











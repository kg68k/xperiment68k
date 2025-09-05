.title run68_dos_test - tests for run68 doscall trace (-f option)

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac

NGFILENO: .equ $ffff


.text

Start:
  addq.l #1,a2
  @@:
    cmpi.b #' ',(a2)+
  beq @b
  tst.b -(a2)
  sne d7  ;enable RS-232C and printer functions

  DOS _GETCHAR  ;$ff01

  move #'a',-(sp)
  DOS _PUTCHAR  ;$ff02
  addq.l #2,sp

  tst.b d7
  beq @f
    DOS _COMINP  ;$ff03

    move #'a',-(sp)
    DOS _COMOUT  ;$ff04
    addq.l #2,sp

    move #'a',-(sp)
    DOS _PRNOUT  ;$ff05
    addq.l #2,sp
  @@:

  move #$ff,-(sp)
  DOS _INPOUT  ;$ff06
  move #'b',-(sp)
  DOS _INPOUT  ;$ff06
  addq.l #4,sp

  DOS _INKEY  ;$ff07

  DOS _GETC  ;$ff08

  pea (str,pc)
  DOS _PRINT  ;$ff09
  addq.l #4,sp

  lea (buf,pc),a0
  move #10<<8+0,(a0)
  pea (a0)
  DOS _GETS  ;$ff0a
  addq.l #4,sp

  DOS _KEYSNS  ;$ff0b

  move #1,-(sp)
  DOS _KFLUSH  ;$ff0c mode=1
  addq.l #2,sp

  move #'c',-(sp)
  move #6,-(sp)
  DOS _KFLUSH  ;$ff0c mode=6
  addq.l #4,sp

  lea (buf,pc),a0
  move #10<<8+0,(a0)
  pea (a0)
  move #10,-(sp)
  DOS _KFLUSH  ;$ff0c mode=10
  addq.l #6,sp

  DOS _FFLUSH  ;$ff0d

  DOS _CURDRV  ;$ff19
  move d0,-(sp)
  DOS _CHGDRV  ;$ff0e
  addq.l #2,sp

  move #0<<8+('Z'-'A'+1),-(sp)
  DOS _DRVCTRL  ;$ff0f
  addq.l #2,sp

  DOS _CONSNS  ;$ff10

  DOS _PRNSNS  ;$ff11

  DOS _CINSNS  ;$ff12

  DOS _COUTSNS  ;$ff13

  pea (buf,pc)
  pea (ngfile,pc)
  DOS _FATCHK  ;$ff17
  addq.l #8,sp

  move #3,-(sp)
  DOS _HENDSP  ;$ff18
  addq.l #2,sp

  lea (buf,pc),a0
  move #10<<8+0,(a0)
  pea (a0)
  DOS _GETS  ;$ff1a
  addq.l #4,sp

  move #STDIN,-(sp)
  DOS _FGETC  ;$ff1b
  addq.l #2,sp

  move #STDIN,-(sp)
  lea (buf,pc),a0
  move #10<<8+0,(a0)
  pea (a0)
  DOS _FGETS  ;$ff1c
  addq.l #6,sp

  move #STDOUT,-(sp)
  move #'d',-(sp)
  DOS _FPUTC  ;$ff1d
  addq.l #4,sp

  move #STDOUT,-(sp)
  pea (str,pc)
  DOS _FPUTS  ;$ff1e
  addq.l #6,sp

  DOS _ALLCLOSE  ;$ff1f

  clr.l -(sp)
  DOS _SUPER  ;$ff20
  move.l d0,(sp)
  DOS _SUPER
  addq.l #4,sp

  pea (buf,pc)
  move #0<<8+32,-(sp)
  DOS _FNCKEY  ;$ff21
  addq.l #6,sp

  pea (50)
  DOS _KNJCTRL  ;$ff22
  addq.l #4,sp

  move #'e',-(sp)
  move #0,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #4,sp

  pea (str,pc)
  move #1,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #6,sp

  move #-1,-(sp)
  move #2,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #4,sp

  move #4,-(sp)
  move #10,-(sp)
  move #3,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #6,sp

  move #4,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #2,sp

  move #1,-(sp)
  move #6,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #4,sp

  move #0,-(sp)
  move #11,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #4,sp

  move #0,-(sp)
  move #14,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #4,sp

  move #31,-(sp)
  move #0,-(sp)
  move #15,-(sp)
  DOS _CONCTRL  ;$ff23
  addq.l #6,sp

  move #2,-(sp)
  DOS _KEYCTRL  ;$ff24
  addq.l #2,sp

  move #0,-(sp)
  move #3,-(sp)
  DOS _KEYCTRL  ;$ff24
  addq.l #4,sp

  move #0,-(sp)
  move #4,-(sp)
  DOS _KEYCTRL  ;$ff24
  addq.l #4,sp

  move #$3f,-(sp)
  DOS _INTVCG  ;$ff35
  addq.l #2,sp
  move.l d0,-(sp)
  move #$3f,-(sp)
  DOS _INTVCS  ;$ff25
  addq.l #6,sp

  ;;pea (pspadr)
  ;;DOS _PSPSET  ;$ff26
  ;;addq.l #4,sp

  DOS _GETTIM2  ;$ff27
  move.l d0,-(sp)
  DOS _SETTIM2  ;$ff28
  addq.l #4,sp

  pea (buf,pc)
  pea (file,pc)
  DOS _NAMESTS  ;$ff29
  addq.l #8,sp

  DOS _GETDATE  ;$ff2a
  move.l d0,-(sp)
  DOS _SETDATE  ;$ff2b
  addq.l #4,sp

  DOS _GETTIME  ;$ff2c
  move.l d0,-(sp)
  DOS _SETTIME  ;$ff2d
  addq.l #4,sp

  DOS _VERIFYG
  move d0,-(sp)
  DOS _VERIFY  ;$ff2e
  addq.l #2,sp

  move #STDPRN,-(sp)
  move #STDOUT,-(sp)
  DOS _DUP0  ;$ff2f
  addq.l #4,sp

  DOS _VERNUM  ;$ff30

  ;;move #0,-(sp)
  ;;pea (256)
  ;;DOS _KEEPPR  ;$ff31

  pea (buf,pc)
  move #0,-(sp)
  DOS _GETDPB  ;$ff32
  addq.l #6,sp

  move #0<<8+$ff,-(sp)
  DOS _BREAKCK  ;$ff33
  addq.l #2,sp

  move #0,-(sp)
  move #0,-(sp)
  DOS _DRVXCHG  ;$ff34
  addq.l #4,sp

  pea (buf,pc)
  move #0,-(sp)
  DOS _DSKFRE  ;$ff36
  addq.l #6,sp

  pea (buf,pc)
  pea (file,pc)
  DOS _NAMECK  ;$ff37
  addq.l #8,sp

  pea (ngfile,pc)
  DOS _MKDIR  ;$ff39
  addq.l #4,sp

  pea (ngfile,pc)
  DOS _RMDIR  ;$ff3a
  addq.l #4,sp

  pea (ngfile,pc)
  DOS _CHDIR  ;$ff3b
  addq.l #4,sp

  move #$20,-(sp)
  pea (ngfile,pc)
  DOS _CREATE  ;$ff3c
  addq.l #6,sp

  move #0,-(sp)
  pea (nulfile,pc)
  DOS _OPEN  ;$ff3d
  addq.l #6,sp
  move.l d0,d6

  move.l #10,-(sp)
  pea (buf,pc)
  move d6,-(sp)
  DOS _READ  ;$ff3f
  lea (10,sp),sp

  move.l #10,-(sp)
  pea (buf,pc)
  move d6,-(sp)
  DOS _WRITE  ;$ff40
  lea (10,sp),sp

  pea (ngfile,pc)
  DOS _DELETE  ;$ff41
  addq.l #4,sp

  move #2,-(sp)
  move.l #-1,-(sp)
  move d6,-(sp)
  DOS _SEEK
  addq.l #8,sp

  move d6,-(sp)
  move #0,-(sp)
  DOS _IOCTRL  ;$ff44
  addq.l #4,sp

  move d0,-(sp)
  move d6,-(sp)
  move #1,-(sp)
  DOS _IOCTRL  ;$ff44
  addq.l #6,sp

  pea (10)
  pea (buf,pc)
  move d6,-(sp)
  move #2,-(sp)
  DOS _IOCTRL  ;$ff44
  lea (12,sp),sp

  pea (10)
  pea (buf,pc)
  move #0,-(sp)
  move #4,-(sp)
  DOS _IOCTRL  ;$ff44
  lea (12,sp),sp

  move #0,-(sp)
  move #9,-(sp)
  DOS _IOCTRL  ;$ff44
  addq.l #4,sp

  move #100,-(sp)
  move #3,-(sp)
  move #11,-(sp)
  DOS _IOCTRL  ;$ff44
  addq.l #6,sp

  ;;pea (buf,pc)
  ;;move #0,-(sp)
  ;;move d6,-(sp)
  ;;move #12,-(sp)
  ;;DOS _IOCTRL  ;$ff44
  ;;lea (10,sp),sp

  pea (buf,pc)
  move #0,-(sp)
  move #0,-(sp)
  move #13,-(sp)
  DOS _IOCTRL  ;$ff44
  lea (10,sp),sp

  move d6,-(sp)
  DOS _CLOSE  ;$ff3e
  addq.l #2,sp

  move #STDIN,-(sp)
  DOS _DUP  ;$ff45
  addq.l #2,sp
  move.l d0,d6

  move d6,-(sp)
  move #STDOUT,-(sp)
  DOS _DUP2  ;$ff46
  addq.l #4,sp

  move d6,-(sp)
  DOS _CLOSE

  pea (buf,pc)
  move #0,-(sp)
  DOS _CURDIR  ;$ff47
  addq.l #6,sp

  pea (-1)
  DOS _MALLOC  ;$ff48
  addq.l #4,sp

  clr.l -(sp)
  DOS _MFREE  ;$ff49
  addq.l #4,sp

  move.l #End-Start+$f0,-(sp)
  pea (Start-$f0,pc)
  DOS _SETBLOCK  ;$ff4a
  addq.l #8,sp

  clr.l -(sp)
  pea (str,pc)
  pea (ngfile,pc)
  move #0<<8+0,-(sp)
  DOS _EXEC  ;$ff4b
  lea (14,sp),sp

  pea ($c00000)
  pea ($b80000)
  pea (ngfile,pc)
  move #0<<8+3,-(sp)
  DOS _EXEC  ;$ff4b
  lea (14,sp),sp

  ;;pea ($b80000)
  ;;move #0<<8+4,-(sp)
  ;;DOS _EXEC  ;$ff4b
  ;;addq.l #6,sp

  ;;pea (file,pc)
  ;;pea (ngfile,pc)
  ;;move #0<<8+5,-(sp)
  ;;DOS _EXEC  ;$ff4b
  ;;lea (10,sp),sp

  ;;move #1,-(sp)
  ;;DOS _EXIT2  ;$ff4c

  DOS _WAIT  ;$ff4d

  move #$ff,-(sp)
  pea (ngfile,pc)
  pea (buf,pc)
  DOS _FILES  ;$ff4e
  lea (10,sp),sp

  pea (buf,pc)
  DOS _NFILES  ;$ff4f
  addq.l #4,sp

  DOS _V2_GETPDB  ;$ff51
  ;;move.l d0,-(sp)
  ;;DOS _V2_SETPDB  ;$ff50
  ;;addq.l #4,sp

  pea (file,pc)
  clr.l -(sp)
  pea (envname,pc)
  DOS _V2_SETENV  ;$ff52
  lea (12,sp),sp

  pea (buf,pc)
  clr.l -(sp)
  pea (envname,pc)
  DOS _V2_GETENV  ;$ff53
  lea (12,sp),sp

  DOS _V2_VERIFYG  ;$ff54

  pea (file,pc)
  pea (ngfile,pc)
  DOS _V2_RENAME  ;$ff56
  addq.l #8,sp

  clr.l -(sp)
  move #STDIN,-(sp)
  DOS _V2_FILEDATE  ;$ff57
  addq.l #6,sp

  pea (-1)
  move #1,-(sp)
  DOS _V2_MALLOC2  ;$ff58
  addq.l #6,sp

  pea (Start-$100,pc)
  pea (-1)
  move #$8002,-(sp)
  DOS _V2_MALLOC2  ;$ff58
  lea (10,sp),sp

  move #$20,-(sp)
  pea (ngfile,pc)
  DOS _V2_MAKETMP  ;$ff5a
  addq.l #6,sp

  move #$20,-(sp)
  pea (ngfile,pc)
  DOS _V2_NEWFILE  ;$ff5b
  addq.l #6,sp

  lea (drive,pc),a0
  DOS _CURDRV
  addi.b #'A',d0
  move.b d0,(a0)

  pea (buf,pc)
  pea (drive,pc)
  move #0,-(sp)
  DOS _V2_ASSIGN  ;$ff5f
  lea (10,sp),sp

  move #$50,-(sp)
  pea (ngfile,pc)
  pea (drive,pc)
  move #1,-(sp)
  DOS _V2_ASSIGN  ;$ff5f
  lea (12,sp),sp

  pea (drive,pc)
  move #4,-(sp)
  DOS _V2_ASSIGN  ;$ff5f
  addq.l #6,sp

  pea (-1)
  DOS _V2_MALLOC3  ;$ff60
  addq.l #4,sp

  move.l #End-Start+$f0,-(sp)
  pea (Start-$f0,pc)
  DOS _V2_SETBLOCK2  ;$ff61
  addq.l #8,sp

  pea (Start-$100,pc)
  pea (-1)
  move #$8002,-(sp)
  DOS _V2_MALLOC4  ;$ff62
  lea (10,sp),sp

  pea (-1)
  move #0,-(sp)
  DOS _V2_S_MALLOC2  ;$ff63
  addq.l #6,sp

  move #-1,-(sp)
  DOS _V2_FFLUSH_SET  ;$ff7a
  addq.l #2,sp

  ;;clr.l -(sp)
  ;;move #$ff<<8+$ff,-(sp)
  ;;DOS _V2_OS_PATCH  ;$ff7b
  ;;addq.l #6,sp

  move #STDIN,-(sp)
  DOS _V2_GET_FCB_ADR  ;$ff7c
  addq.l #2,sp

  pea (-1)
  move #0,-(sp)
  DOS _V2_S_MALLOC  ;$ff7d
  addq.l #6,sp

  clr.l -(sp)
  DOS _V2_S_MFREE  ;$ff7e
  addq.l #4,sp

  ;;move.l #I_LEN,-(sp)
  ;;move.l #LENGTH,-(sp)
  ;;pea (START)
  ;;move #ID,-(sp)
  ;;DOS _V2_S_PROCESS  ;$ff7f
  ;;lea (14,sp),sp

  DOS _GETPDB  ;$ff81
  ;;move.l d0,-(sp)
  ;;DOS _SETPDB  ;$ff80
  ;;addq.l #4,sp

  pea (file,pc)
  clr.l -(sp)
  pea (envname,pc)
  DOS _SETENV  ;$ff82
  lea (12,sp),sp

  pea (buf,pc)
  clr.l -(sp)
  pea (envname,pc)
  DOS _GETENV  ;$ff83
  lea (12,sp),sp

  DOS _VERIFYG  ;$ff84

  pea (file,pc)
  pea (ngfile,pc)
  DOS _RENAME  ;$ff86
  addq.l #8,sp

  clr.l -(sp)
  move #STDIN,-(sp)
  DOS _FILEDATE  ;$ff87
  addq.l #6,sp

  pea (-1)
  move #1,-(sp)
  DOS _MALLOC2  ;$ff88
  addq.l #6,sp

  pea (Start-$100,pc)
  pea (-1)
  move #$8002,-(sp)
  DOS _MALLOC2  ;$ff88
  lea (10,sp),sp

  move #$20,-(sp)
  pea (ngfile,pc)
  DOS _MAKETMP  ;$ff8a
  addq.l #6,sp

  move #$20,-(sp)
  pea (ngfile,pc)
  DOS _NEWFILE  ;$ff8b
  addq.l #6,sp

  lea (drive,pc),a0
  DOS _CURDRV
  addi.b #'A',d0
  move.b d0,(a0)

  pea (buf,pc)
  pea (drive,pc)
  move #0,-(sp)
  DOS _ASSIGN  ;$ff8f
  lea (10,sp),sp

  move #$50,-(sp)
  pea (ngfile,pc)
  pea (drive,pc)
  move #1,-(sp)
  DOS _ASSIGN  ;$ff8f
  lea (12,sp),sp

  pea (drive,pc)
  move #4,-(sp)
  DOS _ASSIGN  ;$ff8f
  addq.l #6,sp

  pea (-1)
  DOS _MALLOC3  ;$ff90
  addq.l #4,sp

  move.l #End-Start+$f0,-(sp)
  pea (Start-$f0,pc)
  DOS _SETBLOCK2  ;$ff91
  addq.l #8,sp

  pea (Start-$100,pc)
  pea (-1)
  move #$8002,-(sp)
  DOS _MALLOC4  ;$ff92
  lea (10,sp),sp

  pea (-1)
  move #0,-(sp)
  DOS _S_MALLOC2  ;$ff93
  addq.l #6,sp

  move #-1,-(sp)
  DOS _FFLUSH_SET  ;$ffaa
  addq.l #2,sp

  ;;clr.l -(sp)
  ;;move #$ff<<8+$ff,-(sp)
  ;;DOS _OS_PATCH  ;$ffab
  ;;addq.l #6,sp

  move #STDIN,-(sp)
  DOS _GET_FCB_ADR  ;$ffac
  addq.l #2,sp

  pea (-1)
  move #0,-(sp)
  DOS _S_MALLOC  ;$ffad
  addq.l #6,sp

  clr.l -(sp)
  DOS _S_MFREE  ;$ffae
  addq.l #4,sp

  ;;move.l #I_LEN,-(sp)
  ;;move.l #LENGTH,-(sp)
  ;;pea (START)
  ;;move #ID,-(sp)
  ;;DOS _S_PROCESS  ;$ffaf
  ;;lea (14,sp),sp

  clr -(sp)  
  DOS $ffb0  ;(v)twentyone.sys _TWON
  addq.l #2,sp

  clr -(sp)  
  DOS $ffb1  ;mvdir.r _MVDIR
  addq.l #2,sp

  ;;DOS $ffe0  ;swapper.sys _VMALLOC
  ;;DOS $ffe1  ;swapper.sys _VMFREE
  ;;DOS $ffe2  ;swapper.sys _VMALLOC2
  ;;DOS $ffe3  ;swapper.sys _VSETBLOCK
  ;;DOS $ffe4  ;vmexec.sys _VEXEC

  ;;DOS $ffef  ;fontman.x _GETFONT

  move #1,-(sp)
  move #0,-(sp)
  move #0,-(sp)
  pea (buf,pc)
  DOS _DISKRED  ;$fff3
  lea (10,sp),sp

  ;;DOS _DISKWRT  ;$fff4

  DOS _INDOSFLG  ;$fff5

  pea (superjob,pc)
  DOS _SUPER_JSR  ;$fff6
  addq.l #4,sp

  move #4,-(sp)
  pea (buf,pc)
  pea (file,pc)
  DOS _BUS_ERR  ;$fff7
  lea (10,sp),sp

  ;;DOS _OPEN_PR  ;$fff8
  ;;DOS _KILL_PR  ;$fff9

  pea (buf,pc)
  move #-2,-(sp)
  DOS _GET_PR  ;$fffa
  addq.l #6,sp

  move #$ffff,-(sp)
  DOS _SUSPEND_PR  ;$fffb
  addq.l #2,sp

  ;;DOS _SLEEP_PR  ;$fffc

  ;;DOS _SEND_PR  ;$fffd

  DOS _TIME_PR  ;$fffe

  DOS _CHANGE_PR  $ffff

  DOS _EXIT  ;$ff00


superjob:
  rts


.data

str: .dc.b 'TEST',CR,LF,0
drive: .dc.b 'A:',0
file: .dc.b 'A:\test.txt',0
ngfile: .dc.b '?:invalid.txt',0
nulfile: .dc.b 'NUL',0
envname: .dc.b 'env',0


.bss
buf: .ds.b 64*1024


End:

.end

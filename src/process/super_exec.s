.title super_exec - switch to supervisor mode and execute file

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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

.include macro.mac

.include xputil.mac


MARGIN_SIZE: .equ 256
.fail (MARGIN_SIZE.and.%11).or.(MARGIN_SIZE>$10000*4)


.cpu 68000
.text

ProgramStart:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    PRINT_1LINE_USAGE 'usage: super_exec <command...>'
    DOS _EXIT
  @@:
  lea (Execfile,pc),a0
  STRCPY a2,a0

  bsr pathchk
  tst.l d0
  bpl @f
    FATAL_ERROR 'pathchk error'
  @@:

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  move.l sp,d0
  bsr PrintSsp

  move.l #MARGIN_SIZE,d0
  suba.l d0,sp
  lea (sp),a0
  bsr PushZero

  move.l sp,d0
  bsr PrintSsp

  bsr exec

  move.l #MARGIN_SIZE,d0
  lea (sp),a0
  bsr DumpMemory

  DOS _EXIT


PrintSsp:
  move.l d0,-(sp)
  DOS_PRINT (strSsp,pc)
  move.l (sp)+,d0
  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


PushZero:
  move.l d0,-(sp)
  bsr PrintDecString
  DOS_PRINT (strPushZero,pc)
  move.l (sp)+,d0

  lsr.l #2,d0
  moveq #0,d1
  bra 1f
  @@:
    move.l d1,(a0)+
  1:
  dbra d0,@b
  rts


DumpMemory:
  lsr.l #2,d0
  beq 9f
    move d0,d2  ;残りロングワード数
    DOS_PRINT (strPrintStack,pc)
    lea (a0),a1
    1:
      moveq #0,d1  ;変換したロングワード数
      lea (Buffer,pc),a0
      2:
        move.b #'$',(a0)+
        move.l (a1)+,d0
        bsr ToHexString8
        move.b #' ',(a0)+
  
        addq #1,d1
      cmpi #8,d1
      beq @f
        cmp d1,d2
        bne 2b
      @@:
      subq.l #1,a0
      WRITE_CRLF_NUL a0
      DOS_PRINT (Buffer,pc)
    sub d1,d2
    bne 1b
  9:
  rts


pathchk:
  clr.l -(sp)
  pea (Cmdline,pc)
  pea (Execfile,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  rts


exec:
  DOS_PRINT (Execfile,pc)
  DOS_PRINT (Space,pc)
  DOS_PRINT (Cmdline,pc)
  DOS_PRINT_CRLF

  clr.l -(sp)
  pea (Cmdline,pc)
  pea (Execfile,pc)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp

  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINT$4_4 Print$4_4
  DEFINE_PRINTD0$4_4 PrintD0$4_4
  DEFINE_PRINTDECSTRING PrintDecString
  DEFINE_TOHEXSTRING8 ToHexString8


.data

strSsp: .dc.b 'ssp = ',0
strPushZero: .dc.b 'バイトの0をスタックに積みます。',CRLF,0
strPrintStack: .dc.b '0を積んだスタックの現在の内容を表示します。',CRLF,0

Space: .dc.b ' ',0


.bss
.even

Cmdline: .ds.b 256
Execfile: .ds.b 256

Buffer: .ds.b .sizeof.('$01234567 ')*8+8


.end ProgramStart

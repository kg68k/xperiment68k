.title dos_malloc2 - DOS _MALLOC2 or _S_MALLOC

;This file is part of Xperiment68k
;Copyright (C) 2025 TcbnErik
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

.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  move.l a0,d5  ;ptr省略時は自分自身のプロセス管理ポインタを使用する

  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  lea (Malloc,pc),a5
  cmpi.b #'-',(a0)
  bne @f
    cmpi.b #'s',(1,a0)
    bne PrintUsage
      lea (SMalloc,pc),a5
      addq.l #2,a0
      SKIP_SPACE a0
      beq PrintUsage
  @@:

  FPACK __STOH
  bcs NumberError
  cmpi.l #$0001_0000,d0
  bcc NumberError
  move d0,d7  ;md

  SKIP_SPACE a0
  beq PrintUsage
  FPACK __STOH
  bcs NumberError
  move.l d0,d6  ;len

  tst d7
  bpl @f
    SKIP_SPACE a0  ;md=$800xの場合はポインタを指定できる
    beq @f
      FPACK __STOH
      bcs NumberError
      move.l d0,d5  ;ptr
  @@:

  jsr (a5)
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


Malloc:
  tst d7
  bmi 1f
    move.l d6,-(sp)
    move d7,-(sp)
    DOS _MALLOC2
    addq.l #6,sp
    bra 9f
  1:
    move.l d5,-(sp)
    move.l d6,-(sp)
    move d7,-(sp)
    DOS _MALLOC2
    lea (10,sp),sp
  9:
  rts

SMalloc:
  tst d7
  bmi 1f
    move.l d6,-(sp)
    move d7,-(sp)
    DOS _S_MALLOC
    addq.l #6,sp
    bra 9f
  1:
    move.l d5,-(sp)
    move.l d6,-(sp)
    move d7,-(sp)
    DOS _S_MALLOC
    lea (10,sp),sp
  9:
  rts


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT

NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strUsage:
  .dc.b 'usage:',CR,LF
  .dc.b '  dos_malloc2 [-s] <0|1|2> <len>',CR,LF
  .dc.b '  dos_malloc2 [-s] <8000|8001|8002> <len> [ptr]',CR,LF
  .dc.b 0

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart

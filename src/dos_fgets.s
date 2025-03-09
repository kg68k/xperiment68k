.title dos_fgets - DOS _FGETS

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

.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #STDIN,d7
  moveq #0,d6

  lea (1,a2),a0
  SKIP_SPACE a0
  bne filenameSpecified
    move d7,-(sp)
    clr -(sp)
    DOS _IOCTRL
    move.l d0,(sp)+
    bmi @f
      tst d0
      bpl @f  ;ブロックデバイス
        btst #0,d0
        beq @f  ;標準入力ではない
          moveq #'>',d6  ;コンソールからの入力なら出力に引用符をつける
  bra @f
  filenameSpecified:
    clr -(sp)
    pea (a0)
    DOS _OPEN
    addq.l #6,sp
    move.l d0,d7
    bmi error
  @@:

  lea (Buffer,pc),a3
  loop:
    move #255<<8+0,(a3)

    move d7,-(sp)
    pea (a3)
    DOS _FGETS
    addq.l #6,sp
    tst.l d0
    bmi 9f
      tst d6
      beq @f
        IOCS _B_DOWN_S
        cmpi.b #$1a,(2,a3)
        beq exit  ;Ctrl+Zで終了
        move d6,d1
        IOCS _B_PUTC
      @@:
      DOS_PRINT (2,a3)
      DOS_PRINT (CrLf,pc)
    bra loop
  9:
  cmpi.l #-1,d0
  bne error
exit:
  DOS _EXIT

error:
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 512


.end ProgramStart

.title dos_fgetc - DOS _FGETC

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
        sne d6  ;標準入力ならd6.b=$ff
  bra @f
  filenameSpecified:
    clr -(sp)
    pea (a0)
    DOS _OPEN
    addq.l #6,sp
    move.l d0,d7
    bpl @f
      move.l d0,d1
      DOS_PRINT (OpenErrorMessage,pc)
      move.l d1,d0
      bra error
  @@:

  loop:
    move d7,-(sp)
    DOS _FGETC
    addq.l #2,sp
    tst.l d0
    bmi 9f
      tst.b d6
      beq @f
        cmpi #EOF,d0
        beq ctrlZ
        cmpi #CR,d0
        bne @f
          move d0,-(sp)  ;コンソールからCRが入力されたら
          DOS _PUTCHAR   ;CR LFを出力する
          addq.l #2,sp
          moveq #LF,d0
      @@:
      move d0,-(sp)
      DOS _PUTCHAR
      addq.l #2,sp
    bra loop
  9:
  cmpi.l #-1,d0
  beq exit  ;d0.l=-1ならファイル末尾に到達した
    move.l d0,d1
    DOS_PRINT (ReadErrorMessage,pc)
    move.l d1,d0
    bra error

ctrlZ:
  DOS_PRINT (CtrlZMessage,pc)
exit:
  DOS _EXIT

error:
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

OpenErrorMessage: .dc.b 'file open error: ',0
ReadErrorMessage: .dc.b 'file read error: ',0
CtrlZMessage: .dc.b CR,LF,'Ctrl+Zが入力されたので終了します。',CR,LF,0


.end ProgramStart

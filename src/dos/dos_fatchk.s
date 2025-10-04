.title dos_fatchk - DOS _FATCHK

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

.include macro.mac

.include xputil.mac


FATCHK_BUF_SIZE: .equ $fffe


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq NoArgError

  move #FATCHK_BUF_SIZE,-(sp)
  pea (FatChkBuf,pc)
  tas (sp)  ;ori.l #$8000_0000,(sp)
  pea (a0)
  DOS _FATCHK
  lea (10,sp),sp
  move.l d0,d7

  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  move.l d7,d0
  bmi @f
    lea (FatChkBuf,pc),a0
    bsr PrintFatChkData
  @@:
  DOS _EXIT

NoArgError:
  DOS_PRINT (NoArgMessage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


PrintFatChkData:
  PUSH d2/a2
  move.l d0,d2
  lea (a0),a2
  subq.l #2,d2
  bcs 9f

  DOS_PRINT (DriveMessage,pc)
  move (a2)+,d0  ;drive number
  bsr Print$4
  DOS_PRINT_CRLF

  bra 8f
  1:
    move.l (a2)+,d0  ;sector number
    beq 9f

    lea (Buffer,pc),a0
    bsr ToHexString$4_4
    move.b #' ',(a0)+
    move.l (a2)+,d0  ;sector length
    bsr ToHexString$4_4

    lea (CrLf,pc),a1
    STRCPY a1,a0
    DOS_PRINT (Buffer,pc)
  8:
  subq.l #4+4,d2
  bcc 1b
9:
  POP d2/a2
  rts


  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4
  DEFINE_PRINT$4 Print$4
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

NoArgMessage: .dc.b 'no filename',CR,LF,0
CrLf: .dc.b CR,LF,0

DriveMessage: .dc.b 'drive = ',0


.bss
.quad

Buffer: .ds.b 64

.quad
.ds 1
FatChkBuf: .ds.b FATCHK_BUF_SIZE


.end ProgramStart

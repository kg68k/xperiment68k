.title dumpstdin - dump result of DOS _READ from stdin

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

.include macro.mac
.include dosdef.mac
.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


BUFFER_SIZE: .equ 256


.cpu 68000
.text

ProgramStart:
  moveq #STDIN,d0
  bsr IsStdin
  tst.l d0
  beq @f
    DOS_PRINT (Prompt,pc)  ;STDINが標準入力なら"input: "表示
  @@:

  pea (BUFFER_SIZE).w
  pea (ReadBuffer,pc)
  move #STDIN,-(sp)
  DOS _READ
  lea (10,sp),sp
  move.l d0,d6

  DOS_PRINT (Result,pc)  ;DOS _READの返り値を表示
  move.l d6,d0
  lea (Buffer,pc),a0
  FPACK __LTOS
  DOS_PRINT (Buffer,pc)
  DOS_PRINT_CRLF

  move.l d6,d0
  bmi readError
  beq @f
    lea (Buffer,pc),a0  ;入力データを16進数で表示
    lea (ReadBuffer,pc),a1
    bsr StringToHexString
    DOS_PRINT (Buffer,pc)
    DOS_PRINT_CRLF
  @@:

  DOS _EXIT

readError:
  move #STDERR,-(sp)
  pea (ReadError,pc)
  DOS _FPUTS
  move #EXIT_FAILURE,(sp)
  DOS _EXIT2


;指定したファイルハンドルが標準入力デバイスか調べる
IsStdin:
  move d0,-(sp)
  clr -(sp)
  DOS _IOCTRL
  move.l d0,(sp)+
  bmi @f
    tst.b d0
    bpl @f  ;ブロックデバイス
      lsr #1,d0
      bcc @f
        moveq #1,d0  ;標準入力デバイス
        bra 9f
  @@:
  moveq #0,d0
9:
  rts


StringToHexString:
  move.l d7,-(sp)
  move.l d0,d7
  bra 8f
  1:
    move.b #'$',(a0)+
    move.b (a1)+,d0
    bsr ToHexString2
    move.b #' ',(a0)+
8:
  subq.l #1,d7
  bcc 1b
  clr.b -(a0)
  move.l (sp)+,d7
  rts


  DEFINE_TOHEXSTRING2 ToHexString2


.data

Prompt: .dc.b 'input: ',0
Result: .dc.b 'result: ',0
ReadError: .dc.b 'read error',CR,LF,0


.bss
.even

Buffer: .ds.b BUFFER_SIZE*4
ReadBuffer: .ds.b BUFFER_SIZE


.end ProgramStart

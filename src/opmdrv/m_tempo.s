.title m_tempo - OPM _M_TEMPO

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
.include opmdrv.mac
.include console.mac
.include doscall.mac

.include xputil.mac


TEMPO_MIN: .equ 20   ;OPMDRV.X、OPMDRV2.Xでは32
TEMPO_MAX: .equ 300  ;OPMDRV.X、OPMDRV2.Xでは200


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne 1f
    bsr PrintCurrentTempo  ;テンポ省略時は現在値を表示する
    bra @f
  1:
    bsr SetTempo
  @@:
  DOS _EXIT


PrintCurrentTempo:
  moveq #-1,d2
  OPM _M_TEMPO
  cmpi.l #TEMPO_MIN,d0
  bcs 1f
  cmpi.l #TEMPO_MAX,d0
  bhi 1f
    lea (Buffer,pc),a0
    FPACK __LTOS
    DOS_PRINT (Buffer,pc)
    bra @f
  1:
    bsr Print$4_4  ;エラーコードは16進数で表示する
  @@:
  DOS_PRINT (strCrLf,pc)
  rts


SetTempo:
  FPACK __STOL
  bcs NumberError
  move.l d0,d2  ;テンポ
  OPM _M_TEMPO
  bsr Print$4_4
  DOS_PRINT (strCrLf,pc)
  rts


NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 256


.end ProgramStart

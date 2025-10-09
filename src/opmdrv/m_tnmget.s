.title m_tnmget - OPM _M_TNMGET

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
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (NameBuffer,pc),a1

  lea (1,a2),a0
  SKIP_SPACE a0
  cmpi.b #'-',(a0)
  bne @f
    cmpi.b #'k',(1,a0)
    bne @f
      addq.l #2,a0
      addq.l #1,a1  ;-k 指定時はバッファを奇数アドレスにする
  @@:
  SKIP_SPACE a0
  bne @f
    bsr PrintAllToneNames
    bra 9f
  @@:
    bsr ParseInt
    bsr PrintToneName
9:
  DOS _EXIT


PrintToneName:
  move.l d0,d2  ;音色番号

  lea (Buffer,pc),a0
  lea (strD0equ,pc),a2
  STRCPY a2,a0,-1

  OPM _M_TNMGET
  bsr ToHexString$4_4

  lea (strCommaName,pc),a2
  STRCPY a2,a0,-1

  clr.b (O3_TONE_NAME_LEN,a1)
  lea (a1),a2
  STRCPY a2,a0,-1

  lea (strCrLf,pc),a2
  STRCPY a2,a0,-1

  DOS_PRINT (Buffer,pc)
  rts


PrintAllToneNames:
  lea (Buffer,pc),a0
  moveq #FM_TONE_MIN,d7
  @@:
    move.l d7,d0
    bsr ToneNameToString
    addq #1,d7
  cmpi #FM_TONE_MAX,d7
  bls @b

  DOS_PRINT (Buffer,pc)
  rts


ToneNameToString:
  move.l d0,d2  ;音色番号

  moveq #3,d1
  bsr ToDecStringWidth
  lea (strColon,pc),a2
  STRCPY a2,a0,-1

  OPM _M_TNMGET
  tst.l d0
  beq 1f
    lea (strD0equ,pc),a2  ;エラー時はエラーコードを表示
    STRCPY a2,a0,-1
    bsr ToHexString$4_4
    bra @f
  1:
    clr.b (O3_TONE_NAME_LEN,a1)
    lea (a1),a2
    STRCPY a2,a0,-1
  @@:
  lea (strCrLf,pc),a2
  STRCPY a2,a0,-1
  rts


  DEFINE_TODECSTRINGWIDTH ToDecStringWidth
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4
  DEFINE_PARSEINT ParseInt


.data

strColon: .dc.b ': ',0
strD0equ: .dc.b 'd0.l = ',0
strCommaName: .dc.b ', name = ',0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 4096

.even
NameBuffer:
  .ds.b O3_TONE_NAME_LEN  ;音色名
  .ds.b 1  ;NUL終端
  .ds.b 1  ;-k指定時にバッファ先頭を1バイトずらして奇数バイトにする分


.end ProgramStart

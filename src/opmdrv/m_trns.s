.title m_trns - OPM _M_TRNS

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
.include fefunc.mac
.include opmdrv.mac

.include xputil.mac

CHANNEL_NO_MIN: .equ 1
CHANNEL_NO_MAX: .equ 25
CHANNEL_COUNT:  .equ 25

TRNS_MIN: .equ 0
TRNS_MAX: .equ 48


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    bsr PrintAllChannels  ;引数省略時は全チャンネルのベロシティを表示
    bra 9f
  @@:
    bsr ParseIntWord
    move d0,d2  ;チャンネル番号
    swap d2
    move #-1,d2  ;トランスポーズ省略時は設定取得
    SKIP_SPACE a0
    beq @f
      bsr ParseIntWord
      move d0,d2  ;トランスポーズ
  @@:
  OPM _M_TRNS
  bsr Print$4_4
  DOS_PRINT_CRLF
9:
  DOS _EXIT


PrintAllChannels:
  PUSH d6-d7
  lea (Buffer,pc),a0
  lea (strHeader,pc),a1
  STRCPY a1,a0,-1

  moveq #CHANNEL_COUNT-1,d7
  moveq.l #CHANNEL_NO_MIN,d6
  1:
    move.l d6,d0
    moveq #2,d1
    FPACK __IUSING
    lea (strColon,pc),a1
    STRCPY a1,a0,-1

    moveq #-1,d2
    move d6,d2
    swap d2  ;上位ワード=チャンネル番号、下位ワード=$ffff
    OPM _M_TRNS

    .fail TRNS_MIN.ne.0
    cmpi.l #TRNS_MAX,d0
    bhi @f
      FPACK __LTOS
      bra 8f
    @@:
      bsr ToHexString$4_4  ;エラーコードは16進数で表示する
    8:
    lea (strCrLf,pc),a1
    STRCPY a1,a0,-1

    addq #1,d6
  dbra d7,1b

  clr.b (a0)
  DOS_PRINT (Buffer,pc)
  POP d6-d7
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4
  DEFINE_PRINT$4_4 Print$4_4


.data

strHeader: .dc.b 'Ch: Transpose',CR,LF,0
strColon: .dc.b ': ',0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 1024


.end ProgramStart

.title m_chan - OPM _M_CHAN

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
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    bsr PrintAllChannels  ;引数省略時は全チャンネルの設定を表示
    bra 9f
  @@:
    bsr ParseIntWord
    move d0,d2  ;チャンネル番号
    swap d2
    move #O3_CHAN_INQUIRY,d2  ;出力チャンネル省略時は設定取得
    SKIP_SPACE a0
    beq @f
      bsr ParseIntWord
      move d0,d2  ;出力チャンネル番号
  @@:
  OPM _M_CHAN
  bsr Print$4_4
  DOS_PRINT_CRLF
9:
  DOS _EXIT


PrintAllChannels:
  PUSH d6-d7
  lea (Buffer,pc),a0
  lea (strHeader,pc),a1
  STRCPY a1,a0,-1

  moveq #O3_CHANNEL_COUNT-1,d7
  moveq.l #O3_CHANNEL_MIN,d6
  1:
    move.l d6,d0
    moveq #2,d1
    FPACK __IUSING
    lea (strArrow,pc),a1
    STRCPY a1,a0,-1

    move d6,d2  ;チャンネル番号
    swap d2
    move #O3_CHAN_INQUIRY,d2
    OPM _M_CHAN

    cmpi.l #O3_CHANNEL_MIN,d0
    bcs @f
    cmpi.l #O3_CHANNEL_MAX,d0
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

strHeader: .dc.b 'Ch -> Output Ch',CR,LF,0
strArrow: .dc.b ' -> ',0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 1024


.end ProgramStart

.title si_midi - show information: midi board

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


MIDI1_EAFA00_BASE: .equ $eafa00
MIDI2_EAFA10_BASE: .equ $eafa10

YM3802_R00_IVR: .equ $1
YM3802_R01_RGR: .equ $3
YM3802_R02_ISR: .equ $5
YM3802_R03_ICR: .equ $7
YM3802_GRP4:    .equ $9
YM3802_GRP5:    .equ $b
YM3802_GRP6:    .equ $d
YM3802_GRP7:    .equ $f

MIDIORI_VER_STR_LEN: .equ 32

MIDI_NONE:    .equ 0
MIDI_CZ6BM1:  .equ 1
MIDI_MIDIORI: .equ 2
.fail MIDI_NONE.ne.0


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  moveq #0,d0
  bsr PrintMidi
  move.l d0,d7

  moveq #1,d0
  bsr PrintMidi
  add.l d0,d7
  bne @f
    lea (strNotInst,pc),a0
    bsr PrintMidiSub
  @@:
  DOS _EXIT

PrintMidi:
  lea (strBuf,pc),a0
  bsr MidiBoard_GetString
  tst.l d0
  beq 9f

  bsr PrintMidiSub
  moveq #1,d0
9:
  rts

PrintMidiSub:
  pea (strBoard,pc)
  DOS _PRINT
  move.l a0,(sp)
  DOS _PRINT
  pea (strCrLf,pc)
  DOS _PRINT
  addq.l #8,sp
  rts

.data
strBoard: .dc.b 'optional board: ',0
strNotInst: .dc.b 'not installed',0
strCrLf: .dc.b CR,LF,0
.bss
.even
strBuf: .ds.b 256
.text


;MIDIボードの種類を返す。
;  スーパーバイザモードで呼び出すこと。
;in d0.l ... ID(0,1)
;   a0.l ... midioriバージョン文字列を格納するバッファ(0ならCZ-6BM1とmidioriの判別をしない)
;out d0.l ... 種類
MidiBoard_GetType:
  PUSH d7/a0-a1
  lea (a0),a1

  move.l d0,d7
  lea (MIDI1_EAFA00_BASE+YM3802_R00_IVR),a0
  beq @f
    subq.l #1,d0
    lea (MIDI2_EAFA10_BASE-MIDI1_EAFA00_BASE,a0),a0
    bhi 8f
  @@:
  bsr DosBusErrByte
  bne 8f

  move.l a1,d0
  beq 1f  ;バッファを指定されていなければmidioriの判別をしない
  bsr getMidioriVerStr
  beq 1f
    moveq #MIDI_MIDIORI,d0
    bra 9f
  1:
    moveq #MIDI_CZ6BM1,d0
    bra 9f
8:
  moveq #MIDI_NONE,d0
9:
  POP d7/a0-a1
  rts


;midioriのバージョン文字列を読み込む
;in a0.l ... YM3802 R00のアドレス
;   a1.l ... バッファ(32バイト)
;out d0/ccr
;break d1/a1
getMidioriVerStr:
  moveq #0,d0
  moveq #4-1,d1
  bsr readVer
  cmpi.l #'midi',(-4,a1)
  bne 8f

  moveq #4-1,d1
  bsr readVer
  cmpi.l #'ori ',(-4,a1)
  bne 8f

  moveq #(MIDIORI_VER_STR_LEN-8)-1,d1
  bsr readVer
  clr.b -(a1)  ;念の為末尾をNULにする
  moveq #1,d0
  bra 9f
8:
  moveq #0,d0
9:
  rts

readVer:
@@:
  PUSH_SR_DI
  move.b #$f0>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b d0,($04*2,a0)     ;レジスタ$f4にインデックスを書く
  move.b ($05*2,a0),(a1)+  ;レジスタ$f5から文字を読む
  POP_SR
  addq.b #1,d0
  dbra d1,@b
  rts


;MIDIボードの種類を返す。
;  指定したバッファに種類の文字列を書き込む。
;  その他制限はMidiBoard_GetTypeと同じ。
;in
;  d0.l ... ID(0,1)
;  a0.l ... 文字列バッファ
;out
;  d0.l ... Model_GetTypeと同じ
MidiBoard_GetString:
  PUSH d5-d7/a0-a2
  link a6,#-MIDIORI_VER_STR_LEN
  move.l d0,d7
  lea (a0),a2
  clr.b  (a2)

  lea (sp),a0
  bsr MidiBoard_GetType
  move.l d0,d6
  beq 9f

  lea (strAddr1,pc),a1
  beq @f
    lea (strAddr2,pc),a1
  @@:
  STRCPY a1,a2
  subq.l #1,a2

  moveq #MIDI_CZ6BM1,d0
  cmp.l d0,d6
  bhi 2f
    ;凡例 $00eafa00-$00eafa0f CZ-6BM1 compatible (#1)
    lea (strCz6bm1,pc),a1
    STRCPY a1,a2
    subq.l #1,a2
    lea (strId1,pc),a1
    tst.l d7
    beq @f
      addq.l #strId2-strId1,a1
    @@:
    bra 3f
  2:
    ;凡例 $00eafa00-$00eafa0f midiori midiori_version_string
    ;midioriは$00eafa00-$00eafa0f固定なのでIDは表示しない。
    ;バージョン文字列が'midiori 'からはじまるのでstrMidioriは削除した方がよいかも。
    lea (strMidiori,pc),a1
    STRCPY a1,a2
    move.b #' ',(-1,a2)
    lea (sp),a1
  3:
    STRCPY a1,a2
9:
  move.l d6,d0
  unlk a6
  POP d5-d7/a0-a2
  rts

.data
strAddr1: .dc.b '$00eafa00-$00eafa0f ',0
strAddr2: .dc.b '$00eafa10-$00eafa1f ',0
strCz6bm1:  .dc.b 'CZ-6BM1',0
strMidiori: .dc.b 'midiori',0
strId1: .dc.b ' (#1)',0
strId2: .dc.b ' (#2)',0
.text


  DEFINE_DOSBUSERRBYTE DosBusErrByte


.end ProgramStart

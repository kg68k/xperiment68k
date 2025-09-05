.title beep_zmsc3 - play beep with Z-MUSIC v3 ZM_SE_ADPCM1($13)

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
.include console.mac
.include doscall.mac
.include iocscall.mac
.include iocswork.mac

.include xputil.mac

TRAP3_VEC: .equ $23

ZM_SE_ADPCM1: .equ $13

Z_MUSIC: .macro n
  moveq #n,d0
  trap #3
.endm

PLAY_FMT:  .equ $ff  ;ADPCM
PLAY_VOL:  .equ 64
PLAY_FREQ: .equ 4
PLAY_PAN:  .equ 3


.cpu 68000
.text

ProgramStart:
  pea (GetZmsc3Version,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  tst.l d0
  bpl @f
    DOS_PRINT (NoZmsc3Message,pc)
    bra exit
  @@:

  pea (GetBeepData,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  bsr IsValidBeepData
  bne @f
    DOS_PRINT (InvalidBeepDataMessage,pc)
    bra exit
  @@:

  bsr PrintUsage
  bsr MainLoop
exit:
  DOS _EXIT


MainLoop:
  PUSH d4-d7/a6
  move.l d2,d6
  movea.l a1,a6
  moveq #0,d5  ;優先度

  bra loopNext
  loop:
    move.l d1,d5

    move.l d5,d4
    swap d4  ;優先度
    move d0,d4  ;チャンネル番号

    move.l #PLAY_FMT<<24+PLAY_VOL<<16+PLAY_FREQ<<8+PLAY_PAN,d1
    move.l d6,d2
    movea.l a6,a1
    Z_MUSIC ZM_SE_ADPCM1

    bsr Print$4_4
    DOS_PRINT (CrLf,pc)
  loopNext:
  move.l d5,d0
  bsr getPlayChannel
  bpl loop

  POP d4-d7/a6
  rts


PrintUsage:
  DOS_PRINT (Usage,pc)
  rts


getPlayChannel:
  move.l d0,d1  ;優先度
  bra 2f
1:
  DOS _CHANGE_PR
2:
  IOCS _B_KEYSNS
  tst.l d0
  beq 1b
  IOCS _B_KEYINP
  tst.b d0
  beq 2b

  cmpi.b #'?',d0
  bne @f
    bsr PrintUsage
    bra 2b
  @@:
  cmpi.b #'q',d0
  bne @f
    moveq #-1,d0  ;終了
    rts
  @@:
  cmpi.b #' ',d0
  bne @f
    moveq #$e0,d0  ;空きチャンネル
    bra 9f
  @@:
  cmpi.b #$0d,d0
  bne @f
    moveq #$ff,d0  ;全チャンネル
    bra 9f
  @@:
  cmpi.b #'0',d0
  bcs @f
  cmpi.b #'9',d0
  bhi @f
    subi.b #'0',d0  ;指定チャンネル(0-9)
    bra 9f
  @@:
  cmpi.b #'a',d0
  bcs @f
  cmpi.b #'f',d0
  bhi @f
    subi.b #'a'-10,d0  ;指定チャンネル(10-15)
    bra 9f
  @@:
  cmpi.b #'+',d0
  bne @f
    cmpi #255,d1
    bcc 2b
      addq #1,d1  ;優先度を大きくする
    bra 2b
  @@:
  cmpi.b #'-',d0
  bne @f
    tst d1
    beq 2b
      subq #1,d1  ;優先度を小さくする
    bra 2b
  @@:
  9:
  andi.l #$ff,d0
  rts


GetZmsc3Version:
  movea.l (TRAP3_VEC*4).w,a0
  moveq #0,d0
  move -(a0),d0  ;バージョン番号 3.21 -> $3241
  cmpi #'iC',-(a0)
  bne @f
  cmpi.l #'ZmuS',-(a0)
  bne @f
  cmpi #$3000,d0
  bcc 9f
    @@:
    moveq #-1,d0
9:
  rts


;システムに登録されているビープ音の情報を取得する
;out  d2.l  バイト数($ffff以下)
;     a1.l  アドレス
GetBeepData:
  moveq #0,d2
  move (BEEPLEN).w,d2
  movea.l (BEEPADR).w,a1
  rts

IsValidBeepData:
  tst.l d2
  beq @f
  move.l a1,d0
  beq @f
    moveq #1,d0
    rts
  @@:
  moveq #0,d0
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

Usage:
  .dc.b 'キー操作:',CR,LF
  .dc.b '  0-9,a-f: 指定チャンネルで再生, +: 優先度大, -: 優先度小',CR,LF
  .dc.b '  (非公式動作) SPACE: 空きチャンネルで再生, CR: 全チャンネルで再生(音量注意)',CR,LF
  .dc.b '  q: 終了',CR,LF
  .dc.b 0

NoZmsc3Message: .dc.b 'ZMSC3.Xが組み込まれていません。',CR,LF,0
InvalidBeepDataMessage: .dc.b 'BEEP音データが登録されていません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart

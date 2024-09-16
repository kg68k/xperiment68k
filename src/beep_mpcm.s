.title beep_mpcm - play beep with MPCM M_EFCT_OUT($10xx)

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
.include vector.mac
.include console.mac
.include doscall.mac
.include iocscall.mac
.include iocswork.mac

.include xputil.mac


M_EFCT_OUT: .equ $1000

PLAY_FMT:  .equ $ff  ;ADPCM
PLAY_VOL:  .equ 64
PLAY_FREQ: .equ 4
PLAY_PAN:  .equ 3


.cpu 68000
.text

ProgramStart:
  pea (GetMpcmVersion,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  tst.l d0
  bpl @f
    DOS_PRINT (NoMpcmMessage,pc)
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
  PUSH d5-d7/a6
  move.l d2,d6
  movea.l a1,a6

  bra loopNext
  loop:
    ori.l #$dead0000,d0   ;ダミーデータ
    move.l #$beef0000,d7  ;

    ori #M_EFCT_OUT,d0
    move.l #PLAY_FMT<<24+PLAY_VOL<<16+PLAY_FREQ<<8+PLAY_PAN,d1
    move.l d6,d2
    movea.l a6,a1
    trap #1  ;MPCMファンクションコール呼び出し

    bsr Print$4_4
    DOS_PRINT_CRLF
  loopNext:
  bsr getPlayChannel
  bpl loop

  POP d5-d7/a6
  rts


PrintUsage:
  DOS_PRINT (Usage,pc)
  rts


@@:
  DOS _CHANGE_PR
getPlayChannel:
  IOCS _B_KEYSNS
  tst.l d0
  beq @b
  IOCS _B_KEYINP
  tst.b d0
  beq getPlayChannel

  cmpi.b #'?',d0
  bne @f
    bsr PrintUsage
    bra getPlayChannel
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
  subi.b #'0',d0  ;指定チャンネル
  cmpi.b #8,d0    ;有効なのは0～7だが、テスト用に8も受け付ける
  bhi getPlayChannel
  9:
  andi.l #$ff,d0
  rts


GetMpcmVersion:
  movea.l (TRAP1_VEC*4).w,a0
  move.l -(a0),d0  ;'/???' バージョン番号
  cmpi.b #'/',(a0)
  bne @f
  cmpi.l #'MPCM',-(a0)
  beq 9f
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
  .dc.b '  0-8: 指定チャンネルで再生, SPACE: 空きチャンネルで再生, CR: 全チャンネルで再生(音量注意)',CR,LF
  .dc.b '  q: 終了',CR,LF,0

NoMpcmMessage: .dc.b 'MPCMが組み込まれていません。',CR,LF,0
InvalidBeepDataMessage: .dc.b 'BEEP音データが登録されていません。',CR,LF,0


.end ProgramStart

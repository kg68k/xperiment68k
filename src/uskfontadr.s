.title uskfontadr - show uskfont address

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

.include console.mac
.include doscall.mac
.include iocswork.mac

.include xputil.mac

HUMAN_SYS_LOAD_ADDRESS: .equ $6800


.cpu 68000
.text

Start:
  lea (Start,pc),a0
  cmpa #HUMAN_SYS_LOAD_ADDRESS,a0
  beq @f
    ;コマンドラインから実行された場合
    lea (DosPrintA1,pc),a2
    bsr PrintUskFontAddressAll
    DOS _EXIT
  @@:
  ;IPLから偽装HUMAN.SYSとして直接読み込まれた場合
  lea (IocsPrintA1,pc),a2
  bsr PrintUskFontAddressAll

  lea (RebootMessage,pc),a1
  jsr (a2)
  @@: bra @b  ;無限ループでユーザーによる再起動を待つ


DosPrintA1:
  DOS_PRINT (a1)
  rts

IocsPrintA1:
  IOCS _B_PRINT
  rts


PrintUskFontAddressAll:
  lea (UskFontList,pc),a3
  @@:
    move (a3)+,d0
    beq @f
      lea (-2,a3,d0.w),a1  ;ヘッダ文字列
      movea (a3)+,a0       ;フォントアドレス
      bsr PrintUskFontAddress
    bra @b
  @@:
  rts

PrintUskFontAddress:
  jsr (a2)  ;ヘッダ文字列を表示

  lea (a0),a1
  IOCS _B_LPEEK
  lea (Buffer,pc),a0
  bsr ToHexString8
  lea (Buffer,pc),a1
  jsr (a2)  ;アドレスを表示

  lea (CrLf,pc),a1
  jsr (a2)
  rts

  DEFINE_TOHEXSTRING8 ToHexString8


.data
.even

UskFontList:
  .dc UskFont0-$,USKFONT0
  .dc UskFont1-$,USKFONT1
  .dc UskFont2-$,USKFONT2
  .dc UskFont3-$,USKFONT3
  .dc UskFont4-$,USKFONT4
  .dc UskFont5-$,USKFONT5
  .dc 0

UskFont0: .dc.b 'グループ0 (全角 16x16, SJIS:869f～879e JIS:2c21～2d7e): $',0
UskFont1: .dc.b 'グループ1 (全角 16x16, SJIS:eb9f～ec9e JIS:7621～777e): $',0
UskFont2: .dc.b 'グループ2 (半角  8x16, SJIS:f400～f5ff               ): $',0
UskFont3: .dc.b 'グループ3 (全角 24x24, SJIS:869f～879e JIS:2c21～2d7e): $',0
UskFont4: .dc.b 'グループ4 (全角 24x24, SJIS:eb9f～ec9e JIS:7621～777e): $',0
UskFont5: .dc.b 'グループ5 (半角 12x24, SJIS:f400～f5ff               ): $',0

RebootMessage:
      .dc.b CR,LF,'終了しました。フロッピーディスクを抜いて再起動してください。'
CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 64


.end

.title gaiji_ttl - print title with gaiji characters

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
.include filesys.mac

.include xputil.mac


.offset 0
FNTBUF16_X_DOTS:  .ds.w 1
FNTBUF16_Y_DOTS:  .ds.w 1
FNTBUF16_PATTERN: .ds.b 2*16
sizeof_FNTBUF16:
.text


GAIJI_CHARS:  .equ 3
GAIJI_CODE:   .equ $879c

DCB_CHARS: .macro code,len
  @code:=code
  .rept len
    .dc.b @code>>8,@code.and.$ff
    @code:=@code+1
  .endm
.endm


.cpu 68000
.text

ProgramStart:
  lea (strTitle1,pc),a0
  lea (strTitle1Gaiji,pc),a1
  lea (strTitle2,pc),a2
  bsr PrintTitle
  DOS _EXIT


PrintTitle:
  DOS_PRINT (a0)  ;標準文字のタイトルを表示

  moveq #STDOUT,d0
  bsr isStdOut
  beq @f
    DOS_PRINT (a2)  ;リダイレクトされていればコピーライトを表示して終わり
    rts
  @@:

  PUSH a1-a2
  move.l #8<<16+GAIJI_CODE,d1  ;フォントサイズ 16x16ドット
  moveq #GAIJI_CHARS-1,d2
  lea (GaijiFonts,pc),a0
  lea (GaijiSaveBuffer,pc),a1
  bsr SaveAndDefineGaiji
  POP a1-a2

  DOS_PRINT (a1)  ;標準文字のタイトルを外字タイトルで上書き
  DOS_PRINT (a2)  ;コピーライトを表示

  move.l #8<<16+GAIJI_CODE,d1
  moveq #GAIJI_CHARS-1,d2
  lea (GaijiSaveBuffer,pc),a1
  bsr RestoreGaiji
  rts


SaveAndDefineGaiji:
  @@:
    IOCS _FNTGET
    lea (sizeof_FNTBUF16,a1),a1
    exg a0,a1

    IOCS _DEFCHR
    addq #1,d1
    lea (2*16,a1),a1
    exg a0,a1
  dbra d2,@b
  rts

RestoreGaiji:
  addq.l #FNTBUF16_PATTERN,a1  ;Xドット数とYドット数を飛ばす
  @@:
    IOCS _DEFCHR
    addq #1,d1
    lea (sizeof_FNTBUF16,a1),a1
  dbra d2,@b
  rts


isStdOut:
  move d0,-(sp)
  clr -(sp)
  DOS _IOCTRL
  move.l d0,(sp)+
  bmi 9f
    andi #$8002,d0
    cmpi #$8002,d0  ;キャラクタデバイスかつ標準出力(CON)デバイスか？
    bne 9f
      moveq #0,d0
      rts
9:
  moveq #-1,d0
  rts


.data

.even
GaijiFonts:
.irp DC_OP,<.dc w0>,<.dc w1>,<.dc w2>
  GF: .macro w0,w1,w2
    DC_OP
  .endm

  GF %0000000000000000,%0000000000000000,%0000000000000000
  GF %0011111111111111,%1111000111111111,%1111111111111100
  GF %0011111111111111,%1111000111111111,%1111111111111100
  GF %0011000000000000,%0011000110000000,%0000000000001100
  GF %0011000000000000,%0011000110000000,%0000000000001100
  GF %0011000111111110,%0011000110001111,%1111111110001100
  GF %0011000111111110,%0011000110001111,%1111111110001100
  GF %0011000110000000,%0011000110001100,%0000000110001100
  GF %0011000110000000,%0011000110001100,%0000000110001100
  GF %0011000111111111,%1111000110001100,%0111111110001100
  GF %0011000111111111,%1111000110001100,%0111111110001100
  GF %0011000000000000,%0000000110001100,%0000000000001100
  GF %0011000000000000,%0000000110001100,%0000000000001100
  GF %0011111111111111,%1111111110001111,%1111111111111100
  GF %0011111111111111,%1111111110001111,%1111111111111100
  GF %0000000000000000,%0000000000000000,%0000000000000000
.endm

strTitle1:
  .dc.b 'RaiMon',0

strTitle1Gaiji:
  .dc.b ESC,'[','0'+GAIJI_CHARS*2,'D'  ;左へ移動
  DCB_CHARS GAIJI_CODE,GAIJI_CHARS
  .dcb.b GAIJI_CHARS*2,BS              ;condrvのバックログから外字を削除する
  .dc.b ESC,'[','0'+GAIJI_CHARS*2,'C'  ;右へ移動
  .dc.b 0

strTitle2:
  .dc.b ' version 1.0.0  Copyright (C) 2025 TcbnErik.',CR,LF,0


.bss
.even

GaijiSaveBuffer:
  .ds.b sizeof_FNTBUF16*GAIJI_CHARS


.end

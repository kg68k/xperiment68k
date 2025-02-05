.title zmsc2_gettrktbl - show Z-MUSIC get_trk_tbl result

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
.include vector.mac
.include console.mac
.include doscall.mac

.include xputil.mac


ZM_GET_TRK_TBL: .equ $3a

ZMUSIC: .macro no
  moveq #no,d1
  trap #3
.endm


.cpu 68000
.text

ProgramStart:
  bsr IsZmusic2Resident
  bne @f
    DOS_PRINT (strZmusic2IsNotResident,pc)
    DOS _EXIT
  @@:

  ZMUSIC ZM_GET_TRK_TBL
  move.l d0,d6  ;絶対チャンネルテーブルのアドレス
  move.l a0,d7  ;演奏トラックテーブルのアドレス

  DOS_PRINT (strChannelTable,pc)
  move.l d6,d0
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  movea.l d6,a0
  bsr PrintChannelTable

  DOS_PRINT (strTrackTable,pc)
  move.l d7,d0
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  movea.l d7,a0
  bsr PrintTrackTable

  DOS _EXIT


PrintChannelTable:
  link a6,#-256
  moveq #32,d0  ;要素数(固定)
  lea (a0),a1  ;テーブル(スーパーバイザ領域の可能性あり)
  lea (sp),a0  ;文字列バッファ

  pea (StringifyChannelTable,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  DOS_PRINT (strTableHeader,pc)
  DOS_PRINT (sp)
  DOS_PRINT (strTableFooter,pc)
  unlk a6
  rts

StringifyChannelTable:
  move d0,d1
  subq #1,d1
  @@:
    moveq #0,d0
    move.b (a1)+,d0
    bsr Uint8ToDecimal
    move.b #',',(a0)+
  dbra d1,@b
  clr.b -(a0)  ;最後の','を消す
  rts


PrintTrackTable:
  link a6,#-256
  moveq #32+1,d0  ;最大要素数(最大32 + 終端の$ff)
  lea (a0),a1  ;テーブル(スーパーバイザ領域の可能性あり)
  lea (sp),a0  ;文字列バッファ

  pea (StringifyTrackTable,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  DOS_PRINT (strTableHeader,pc)
  DOS_PRINT (sp)
  DOS_PRINT (strTableFooter,pc)
  unlk a6
  rts

StringifyTrackTable:
  move d0,d1
  subq #1,d1
  lea (strDollarFF,pc),a2
  @@:
    moveq #0,d0
    move.b (a1)+,d0
    cmpi.b #$ff,d0
    beq 8f  ;$ffでテーブル終了

    bsr Uint8ToDecimal
    move.b #',',(a0)+
  dbra d1,@b
  lea (strEllipsis,pc),a2
  8:
  STRCPY a2,a0
  rts


Uint8ToDecimal:
  divu #100,d0
  beq @f
    addi.b #'0',d0
    move.b d0,(a0)+  ;100の位
    clr d0
    swap d0
    divu #10,d0
    bra 2f
  @@:
  clr d0
  swap d0
  divu #10,d0
  beq @f
  2:
    addi.b #'0',d0
    move.b d0,(a0)+  ;10の位
  @@:
  swap d0
  addi.b #'0',d0
  move.b d0,(a0)+  ;1の位
  clr.b (a0)
  rts


IsZmusic2Resident:
  pea (GetZmusicVersion,pc)
  DOS _SUPER_JSR
  move.l d0,(sp)+
  bmi @f
    andi #$f000,d0  ;バージョン整数部
    cmpi #$2000,d0
    bne @f
      moveq #1,d0
      rts
  @@:
  moveq #0,d0
  rts

GetZmusicVersion:
  movea.l (TRAP3_VEC*4).w,a0
  moveq #0,d0
  move -(a0),d0  ;(常駐していれば)バージョン番号
  cmpi #'iC',-(a0)
  bne @f
    cmpi.l #'ZmuS',-(a0)
    beq 9f
    @@:
      moveq #-1,d0
9:
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

strChannelTable:
  .dc.b '絶対チャンネルテーブル',CR,LF
  .dc.b '  d0.l = ',0
strTrackTable:
  .dc.b '演奏トラックテーブル',CR,LF
  .dc.b '  a0.l = ',0

strTableHeader: .dc.b '  [',0
strTableFooter: .dc.b ']',CR,LF,0
strDollarFF: .dc.b '$ff',0
strEllipsis: .dc.b '...',0

strZmusic2IsNotResident:
  .dc.b 'Z-MUSIC v2が常駐していません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart

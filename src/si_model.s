.title si_model - show information: model

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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

.include xputil.mac


SYSTEM_PORT6_E8E00B: .equ $e8e00b
SPC_E9602D_SSTS:     .equ $e9602d

XEIJ_E9F03C_HFS_MAGIC: .equ $e9f03c

PHANTOMX_EA8000_REG:  .equ $ea8000

MODEL_UNIDENTIFIED:      .equ  0
MODEL_UNIDENTIFIED_SASI: .equ  1  ;初代/ACE/EXPERT/PRO
MODEL_UNIDENTIFIED_SCSI: .equ  2  ;SUPER/XVI/Compact
MODEL_UNIDENTIFIED_XVI:  .equ  3  ;XVI/Compact
MODEL_X68000:            .equ  4  ;初代
MODEL_X68000_SERIES:     .equ  5  ;ACE/EXPERT/PRO
MODEL_PRO:               .equ  6  ;GetType が返すことはない
MODEL_SUPER:             .equ  7
MODEL_XVI:               .equ  8
MODEL_COMPACT:           .equ  9
MODEL_X68020:            .equ 10
MODEL_X68030:            .equ 11  ;X68030/X68030 Compact
MODEL_HYBRID:            .equ 12  ;XEiJ X68000 SCSI + ROM1.5-


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  bsr Model_GetType
  lea (strBuf,pc),a0
  bsr Model_ToString
  lea (strBuf,pc),a0
  bsr PrintModel

  DOS _EXIT

PrintModel:
  pea (strModel,pc)
  DOS _PRINT
  move.l a0,(sp)
  DOS _PRINT
  pea (strCrLf,pc)
  DOS _PRINT
  addq.l #8,sp
  rts

.data
strModel: .dc.b 'Model: ',0
strCrLf: .dc.b CR,LF,0
.bss
.even
strBuf: .ds.b 256
.text


;機種を調べる。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 種類
Model_GetType::
  PUSH d1-d2/a0
  move.b (SYSTEM_PORT6_E8E00B),d1
  cmpi.b #$fe,d1
  beq getType16mhz
  bhi getType10mhz

    bsr isPhantomX
    bne getType10mhz

      moveq #MODEL_X68030,d0
      cmpi.b #$dc,d1
      beq 9f

      moveq #MODEL_X68020,d0
      cmpi.b #$ec,d1
      beq 9f

      moveq #MODEL_UNIDENTIFIED,d0
      bra 9f

  ;SystemPort6==$fe ... XVI/Compactの16MHzモード
  getType16mhz:
    bsr getTypeXvi
    bra 9f

  ;SystemPort6==$ff ... 初代～SUPER、またはXVI/Compactの10MHzモード
  getType10mhz:
    bsr isScsiModel
    beq @f
      ;SCSI内蔵機種 ... SUPER、またはXVI/Compactの10MHzモード
      bsr getTypeScsi
      bra 9f
    @@:
    bsr getTypeSasi
9:
  POP d1-d2/a0
  rts


;SCSI内蔵機種か判別する。
;out d0/ccr, break a0
;参考: https://twitter.com/kamadox/status/1341647471433289728
;  $e9602dはSCSI内蔵機種におけるSPCのSSTSレジスタ。$ffの値をとることはない。
;  SASI内蔵機種でこのアドレスを読むと、$e96005のSASIリセットポートが
;  読み込まれる。常に$ff。
isScsiModel:
  lea (SPC_E9602D_SSTS),a0
  bsr DosBusErrByte
  bne @f  ;XEiJ 0.21.01.11のSASI内蔵機種でバスエラーになる対策
  not.b d0
  beq @f
    moveq #1,d0
    rts
  @@:
  moveq #0,d0
  rts


;SCSI内蔵機種 SUPER/XVI/Compact/Hybridを判別する。
;out d0, break d1-d2/a0
getTypeScsi:
  moveq #MODEL_UNIDENTIFIED_SCSI,d0
  lea (romVerTableScsi,pc),a0
  bra getTypeByRomVer


;クロックスイッチ16MHz機種 XVI/Compact/Hybridを判別する。
;out d0, break d1-d2/a0
getTypeXvi:
  moveq #MODEL_UNIDENTIFIED_XVI,d0
  lea (romVerTableXvi,pc),a0
  bra getTypeByRomVer


;ROMバージョンによって判別する(Hybrid対応)。
;in
;  d0.l ... 判別不能時に返す値(MODEL_UNIDENTIFIED_***)
;  a0.l ... ROMバージョンテーブル
;out d0, break d1-d2/a0
getTypeByRomVer:
  move.l d0,d2
  move.l ($ff000a),d1
  @@:
    move (a0)+,d0
    bmi 8f
  cmp.l (a0)+,d1
  bne @b
  bra 9f
8:
  lea ($ff0030),a0
  cmpi #$203C,(a0)+  ;move.l #imm,d0 のオペコード
  bne @f
  cmpi.b #$15,(a0)  ;IPL ROM v1.5以上かどうか
  bcs @f
  bsr isXeij
  beq @f
    moveq #MODEL_HYBRID,d2
  @@:
  move.l d2,d0
9:
  rts

romVerTableScsi:
  .dc MODEL_SUPER,  $10_870507.l
romVerTableXvi:
  .dc MODEL_XVI,    $11_910111.l
  .dc MODEL_COMPACT,$12_911024.l
  .dc -1


;PhantomXか判別する。
;out d0/ccr
isPhantomX:
  lea (PHANTOMX_EA8000_REG),a0
  bsr DosBusErrWord
  beq @f
    moveq #0,d0
    rts
@@:
  moveq #1,d0
  rts


;XEiJか調べる。
;out d0/ccr
isXeij:
  lea (XEIJ_E9F03C_HFS_MAGIC),a0
  bsr DosBusErrLong
  bne @f
    cmpi.l #'JHFS',d0
    bne @f
      moveq #1,d0
      rts
  @@:
  moveq #0,d0
  rts


;SASI内蔵機種 初代(初期型)、初代(後期型)/ACE/EXPERT/PROの判別。
;out d0, break d1
getTypeSasi:
  moveq #MODEL_X68000,d0
  move.l ($ff000a),d1
  cmpi.l #$10_870318,d1  ;X68000 初代(初期型)
  beq 9f

  cmpi.l #$10_870507,d1
  bne @f
    cmpi #$41f9,($ff0c80)  ;X68000 初代(後期型)
    beq 9f

    moveq #MODEL_X68000_SERIES,d0  ;ACE/EXPERT/PRO
    bra 9f
  @@:
  moveq #MODEL_UNIDENTIFIED_SASI,d0  ;未知のROMバージョン
9:
  rts


;機種名を文字列化する。
;in
;  d0.l ... 種類(Model_GetTypeの返り値)
;  a0.l ... 文字列バッファ(今のところ32バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NULを指す)
;break d0
Model_ToString::
  move.l a1,-(sp)

  lea (modelNameOffs,pc,d0.w),a1
  move.b (a1),d0
  adda d0,a1

  STRCPY a1,a0
  subq.l #1,a0

  movea.l (sp)+,a1
  rts

modelNameOffs:
  .dc.b @f-$,1f-$,2f-$,3f-$,4f-$,5f-$,6f-$,7f-$,8f-$,9f-$,10f-$,11f-$,12f-$

@@: .dc.b 'unidentified X680x0',0
1:  .dc.b 'unidentified X68000 SASI',0
2:  .dc.b 'unidentified X68000 SCSI',0
3:  .dc.b 'unidentified X68000 XVI',0
4:  .dc.b 'X68000',0
5:  .dc.b 'X68000 series',0
6:  .dc.b 'X68000 PRO',0
7:  .dc.b 'X68000 SUPER',0
8:  .dc.b 'X68000 XVI',0
9:  .dc.b 'X68000 Compact',0
10: .dc.b 'X68020 prototype',0
11: .dc.b 'X68030',0
12: .dc.b 'X68000 Hybrid',0
.even


  DEFINE_DOSBUSERRBYTE DosBusErrByte
  DEFINE_DOSBUSERRWORD DosBusErrWord
  DEFINE_DOSBUSERRLONG DosBusErrLong


.end ProgramStart

.title opmcallvec - show OPMDRV3.X OPM call vectors

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
.include opmdrv.mac
.include vector.mac

.include xputil.mac


OPMDRVTYPE_NONE: .equ 0
OPMDRVTYPE_1:    .equ 1
OPMDRVTYPE_2:    .equ 2
OPMDRVTYPE_3:    .equ 3


.cpu 68000
.text

ProgramStart:
  moveq #-1,d7  ;コマンドライン引数省略時はすべて表示する
  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    bsr ParseIntWord
    moveq #0,d7
    move d0,d7  ;指定のOPMコール番号のみ表示する
  @@:

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  bsr GetOpmdrvType
  subq.l #OPMDRVTYPE_3,d0
  beq @f
    FATAL_ERROR 'OPMDRV3.Xが組み込まれていません。'
  @@:

  ;IOCS _OPMDRVの処理コードを見てOPMコール番号の最大値を得る。
  ;OPMDRV.X、OPMDRV2.Xでも同じことはできて、さらに処理アドレステーブルを
  ;取り出すこともできるが、とりあえずOPMDRV3.Xのみを対象としている。
  bsr GetOpmCallCount
  move.l d0,d6
  bpl @f
    FATAL_ERROR 'OPMDRV3.XのOPMコール番号の最大値が取得できませんでした。'
  @@:

  moveq #-1,d2  ;処理アドレステーブルのアドレスを得る
  OPM _M_CHGET
  movea.l d0,a5

  tst.l d7
  bmi 1f
    cmp d6,d7
    bcs @f
      FATAL_ERROR '指定したOPMコール番号が大きすぎます。'
    @@:
    move.l d7,d0
    lsl.l #2,d0
    movea.l (a5,d0.l),a0
    move.l d7,d0
    bsr PrintOpmCallVector
    bra 8f
  1:
    move.l d6,d0
    lea (a5),a0
    bsr PrintAllOpmCallVectors
  8:
  DOS _EXIT


GetOpmCallCount:
  movea.l (IOCS_VECTBL+_OPMDRV*4),a0
  cmpi #$b27c,(a0)+  ;cmp #$xxxx,d1
  bne @f
    moveq #0,d0
    move (a0)+,d0  ;OPMコール番号+1
    bgt 9f
    @@:
      moveq #-1,d0
  9:
  rts


;OPMコールの処理アドレスを一覧表示する
;  一括して文字列化してから表示した方が速いが、必要なバッファ容量が
;  事前に分からないので1行ずつ文字列化と表示を行っている。
PrintAllOpmCallVectors:
  PUSH d6-d7/a3
  lea (a0),a3  ;処理アドレステーブル
  move d0,d7  ;コール数(>0)
  moveq #0,d6  ;処理中のOPMコール番号
  bra 8f
  1:
    move.l d6,d0
    movea.l (a3)+,a0
    bsr PrintOpmCallVector
    addq #1,d6
  8:
  dbra d7,1b
  POP d6-d7/a3
  rts


PrintOpmCallVector:
  link a6,#-32
  lea (a0),a1
  lea (sp),a0
  bsr ToHexString$2  ;OPMコール番号
  move.b #':',(a0)+
  move.b #' ',(a0)+

  move.l a1,d0  ;処理アドレス
  bsr ToHexString$4_4
  lea (strCrLf,pc),a1
  STRCPY a1,a0

  DOS_PRINT (sp)
  unlk a6
  rts


;組み込まれているOPMDRV*.Xの種類を得る
;  スーパーバイザモードで呼び出すこと。
GetOpmdrvType:
  bsr GetZmusicVersion
  tst.l d0
  bpl 8f  ;Z-MUSIC v2/v3常駐時はOPMDRVなし

  movea.l ($400+_OPMDRV*4),a0

  move.l a0,d0
  rol.l #8,d0
  cmpi.b #_OPMDRV,d0  ;最上位バイトにコール番号が入っていれば
  beq 8f              ;IOCS _OPMDRVが設定されていない
  rol.l #8,d0
  cmpi #$00ff,d0  ;060turboでは最上位バイトにコール番号が入らないので
  beq 8f          ;IOCS ROMを指していれば未設定とみなす

  OPM _M_VERSION
  move.l d0,d1
  addq.l #1,d0  ;_M_VERSIONが成功すればOPMDRV3.X
  beq @f
    moveq #OPMDRVTYPE_3,d0  ;d1.lはバージョン番号と作成年月日
    bra 9f
  @@:

  bsr idenifyOpmdrv1or2
  moveq #0,d1
  bra 9f
  8:
    moveq #OPMDRVTYPE_NONE,d0
    moveq #0,d1
  9:
  rts


;OPMDRV.XとOPMDRV2.Xの判別をする
;  スーパーバイザモードで呼び出すこと。
;in a0.l IOCS _OPMDRVのアドレス
idenifyOpmdrv1or2:
  cmpi.l #$b2bc_0000,(a0)+  ;cmp.l #$0000_xxxx,d1
  bne 1f
    moveq #OPMDRVTYPE_1,d0
    cmpi #$0010,(a0)  ;_M_BUFSET+1
    beq 9f
      moveq #OPMDRVTYPE_2,d0
      cmpi #$0017,(a0)  ;_MD_STAT+1
      beq 9f
        1:
        moveq #OPMDRVTYPE_NONE,d0
  9:
  rts


;Z-MUSICのバージョン番号を得る
;  スーパーバイザモードで呼び出すこと。
GetZmusicVersion:
  movea.l (TRAP3_VEC*4),a0
  subq.l #8,a0
  moveq #-1,d0
  cmpi.l #'ZmuS',(a0)+
  bne @f
    cmpi #'iC',(a0)+
    bne @f
      moveq #0,d0
      move (a0)+,d0  ;バージョン番号
  @@:
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4


.data

strCrLf: .dc.b CR,LF,0


.end ProgramStart

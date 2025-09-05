.title opmdrvtype - show OPMDRV*.X type and version

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
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


OPMDRVTYPE_NONE: .equ 0
OPMDRVTYPE_1:    .equ 1
OPMDRVTYPE_2:    .equ 2
OPMDRVTYPE_3:    .equ 3


.cpu 68000
.text

ProgramStart:
  pea (GetOpmdrvType,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  bsr dispatch
  DOS_PRINT (a0)

  DOS _EXIT


dispatch:
  move.b (@f,pc,d0.w),d0
  jmp (@f,pc,d0.w)
@@:
  .dc.b noOpmdrv-@b
  .dc.b opmdrv1-@b
  .dc.b opmdrv2-@b
  .dc.b opmdrv3-@b

noOpmdrv:
  lea (strNoOpmdrv,pc),a0
  rts

opmdrv1:
  lea (strOpmdrv1,pc),a0
  rts

opmdrv2:
  lea (strOpmdrv2,pc),a0
  rts

opmdrv3:
  lea (Buffer,pc),a0
  lea (strOpmdrv3,pc),a1
  STRCPY a1,a0,-1

  move.l d1,d0
  bsr bcdToChar  ;バージョン整数部
  move.b #'.',(a0)+
  bsr bcdToChar  ;バージョン小数部

  lea (strDate,pc),a1
  STRCPY a1,a0,-1

  move #'19',d1
  cmpi.l #$80_00_00_00,d0
  bcc 1f
    move.b #'2',(a0)+  ;00～79は20xx年
    move.b #'0',(a0)+
    bra @f
  1:
    move.b #'1',(a0)+  ;80～99は19xx年
    move.b #'9',(a0)+
  @@:

  bsr bcdToChar2  ;年
  move.b #'-',(a0)+
  bsr bcdToChar2  ;月
  move.b #'-',(a0)+
  bsr bcdToChar2  ;日

  lea (strCrLf,pc),a1
  STRCPY a1,a0

  lea (Buffer,pc),a0
  rts

bcdToChar2:
  pea (bcdToChar,pc)
bcdToChar:
  rol.l #4,d0
  moveq #$f,d1
  and.b d0,d1
  addi.b #'0',d1
  move.b d1,(a0)+
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


.data

strNoOpmdrv: .dc.b 'OPMDRV*.Xは組み込まれていません。',CR,LF,0

strOpmdrv1: .dc.b 'OPMDRV.X',CR,LF,0
strOpmdrv2: .dc.b 'OPMDRV2.X',CR,LF,0

strOpmdrv3: .dc.b 'OPMDRV3.X version=',0
strDate:    .dc.b ' date=',0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 256


.end ProgramStart

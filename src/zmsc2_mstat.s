.title zmsc2_mstat - show Z-MUSIC m_stat result

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

.include fefunc.mac
.include vector.mac
.include console.mac
.include doscall.mac

.include xputil.mac


ZM_M_STAT: .equ $09

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

  moveq #0,d2  ;引数省略時は全チャンネル検査
  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    FPACK __STOH  ;16進数で指定(接頭辞なし)
    bcs PrintUsage
    SKIP_SPACE a0
    bne PrintUsage

    move.l d0,d2
  @@:
  ZMUSIC ZM_M_STAT
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT


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

strUsage: .dc.b 'usage: zmsc2_mstat [hex]',CR,LF,0

strZmusic2IsNotResident:
  .dc.b 'Z-MUSIC v2が常駐していません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart

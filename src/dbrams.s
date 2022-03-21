.title dbrams - remeasure $cb8/$cba value

# This file is part of Xperiment68k
# Copyright (C) 2022 TcbnErik
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
.include fefunc.mac
.include console.mac
.include doscall.mac
.include iocscall.mac


MOVEL_IMM_D0: .equ $203C  ;move.l #imm,d0 のオペコード

IOCS_0CB8_ROM_COUNT: .equ $cb8
IOCS_0CBA_RAM_COUNT: .equ $cba


.offset 0
DBRAMS_ERROR_NONE: .ds.b 1
DBRAMS_ERROR_MPU: .ds.b 1
DBRAMS_ERROR_ROMVER10: .ds.b 1
DBRAMS_ERROR_ROMVER: .ds.b 1
DBRAMS_ERROR_CODE: .ds.b 1
DBRAMS_ERROR_MAX:


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  bsr Dbrams_measure
  bne @f
    move.l d1,d0
    bsr Dbrams_getErrorString
    bsr print
    bra 9f
@@:
  move.l d1,(IOCS_0CB8_ROM_COUNT)
  bsr printValue
9:
  DOS _EXIT


printValue:
  lea (strBuf,pc),a0
  lea (strRom,pc),a1
  STRCPY a1,a0
  subq.l #1,a0

  move.l d1,d0
  clr d0
  swap d0
  FPACK __LTOS

  lea (strRam,pc),a1
  STRCPY a1,a0
  subq.l #1,a0

  moveq #0,d0
  move d1,d0
  FPACK __LTOS

  lea (strBuf,pc),a0
  bra print

print:
  pea (a0)
  DOS _PRINT
  pea (strCrLf,pc)
  DOS _PRINT
  addq.l #8,sp
  rts

.data
strCrLf: .dc.b CR,LF,0
strRom: .dc.b 'ROM: ',0
strRam: .dc.b ', RAM: ',0
.bss
.even
strBuf: .ds.b 256
.text


;dbra空ループが1msになる回数を測定する。
;out
;  d0.l ... 0:失敗 1:成功
;  d1.l ... 失敗時、エラーコード。成功時、測定結果。
Dbrams_measure::
  PUSH a0-a1

  bsr getRomVer
  move.l d0,d1
  rol.l #8,d1

  cmpi.b #$10,d1  ;ROM1.0には計測ルーチンがない
  bne @f
    moveq #DBRAMS_ERROR_ROMVER10,d1
    bra 8f
@@:
  lea ($ff0aa6),a0  ;ROM1.1 XVI
  cmpi.b #$11,d1
  beq 5f

  lea ($ff0b54),a0  ;ROM1.2 Compact
  cmpi.b #$12,d1
  beq 5f

  lea ($ff0c4e),a0  ;ROM1.3 X68030
  cmpi.l #$13,d1
  beq 5f
  cmpi.b #$16,d1  ;ROM1.6 XEiJによるROM1.3へのパッチ
  beq 5f

    moveq #DBRAMS_ERROR_ROMVER,d1
    bra 8f
5:
  bsr isExpectedRomCode
  bne @f
    moveq #DBRAMS_ERROR_CODE,d1
    bra 8f
  @@:
  bsr waitKeyRelease
  jsr (a0)  ;ROM上の計測ルーチンを呼び出す
  move.l d0,d1

  moveq #1,d0
  bra 9f
8:
  moveq #0,d0
9:
  POP a0-a1
  rts


waitKeyRelease:
  @@:
    moveq #$d,d1
    1:
      IOCS _BITSNS
      tst.b d0
    dbne d1,1b
  bne @b
  rts


isExpectedRomCode:
  PUSH a0-a1
  moveq #0,d0
  lea (expectedRomCode,pc),a1
  moveq #(expectedRomCodeEnd-expectedRomCode)/2-1,d1
  @@:
    cmpm (a0)+,(a1)+
  dbne d1,@b
  bne @f
    moveq #1,d0
  @@:
  POP a0-a1
  tst.l d0
  rts

expectedRomCode:
  link a6,#-46
  move #46,d0
  subq #1,d0
expectedRomCodeEnd:


;IOCS ROMのバージョンを得る(IOCS _ROMVERを使わない)。
;out d0, break a0
getRomVer:
  lea ($ff0000),a0

  move.l ($8+2,a0),d0  ;ROM 1.0-1.2
  cmpi #MOVEL_IMM_D0,($8,a0)
  beq 9f

  move.l ($30+2,a0),d0  ;ROM 1.3
  cmpi #MOVEL_IMM_D0,($30,a0)
  beq 9f

  moveq #0,d0
9:
  rts


Dbrams_getErrorString::
  move.l d0,-(sp)
  subq.l #DBRAMS_ERROR_MAX,(sp)+
  bls @f
    moveq #0,d0
  @@:
  lea (errStrOffs,pc,d0.w),a0
  move.b (a0),d0
  adda d0,a0
  rts

errStrOffs: .dc.b @f-$,1f-$,2f-$,3f-$,4f-$
@@: .dc.b '',0
1:  .dc.b '68020以上のMPUでは使用できません。',0
2:  .dc.b 'IOCS ROM 1.0では使用できません。。',0
3:  .dc.b '未対応のIOCS ROMバージョンです。',0
4:  .dc.b 'IOCS ROMの内容が異なります。',0
.even


.end ProgramStart

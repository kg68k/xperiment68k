.title adpcmotchk - IOCS _ADPCMAOT/_ADPCMLOT checker

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

.include iomap.mac
.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac

ADPCM_BUF_SIZE: .equ $ff00

.cpu 68000
.text

ProgramStart:
  bsr fillAdpcmBuf

  TO_SUPER

  bsr adpcmAot
  bsr adpcmLot1
  bsr adpcmLot2

  DOS _EXIT


adpcmAot:
  PUSH d2/d7
  DOS_PRINT (AdpcmAotStr,pc)

  moveq #0<<8+0,d1
  moveq #1,d2
  lea (ArrayChainTable,pc),a1
  IOCS _ADPCMAOT

  move (DMAC_CH3+~DMAC_BTC),d7

  moveq #0,d1
  IOCS _ADPCMMOD

  DOS_PRINT (BtcIs,pc)
  move d7,d0
  bsr PrintD0w
  DOS_PRINT_CRLF

  POP d2/d7
  rts


adpcmLot1:
  DOS_PRINT (AdpcmLotStr1,pc)
  lea (LinkArrayChainTable1,pc),a1
  bsr adpcmLot
  rts

adpcmLot2:
  DOS_PRINT (AdpcmLotStr2,pc)
  lea (LinkArrayChainTable2,pc),a1
  bsr adpcmLot
  rts

adpcmLot:
  PUSH d7
  DOS_PRINT (LatIs,pc)
  move.l a1,d0
  bsr PrintD0l
  DOS_PRINT (CommaDollar,pc)
  move.l (6,a1),d0  ;next table
  bsr PrintD0l
  DOS_PRINT_CRLF

  moveq #0<<8+0,d1
  IOCS _ADPCMLOT

  move.l (DMAC_CH3+~DMAC_BAR),d7

  moveq #0,d1
  IOCS _ADPCMMOD

  DOS_PRINT (BarIs,pc)
  move.l d7,d0
  bsr PrintD0l
  DOS_PRINT_CRLF

  POP d7
  rts


fillAdpcmBuf:
  PUSH d2-d7
  lea (AdpcmBuf+ADPCM_BUF_SIZE),a0
  move.l #$80808080,d0
  .irp rn,d1,d2,d3,d4,d5,d6,a1
    move.l d0,rn
  .endm
  move #ADPCM_BUF_SIZE/.sizeof.(d0-d6/a1)/4-1,d7
  @@:
    .rept 4
      movem.l d0-d6/a1,-(a0)
    .endm
  dbra d7,@b
  POP d2-d7
  rts


PrintD0w:
  lea (Buffer,pc),a0
  bsr ToHexString4

  DOS_PRINT (Buffer,pc)
  rts

  DEFINE_TOHEXSTRING4 ToHexString4

PrintD0l:
  lea (Buffer,pc),a0
  bsr ToHexString4_4

  DOS_PRINT (Buffer,pc)
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data
.even

ArrayChainTable:
  .dc.l AdpcmBuf
  .dc ADPCM_BUF_SIZE

LinkArrayChainTable1:
  .dc.l AdpcmBuf
  .dc ADPCM_BUF_SIZE
  .dc.l LinkArrayChainTable2

  .dc.b '----'  ;padding

LinkArrayChainTable2:
  .dc.l AdpcmBuf
  .dc ADPCM_BUF_SIZE
  .dc.l 0

AdpcmAotStr: .dc.b 'testing IOCS _ADPCMAOT',CR,LF,0
BtcIs: .dc.b 'BTC = $',0

AdpcmLotStr1: .dc.b 'testing IOCS _ADPCMLOT (1)',CR,LF,0
AdpcmLotStr2: .dc.b 'testing IOCS _ADPCMLOT (2)',CR,LF,0
LatIs: .dc.b 'LinkArrayChainTable = $',0
CommaDollar: .dc.b ', $',0
BarIs: .dc.b 'BAR = $',0


.bss
.quad

Buffer: .ds.b 64

AdpcmBuf: .ds.b ADPCM_BUF_SIZE+16


.end ProgramStart

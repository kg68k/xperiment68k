.title skeyset - call IOCS _SKEYSET and show IOCS _KEYINP result

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
.include fefunc.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr getArgument
  move.l d0,d7
  bmi  printUsage

  bsr FlushIocsKey

  move.l d7,d1
  IOCS _SKEYSET

  bsr printInkey

  bsr FlushIocsKey
  bsr FlushDosKey
  DOS _EXIT


printInkey:
  IOCS _B_KEYSNS
  tst.l d0
  bne @f
    DOS_PRINT (NoInputKey,pc)
    bra 9f
  @@:
    IOCS _B_KEYINP
    bsr Print$4
    DOS_PRINT (CrLf,pc)
9:
  rts


printUsage:
  PRINT_1LINE_USAGE 'usage: skeyset <scancode>'
  DOS _EXIT


getArgument:
  SKIP_SPACE a0
  FPACK __STOH
  bcs @f
  tst.l d0
  beq @f
  cmpi.l #$ff,d0
  bls 9f
  @@:
    moveq #-1,d0
9:
  rts


  DEFINE_FLUSHIOCSKEY FlushIocsKey
  DEFINE_FLUSHDOSKEY FlushDosKey

  DEFINE_PRINT$4 Print$4


.data

NoInputKey: .dc.b 'no input key',CR,LF,0

CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 128


.end ProgramStart

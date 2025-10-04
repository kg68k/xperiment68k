.title parseint - ParseInt test

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

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (ParseInt,pc),a5
  lea (1,a2),a0
  1:
    SKIP_SPACE a0
    beq PrintUsage
    cmpi.b #'-',(a0)
    bne 2f
      cmpi.b #'w',(1,a0)
      bne @f
        lea (ParseIntWord,pc),a5
        addq.l #2,a0
        bra 1b
      @@:
      cmpi.b #'b',(1,a0)
      bne @f
        lea (ParseIntByte,pc),a5
        addq.l #2,a0
        bra 1b
      @@:
      ;-w -b以外の-は負数の指定なのでそのまま通す
  2:

  @@:
    jsr (a5)  ;ParseInt or ParseIntWord or ParseIntByte
    bsr Print$4_4
    DOS_PRINT_CRLF
  SKIP_SPACE a0
  bne @b

  DOS _EXIT


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PARSEINTBYTE ParseIntByte
  DEFINE_PRINT$4_4 Print$4_4


.data

strUsage:
  .dc.b 'usage: parseint [-w|-b] <num> ...',CR,LF
  .dc.b 'options:',CR,LF
  .dc.b '  -w ... word size',CR,LF
  .dc.b '  -b ... byte size',CR,LF
  .dc.b 'number format:',CR,LF
  .dc.b '  0x or $ ... hex',CR,LF
  .dc.b '  0b or % ... binary',CR,LF
  .dc.b '  no prefix ... decimal',CR,LF
  .dc.b '  -num ... negative',CR,LF
  .dc.b 0


.end ProgramStart

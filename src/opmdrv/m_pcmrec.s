.title m_pcmrec - OPM _M_PCMREC

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

.include opmdrv.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  bsr ParseArgAndAllocBuffer

  move.l d1,d3  ;バッファサイズ
  OPM _M_PCMREC
  move.l d0,d7
  bsr Print$4_4
  DOS_PRINT_CRLF

  tst.l d7
  bmi @f
    move.l d3,d0
    bsr WriteFile
    move.l d0,d1
    bpl @f
      DOS_PRINT (strFileWriteError,pc)
      move.l d1,d0
      bsr Print$4_4
      DOS_PRINT_CRLF
      DOS _EXIT
  @@:
  DOS _EXIT


WriteFile:
  move.l d0,d2  ;データサイズ

  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (a0)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d1
  bmi 9f
    move.l d2,-(sp)
    pea (a1)
    move d1,-(sp)
    DOS _WRITE
    lea (10,sp),sp  ;手抜きでディスク容量不足のエラーチェックをしていない

    move.l d0,-(sp)
    move d1,-(sp)
    DOS _CLOSE
    addq.l #2,sp
    move.l (sp)+,d0
  9:
  rts


PrintUsage:
  PRINT_1LINE_USAGE 'usage: m_pcmrec <freq(0..4)> <size> <filename>'
  DOS _EXIT

ParseArgAndAllocBuffer:
  bsr ParseArguments

  move.l d1,-(sp)
  DOS _MALLOC
  move.l d0,(sp)+
  bpl @f
    DOS_PRINT (strMallocError,pc)
    DOS _EXIT
  @@:
  move.l d0,a1  ;バッファ
  rts


ParseArguments:
  bsr ParseInt
  move.l d0,d2  ;周波数
  SKIP_SPACE a0
  beq PrintUsage

  bsr ParseInt
  move.l d0,d1  ;バッファサイズ
  SKIP_SPACE a0
  beq PrintUsage

  lea (a0),a1  ;ファイル名
  rts


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.data

strMallocError:
  .dc.b 'メモリを確保できません。',CR,LF,0

strFileWriteError:
  .dc.b 'ファイル書き込みエラー: d0.l = ',0


.end ProgramStart

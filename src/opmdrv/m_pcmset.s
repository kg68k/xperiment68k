.title m_pcmset - OPM _M_PCMSET

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
  bne 1f
    moveq #-1,d2  ;コマンドライン引数の省略時はPCMバッファをクリアする
    bra @f
  1:
    bsr ParseArgAndReadFile
    move.l d2,d3  ;ノート番号 | 周波数
    move.l d1,d2  ;データサイズ
  @@:
  OPM _M_PCMSET
  bsr Print$4_4
  DOS_PRINT_CRLF
9:
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: m_pcmset <note_no(0..127)> <freq(0..4)> <filename>'
  DOS _EXIT

ParseArgAndReadFile:
  bsr ParseArguments
  move.l d0,-(sp)
  bsr ReadFile
  move.l (sp)+,d2  ;ノート番号 | 周波数
  move.l d0,d1
  bpl @f
    DOS_PRINT (strFileReadError,pc)
    move.l d1,d0
    bsr Print$4_4
    DOS_PRINT_CRLF
    DOS _EXIT
  @@:
  rts

ParseArguments:
  bsr ParseIntWord
  move d0,d1  ;ノート番号
  swap d1
  SKIP_SPACE a0
  beq PrintUsage

  bsr ParseIntWord
  move d0,d1  ;周波数

  SKIP_SPACE a0
  beq PrintUsage

  move.l d1,d0
  rts

ReadFile:
  move #OPENMODE_READ,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d1
  bmi 9f
    moveq #SEEKMODE_END,d0
    bsr DosSeek
    bmi 8f
    move.l d0,d2  ;ファイルサイズ
    moveq #SEEKMODE_SET,d0
    bsr DosSeek
    bmi 8f

    move.l d2,-(sp)
    DOS _MALLOC
    move.l d0,(sp)+
    bmi 8f
      movea.l d0,a1  ;読み込みバッファ
      move.l d2,-(sp)
      pea (a1)
      move d1,-(sp)
      DOS _READ
      addq.l #10-4,sp
      move.l d0,(sp)+
      bmi 7f
        move.l d0,d1  ;読み込みサイズをd1に返す
        bra 8f
      7:
      move.l d0,d2
      pea (a1)
      DOS _MFREE
      addq.l #4,sp
      move.l d2,d0
    8:
    move.l d0,d2
    move d1,-(sp)
    DOS _CLOSE
    addq.l #2,sp
    move.l d2,d0
  9:
  rts

DosSeek:
  move d0,-(sp)
  clr.l -(sp)
  move d1,-(sp)
  DOS _SEEK
  addq.l #8,sp
  tst.l d0
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PRINT$4_4 Print$4_4


.data

strFileReadError:
  .dc.b 'ファイル読み込みエラー: d0.l = ',0


.end ProgramStart

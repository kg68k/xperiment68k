.title m_pcmget - OPM _M_PCMGET

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
  bne @f
    PRINT_1LINE_USAGE 'usage: m_pcmget <note_no> [size] [filename]'
    DOS _EXIT
  @@:
  bsr ParseInt
  move.l d0,d2  ;ノート番号

  moveq #0,d7   ;バッファサイズ省略時は0バイト
  SKIP_SPACE a0
  beq @f
    bsr ParseInt
    move.l d0,d7  ;バッファサイズ
    bsr MallocBuffer
    SKIP_SPACE a0  ;ファイル名
  @@:
  move.l d7,d3
  OPM _M_PCMGET
  move.l d0,d6
  bsr Print$4_4
  DOS_PRINT_CRLF

  ;_M_PCMGETの返り値はPCMデータのバイト数で、データがない場合は0になる。
  ;エラーコードが返ることはない。
  ;指定したバッファサイズが小さい場合はバッファいっぱいまでデータをコピーし、
  ;返り値はデータ自体のバイト数となるのでチェックが必要。
  tst.l d7
  beq 9f  ;バッファを確保していない
  tst.b (a0)
  beq 9f  ;ファイル名が指定されていない
    cmp.l d6,d7
    bcc @f
      DOS_PRINT (strBufferTooSmall,pc)  ;バッファが小さすぎた(途中までデータがコピーされた状態)
      DOS _EXIT
    @@:
    move.l d6,d0
    beq 9f  ;PCMデータがなければファイル出力は省略する
      bsr WriteFile
      move.l d0,d1
      bpl 9f
        DOS_PRINT (strFileWriteError,pc)
        move.l d1,d0
        bsr Print$4_4
        DOS_PRINT_CRLF
        DOS _EXIT
  9:
  DOS _EXIT


MallocBuffer:
  move.l d0,-(sp)
  DOS _MALLOC
  move.l d0,(sp)+
  bpl @f
    DOS_PRINT (strMallocError,pc)
    DOS _EXIT
  @@:
  movea.l d0,a1
  rts


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


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.data

strMallocError:
  .dc.b 'メモリを確保できません。',CR,LF,0

strBufferTooSmall:
  .dc.b 'バッファサイズが小さすぎます。',CR,LF,0

strFileWriteError:
  .dc.b 'ファイル書き込みエラー: d0.l = ',0


.end ProgramStart

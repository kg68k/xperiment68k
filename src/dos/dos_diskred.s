.title dos_diskred - DOS _DISKRED

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
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage
  bsr GetDriveNo
  move d0,d7  ;ドライブ番号

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntWord
  move d0,d6  ;セクタ番号

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntWord
  move d0,d5  ;セクタ数

  move d5,d4  セクタ数*1024でバッファ容量を求める
  swap d4
  clr d4
  lsr.l #16-10,d4  ;*1024

  move.l d4,d0
  bsr AllocateBuffer
  tst.l d0
  bmi NotEnoughMemory
  movea.l d0,a0

  move d5,-(sp)
  move d6,-(sp)
  move d7,-(sp)
  pea (a0)
  DOS _DISKRED
  lea (10,sp),sp

  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: dos_diskred <d:|driveno> <sect.w> <sectlen.w>'
  DOS _EXIT


GetDriveNo:
  moveq #$20,d0
  or.b (a0),d0
  subi.b #'a',d0
  cmpi.b #'z'-'a',d0
  bhi @f
    cmpi.b #':',(1,a0)
    bne @f
      addq.l #.sizeof.('?:'),a0
      addq #1,d0  ;A:～Z: -> 1～26
      rts
  @@:
  bra ParseIntWord


AllocateBuffer:
  tst.l d0
  bne @f
    ;セクタ数に0を指定するとHuman68k内部で2^32として扱われると思われるので
    ;指定してはいけないが、念の為最大サイズで確保する
    move.l #$00ff_ffff,-(sp)
    DOS _MALLOC
    and.l (sp)+,d0
    cmpi.l #1024,d0
    bcc @f
      moveq #DOSE_NOMEM,d0
      bra 9f
  @@:
  move.l d0,-(sp)
  DOS _MALLOC
  addq.l #4,sp
9:
  movea.l d0,a0
  rts


NotEnoughMemory:
  DOS_PRINT (strNotEnoughMemory,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PRINT$4_4 Print$4_4


.data

strNotEnoughMemory: .dc.b 'メモリが不足しています。',CR,LF,0


.end ProgramStart

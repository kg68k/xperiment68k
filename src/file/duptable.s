.title duptable - show DUP table

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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

.include xputil.mac


OS_VER: .equ $0302

DupTable: .equ $1c2c  ;ファイルハンドル6～のdupテーブルへのポインタ
Files:    .equ $1c6e  ;使用できるファイルハンドル数(標準ハンドル、辞書用を含む)

.if OS_VER.eq.$0302
StdDupTable: .equ $013d24  ;ファイルハンドル0～5のdupテーブル
.else
  .fail 1
.endif


.cpu 68000
.text

ProgramStart:
  DOS _VERNUM
  cmpi #OS_VER,d0
  beq @f
    FATAL_ERROR 'Human68k version 3.02専用です。'
  @@:
  pea (PrintDupTable,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  DOS _EXIT


PrintDupTable:
  lea (Buffer,pc),a0
  bsr StringifyDupTable
  DOS_PRINT (Buffer,pc)
  rts


StringifyDupTable:
  lea (strHeader,pc),a1
  STRCPY a1,a0,-1

  move (Files).w,d7
  cmpi #$ff,d7
  bls @f
    move #$ff,d7  ;念の為
  @@:
  moveq #0,d5
  moveq #0,d6  ;処理中のファイルハンドル
  1:
    tst d5
    bne @f
      bsr WriteLineHeader
    @@:
    move.b #' ',(a0)+

    move d6,d0
    bsr GetDupMapping
    bsr StringifyDupMapping

    addq #1,d5
    cmpi #10,d5
    bne @f
      WRITE_CRLF a0
      moveq #0,d5
    @@:
    addq #1,d6
  cmp d7,d6
  bcs 1b

  tst d5
  beq @f
    WRITE_CRLF a0
  @@:
  clr.b (a0)
  rts


StringifyDupMapping:
  cmpi #-1,d0
  bne @f
    lea (strMinus1,pc),a1  ;使用されていないファイルハンドル
    STRCPY a1,a0,-1
    rts
  @@:
    move d0,-(sp)  ;使用中のファイルハンドル
    move.b (sp),d0
    bsr ToHexString$2  ;上位バイト
    move.b #'_',(a0)+
    move (sp)+,d0
    bsr ToHexString2  ;下位バイト
    rts


WriteLineHeader:
  move.l d6,d0
  moveq #2,d1
  bsr ToDecStringWidth
  move.b #':',(a0)+
  rts


GetDupMapping:
  move.l a0,-(sp)
  lea (StdDupTable),a0
  cmpi #6,d0
  bcs @f
    subq #6,d0
    movea.l (DupTable).w,a0
  @@:
  add d0,d0
  move (a0,d0.w),d0
  movea.l (sp)+,a0
  rts


  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_TODECSTRINGWIDTH ToDecStringWidth


.data

strHeader: .dc.b '    stdin  stdout stderr stdaux stdprn',CR,LF,0
strMinus1: .dc.b '  -1  ',0


.bss

Buffer: .ds.b 4096


.end ProgramStart

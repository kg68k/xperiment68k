.title lineage - show ancestor memory blocks

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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
.include console.mac
.include doscall.mac
.include process.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)  ;スーパーバイザ領域にあるHuman68kのメモリ管理ポインタに
  DOS _SUPER   ;アクセスできるようにする
  addq.l #4,sp

  DOS_PRINT (Header,pc)
  move.l a0,d0
  @@:
    movea.l d0,a3
    lea (a3),a0
    bsr PrintMemblk
    cmpi.b #MEMBLK_TYPE_SUB,(MEMBLK_Parent,a3)
    bcc @f  ;親が通常のプロセスでなければ打ち切る
    move.l (MEMBLK_Parent,a3),d0
  bne @b
  @@:
  DOS _EXIT


PrintMemblk:
  PUSH d3/a3
  lea (a0),a3
  lea (Buffer,pc),a0

  move.l a3,d0  ;メモリ管理ポインタ自体のアドレス
  bsr ToHexString8
  move.b #':',(a0)+
  move.b #' ',(a0)+

  lea (a3),a1
  moveq #4-1,d3
  @@:
    move.l (a1)+,d0  ;メモリ管理ポインタの内容
    bsr ToHexString8
    move.b #' ',(a0)+
  dbra d3,@b

  lea (PSP_Drive,a3),a1  ;実行ファイル名のフルパス名
  STRCPY a1,a0,-1
  lea (PSP_Filename,a3),a1
  STRCPY a1,a0,-1
  lea (CrLf,pc),a1
  STRCPY a1,a0

  DOS_PRINT (Buffer,pc)
  POP d3/a3
  rts

  DEFINE_TOHEXSTRING8 ToHexString8


.data

Header:
  .dc.b 'address : previous parent   end+1    next',CR,LF
  .dc.b '--------  -------- -------- -------- --------',CR,LF
  .dc.b 0

CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 256


.end ProgramStart

.title loadonly - DOS _EXEC (md=3)

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

.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  addq.l #1,a2
  SKIP_SPACE a2

  move.l #$00ffffff,-(sp)
  DOS _MALLOC
  and.l d0,(sp)
  DOS _MALLOC
  move.l (sp)+,d7  ;確保サイズ
  move.l d0,d6     ;確保アドレス
  bpl @f
    DOS_PRINT (strMallocError,pc)
    DOS _EXIT
  @@:

  add.l d6,d7
  move.l d7,-(sp)  ;リミットアドレス
  move.l d6,-(sp)  ;ロードアドレス
  pea (a2)  ;実行ファイル名
  move #EXECMODE_LOADONLY,-(sp)
  DOS _EXEC
  lea (14,sp),sp

  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strMallocError: .dc.b 'メモリが確保できませんでした。',CR,LF,0


.end

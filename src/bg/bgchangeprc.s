.title bgchangeprc - DOS _CHANGE_PR counter

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
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


COUNTER_WIDTH: .equ .sizeof.('? 12345678')


.cpu 68000
.text

;常駐部先頭
KeepStart:
  .dc.b 'bgchangeprc',0
  .even

;d0/a5レジスタを破壊しないこと
DosChangePr:
  PUSH d0-d4/a1
  lea (Buffer,pc),a0
  addi.b #'0',d0  ;スレッドID
  move.b d0,(a0)+
  move.b #' ',(a0)+

  addq.l #1,(Counter)  ;呼び出し回数
  move.l (Counter,pc),d0
  bsr ToHexString8
  clr.b (a0)

  moveq #1,d1
  moveq #96-COUNTER_WIDTH,d2
  moveq #0,d3
  moveq #COUNTER_WIDTH-1,d4
  lea (Buffer,pc),a1
  IOCS _B_PUTMES

  POP d0-d4/a1
  movea.l (OldDosChangePrVector,pc),a0
  jmp (a0)

  DEFINE_TOHEXSTRING8 ToHexString8


;変数
OldDosChangePrVector: .dc.l 0

Counter: .dc.l 0

Buffer: .ds.b COUNTER_WIDTH+1
.even

KeepEnd:
;常駐部末尾


ProgramStart:
  lea (OldDosChangePrVector,pc),a0
  pea (DosChangePr,pc)
  move #_CHANGE_PR,-(sp)
  DOS _INTVCG     ;_INTVCSだけでフックすると、完了した瞬間にプロセスが切り替わった場合に
  move.l d0,(a0)  ;旧ベクタが保存されておらず0番地に飛んでしまうので、先に保存しておく。
  DOS _INTVCS     ;完全ではないが常駐解除はしないのでよしとする。
  move.l d0,(a0)
  addq.l #6,sp

  DOS_PRINT (KeepMessage,pc)

  clr -(sp)
  move.l #KeepEnd-KeepStart,-(sp)
  DOS _KEEPPR


.data

KeepMessage: .dc.b '常駐しました。',CR,LF,0


.end ProgramStart

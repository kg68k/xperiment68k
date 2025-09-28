.title sram_memsize - verify writing the main memory size in SRAM ($00ed0008)

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

.include sram.mac
.include iomap.mac
.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  bsr PrintMainMemorySize

  bsr GetMeinMemorySize
  move.l d0,d7
  move.l d0,d6
  subi.l #$100000,d6    ;メインメモリ容量を1MB少なくする
  bne @f
    move.l #$200000,d6  ;メインメモリ1MBの場合は2MBにする
  @@:

  DOS_PRINT (ModifyMessage1,pc)
  move.l d6,d0
  bsr Print$4_4
  DOS_PRINT (ModifyMessage2,pc)
  move.l d6,d0
  pea (WriteMainMemorySize,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  bsr PrintMainMemorySize

  DOS_PRINT (RestoreMessage,pc)
  move.l d7,d0
  pea (WriteMainMemorySize,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  DOS _EXIT


WriteMainMemorySize:
  PUSH d7/a0-a1
  lea (SYS_P7),a0
  lea (SRAM_MEMSIZE),a1
  move sr,d7
  DI
  move.b #$31,(a0)  ;SRAM書き込み許可
  move.l d0,(a1)    ;メインメモリ容量を書き換える
  move.b #$00,(a0)  ;SRAM書き込み禁止
  move d7,sr
  POP d7/a0-a1
  rts


GetMeinMemorySize:
  lea (SRAM_MEMSIZE),a1
  IOCS _B_LPEEK
  rts


PrintMainMemorySize:
  DOS_PRINT (MemorySizeMessage,pc)
  bsr GetMeinMemorySize
  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

MemorySizeMessage: .dc.b '現在のメインメモリ容量($00ed0008): ',0
ModifyMessage1: .dc.b 'メインメモリ容量を',0
ModifyMessage2: .dc.b 'に書き換えます。',CR,LF,0
RestoreMessage: .dc.b 'メインメモリ容量を元に戻します。',CR,LF,0


.end

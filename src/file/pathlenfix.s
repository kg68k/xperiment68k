.title pathlenfix - fix path length limit problem

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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

.include console.mac
.include doscall.mac

.include xputil.mac


PATH_MAX: .equ 64

.cpu 68000
.text

Start:
  DOS _VERNUM
  cmpi.l #$36380302,d0
  beq @f
    lea (HumanVerError,pc),a0
    bra error
  @@:

  clr.l -(sp)
  DOS _SUPER

  bsr ValidateCodeInMemory
  beq @f
    lea (CodeInMemoryError,pc),a0
    bra error
  @@:

  bsr Patch

  IS_MPU_68000 d0
  beq @f
    moveq #3,d1
    IOCS _SYS_STAT
  @@:

  DOS_PRINT (Success,pc)
  DOS _EXIT

error:
  DOS_PRINT (a0)
  move #1,-(sp)
  DOS _EXIT2


;パッチ対象メモリの内容を確認する。
ValidateCodeInMemory:
  ;namests内部処理 L00ae1e
  cmpi #$b0bc,($aec4)  ;cmp.l #imm,d0
  bne 9f
  cmpi.l #PATH_MAX-1,($aec4+2)
  bne 9f
  cmpi.l #$6500_4340,($aeca)  ;bcs L00f20c
  bne 9f

  ;仮想ドライブ展開 L00b24e
  cmpi.l #$b07c_0041,($b282)  ;cmp #65,d0
  bne 9f
  cmpi #$646a,($b286)  ;bcc L00b2f2
  bne 9f

  ;ディレクトリ名の長さ制限検査 L00b9e0
  cmpi #$5247,($b9f0)  ;addq #1,d7
  bne 9f
9:
  rts


;パッチを行う。
Patch:
  ;namests内部処理 L00ae1e
  move #PATH_MAX+1,($aec4+4)

  ;仮想ドライブ展開 L00b24e
  move #$626a,($b286)  ;bhi L00b2f2

  ;ディレクトリ名の長さ制限検査 L00b9e0
  move #$5647,($b9f0)  ;addq #3,d7

  rts


.data
Success: .dc.b 'Human68kのパス名処理にパッチをあてました。',CR,LF,0
HumanVerError: .dc.b 'Human68k version 3.02専用です。',CR,LF,0
CodeInMemoryError: .dc.b 'パッチ対象メモリの内容が書き換えられています。',CR,LF,0


.end

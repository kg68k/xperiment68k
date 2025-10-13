.title m_opmreg - OPM _M_OPMREG

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
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne 1f
    bsr PrintAllRegisters  ;コマンドライン引数の省略時は全レジスタを表示
    bra @f
  1:
    bsr ParseArguments
    move.l d1,d3  ;書き込むデータ
    move.l d0,d2  ;レジスタ番号
    OPM _M_OPMREG
    bsr Print$4_4
    DOS_PRINT_CRLF
  @@:
  DOS _EXIT


REGS_PER_LINE: .equ 16  ;1行あたりに表示するレジスタ数

PrintAllRegisters:
  link a6,#-128
  DOS_PRINT (strHeader,pc)

  moveq #O3_OPMREG_REG_MIN,d7  ;レジスタ番号(0-255)
  moveq #O3_OPMREG_REG_COUNT/REGS_PER_LINE-1,d6
  1:
    lea (sp),a0
    move.l d7,d0
    bsr ToHexString$2
    lea (strColon,pc),a1
    STRCPY a1,a0,-1

    moveq #REGS_PER_LINE-1,d5
    2:
      move.l d7,d2
      moveq #O3_OPMREG_DATA_INQUIRY,d3  ;レジスタの値の取得
      OPM _M_OPMREG

      cmpi.l #O3_OPMREG_NOT_WRITTEN,d0
      bne @f
        lea (strAsterisk,pc),a1  ;レジスタが書き換えられていない
        STRCPY a1,a0,-1
        bra 5f
      @@:
      cmpi.l #O3_OPMREG_DATA_MAX,d0
      bls @f
        lea (strUnexpected,pc),a1  ;未定義の返り値
        STRCPY a1,a0,-1
        bra 5f
      @@:
        ;レジスタに書き込んだ値が取得できれば16進数2桁で表示
        bsr ToHexString2
      5:
      move.b #' ',(a0)+

      addq #1,d7
    dbra d5,2b

    subq.l #1,a1  ;最後のスペースを取り除く
    lea (strCrLf,pc),a1
    STRCPY a1,a0
    DOS_PRINT (sp)
  dbra d6,1b

  unlk a6
  rts


ParseArguments:
  moveq #O3_OPMREG_DATA_INQUIRY,d1  ;書き込むデータ省略時は値の取得

  bsr ParseInt
  move.l d0,d2  ;レジスタ番号
  SKIP_SPACE a0
  beq @f
    bsr ParseInt
    move.l d0,d1  ;書き込むデータ
  @@:
  move.l d2,d0
  rts


  DEFINE_PARSEINT ParseInt
  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_PRINT$4_4 Print$4_4


.data

.fail REGS_PER_LINE.ne.16
strHeader: .dc.b '    | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +a +b +c +d +e +f',CR,LF
           .dc.b '----+------------------------------------------------',CR,LF,0
strColon:  .dc.b    ' | ',0

strAsterisk:   .dc.b '**',0
strUnexpected: .dc.b '??',0

strCrLf: .dc.b CR,LF,0


.end ProgramStart

.title zm2_d5poc - Z-MUSIC v2 fclose(d5) on error PoC

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

.include filesys.mac
.include zmusic2.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  sne d7  ;何か引数があれば_m_allocを呼ばない

  bsr IsZmusic2Resident
  bne @f
    FATAL_ERROR 'Z-MUSIC v2が常駐していません。'
  @@:

  move #STDIN,-(sp)
  DOS _DUP
  addq.l #2,sp
  move.l d0,d5  ;複写したファイルハンドルをd5に保存
  lea (strDosDup,pc),a0
  bsr PrintResult
  tst.l d5
  bmi 9f

  tst.b d7
  bne @f
    move.l #0<<16+256,d2  ;不正なトラック番号を指定する
    ZM2 ZM2_M_ALLOC       ;エラー番号2になる(トラック番号が規定外)
    lea (strZmalloc,pc),a0
    bsr PrintResult
  @@:

  move d5,-(sp)  ;複写したファイルハンドルをクローズする
  DOS _CLOSE
  addq.l #2,sp
  lea (strDosClose,pc),a0
  bsr PrintResult
9:
  DOS _EXIT


PrintResult:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  rts


IsZmusic2Resident:
  pea (GetZmusicVersion,pc)
  DOS _SUPER_JSR
  move.l d0,(sp)+
  bmi @f
    andi #$f000,d0  ;バージョン整数部
    cmpi #$2000,d0
    bne @f
      moveq #1,d0
      rts
  @@:
  moveq #0,d0
  rts

GetZmusicVersion:
  movea.l (ZM2_TRAP3_VEC*4).w,a0
  moveq #0,d0
  move -(a0),d0  ;(常駐していれば)バージョン番号
  cmpi #'iC',-(a0)
  bne @f
    cmpi.l #'ZmuS',-(a0)
    beq 9f
    @@:
      moveq #-1,d0
9:
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strDosDup: .dc.b 'DOS _DUP: ',0
strDosClose: .dc.b 'DOS _CLOSE: ',0
strZmalloc: .dc.b 'Z-MUSIC _m_alloc: ',0


.end ProgramStart

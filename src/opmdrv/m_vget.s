.title m_vget - OPM _M_VGET

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
.include fefunc.mac
.include filesys.mac
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    PRINT_1LINE_USAGE 'usage: m_vget <tone_no> [filename]'
    DOS _EXIT
  @@:
  bsr ParseInt
  move.l d0,d2
  lea (ToneBuffer,pc),a1
  OPM _M_VGET
  tst.l d0
  beq @f
    bsr PrintD0$4_4
    DOS_PRINT_CRLF
    move #EXIT_FAILURE,-(sp)
    DOS _EXIT2
  @@:
  SKIP_SPACE a0
  beq @f
    bsr WriteToneToFile
    bra 9f
  @@:
    bsr GetToneName
    bsr PrintTone
  9:
  DOS _EXIT


GetToneName:
  lea (NameBuffer,pc),a1
  lea (a1),a0
  OPM _M_TNMGET
  tst.l d0
  bne 9f

  STREND a0  ;末尾の空白を削除する
  moveq #O3_TONE_NAME_LEN-1,d0
  @@:
    cmp.b #' ',-(a0)
  dbne d0,@b
  beq 9f  ;すべて空白だった
    addq.l #1,a0
9:
  clr.b (a0)
  rts


PrintTone:
  lea (Buffer,pc),a0
  lea (ToneBuffer,pc),a2

  lea (NameBuffer,pc),a1
  tst.b (a1)
  beq @f
    move.b #'/',(a0)+  ;音色名があればコメントとして出力する
    move.b #' ',(a0)+
    STRCPY a1,a0,-1
    lea (strCrLf,pc),a1
    STRCPY a1,a0,-1
  @@:
  lea (strToneHeader,pc),a1
  STRCPY a1,a0,-1
  move.l d2,d0
  FPACK __LTOS  ;音色番号
  move.b #',',(a0)+
  move.b #'0',(a0)+  ;書き換えを始めるパラメーター番号は0で固定

  bsr LineToString  ;AF  OM  WF  SY  SP PMD AMD PMS AMS PAN

  moveq #4-1,d7
  @@:
    bsr LineToString  ;AR  DR  SR  RR  SL  OL  KS  ML DT1 DT2 AME ×4
  dbra d7,@b
  lea (strToneFooter,pc),a1
  STRCPY a1,a0,-1

  DOS_PRINT (Buffer,pc)
  rts

LineToString:
  lea (strCrLf,pc),a1
  STRCPY a1,a0,-1

  moveq #11-1,d2
  @@:
    moveq #0,d0
    move.b (a2)+,d0
    moveq #3,d1
    FPACK __IUSING
    move.b #',',(a0)+
  dbra d2,@b
  clr.b -(a0)  ;最後の,を消す
  rts


WriteToneToFile:
  moveq #FM_TONE_V_SIZE,d0
  lea (ToneBuffer,pc),a1
  bsr WriteFile
  tst.l d0
  bpl @f
    FATAL_ERROR 'file write error'
  @@:
  rts


WriteFile:
  move.l d0,d2  ;書き込みサイズ

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
    addq.l #10-4,sp
    move.l d0,(sp)+
    bpl @f
      cmp.l d0,d2
      beq @f
        moveq #DOSE_DISKFULL,d0
    @@:
    move.l d0,-(sp)
    move d1,-(sp)
    DOS _CLOSE
    addq.l #2,sp
    move.l (sp)+,d0
  9:
  rts


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strToneHeader: .dc.b '(v',0
strToneFooter: .dc.b ')',CR,LF,0

strCrLf: .dc.b CR,LF,0


.bss

.even
Buffer: .ds.b 512

.even
ToneBuffer: .ds.b FM_TONE_V_SIZE
.even
NameBuffer: ds.b O3_TONE_NAME_LEN+1


.end ProgramStart

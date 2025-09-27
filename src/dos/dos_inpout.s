.title dos_inpout - DOS _INPOUT

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


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  bsr AnalyzeArgument
  move.l d0,d7
  bmi PrintUsage
  beq 1f
    bsr InputMode
    bra @f
  1:
    bsr OutputMode
  @@:
  DOS _EXIT


InputMode:
  PUSH d5-d7
  move d0,d7
  moveq #0,d6  ;前回の返り値が0かどうか
  1:
    move d7,-(sp)
    DOS _INPOUT
    addq.l #2,sp

    move.l d0,d5
    bne 2f
      tas d6
      beq 3f
        DOS _CHANGE_PR  ;入力なしが続く間は返り値の表示を省略する
        bra 1b
    2:
      moveq #0,d6
    3:
    bsr Print$4_4

    cmpi.b #$fe,d7
    bne @f
      DOS_PRINT (Comma,pc)
      move #$ff,-(sp)  ;先読みだけだと新しい入力が得られないので
      DOS _INPOUT      ;入力して返り値を表示する
      addq.l #2,sp
      bsr Print$4_4
    @@:
    DOS_PRINT (CrLf,pc)
  cmpi #$03,d5  ;Ctrl+Cが入力されたら終了する
  bne 1b

  POP d5-d7
  rts


OutputMode:
  bra 8f
  1:
    move d0,-(sp)
    DOS _INPOUT
    addq.l #2,sp
  8:
  moveq #0,d0
  move.b (a0)+,d0
  bne 1b

  ;ファイルへのリダイレクト時に指定コードだけが保存されるように、IOCSで改行を表示する
  IOCS_B_PRINT (CrLf,pc)
  rts


PrintUsage:
  PRINT_1LINE_USAGE 'usage: dos_inpout <-ff | -fe | string...>'
  DOS _EXIT


AnalyzeArgument:
  moveq #0,d0
  cmpi.b #'-',(a0)
  bne 9f
    cmpi.b #'f',(1,a0)
    bne 8f
      cmpi.b #'f',(2,a0)
      bne @f
        move #$ff,d0  ;-ff
        rts
      @@:
      cmpi.b #'e',(2,a0)
      bne 8f
        move #$fe,d0  ;-fe
        rts
8:
  moveq #-1,d0
9:
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

Comma: .dc.b ', ',0
CrLf: .dc.b CR,LF,0


.end ProgramStart

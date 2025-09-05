.title bgsleeppr - DOS _SLEEP_PR

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
.include console.mac
.include doscall.mac
.include process.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d1,d7  ;スリープする時間(省略時は0)

  tst d0
  beq @f
    bsr EnablePrcCtrl
  @@:
  move.l d7,-(sp)
  DOS _SLEEP_PR
  addq.l #4,sp

  move.l d0,d7
  DOS_PRINT (strProgramName,pc)
  move.l d7,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


;タスク間通信バッファを受信可能な状態に書き換える
EnablePrcCtrl:
  moveq #-2,d0  ;自分自身のスレッド情報を取得
  bsr GetPr
  movea.l (PrcptrBuffer+PRCPTR_buf_ptr,pc),a0

  ;Human68k systemスレッドのタスク間通信バッファはスーパーバイザ領域にあるので
  ;ユーザーモードからは読み書きできない
  lea (PRCCTRL_your_id,a0),a1
  moveq #-1,d1
  IOCS _B_WPOKE
  rts


AnalyzeArgument:
  PUSH d6-d7,-(sp)
  moveq #0,d6
  moveq #0,d7
  bra 8f
  1:
    cmpi.b #'-',(a0)
    bne @f
      cmpi.b #'f',(1,a0)
      bne PrintUsage
      cmpi.b #$20,(2,a0)
      bhi PrintUsage
        addq.l #2,a0
        moveq #1,d6  ;-f指定あり
        bra 8f
    @@:
    FPACK __STOH
    bcs NumberError
    move.l d0,d7
  8:
  SKIP_SPACE a0
  bne 1b
9:
  move.l d6,d0
  move.l d7,d1
  POP d6-d7
  rts


GetPr:
  pea (PrcptrBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT

NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strProgramName:
  .dc.b 'bgsleeppr: ',0

strUsage:
  .dc.b 'usage: bgsleeppr [-f] [time]',CR,LF,0

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR


.end ProgramStart

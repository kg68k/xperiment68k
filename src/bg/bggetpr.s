.title bggetpr - DOS _GET_PR

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
.include process.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne 1f
    moveq #-2,d0  ;自分自身のスレッド管理情報を得る
    bra @f
  1:
    bsr SetThreadName
    bmi error
    moveq #-1,d0  ;バッファで指定した名前のスレッド管理情報を得る
  @@:
  bsr GetPr

  move.l d0,d7
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  tst.l d7
  bmi @f
    bsr PrintThreadInfo
  @@:
  DOS _EXIT

error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (PrcptrBuffer+PRCPTR_name,pc),a0
  moveq #16-1,d1
  @@:
    move.b (a2)+,(a0)+
  dbeq d1,@b
  beq @f
    DOS_PRINT (ThreadNameTooLong,pc)
    moveq #-1,d0
    rts
  @@:
  moveq #0,d0
  rts


GetPr:
  pea (PrcptrBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


PrintThreadInfo:
  lea (PrcptrBuffer,pc),a5
  lea (Buffer,pc),a0
  bsr StringifyThreadInfo

  DOS_PRINT (Buffer,pc)
  rts


StringifyThreadInfo:
  lea (strNextPtr,pc),a1
  move.l (PRCPTR_next_ptr,a5),d0
  bsr toStringHex8

  lea (strWaitFlg,pc),a1
  move.b (PRCPTR_wait_flg,a5),d0
  bsr toStringHex2

  lea (strCounter,pc),a1
  moveq #0,d0
  move.b (PRCPTR_counter,a5),d0
  bsr toStringDecimal

  lea (strMaxCounter,pc),a1
  moveq #0,d0
  move.b (PRCPTR_max_counter,a5),d0
  bsr toStringDecimal

  lea (strDosCmd,pc),a1
  move.b (PRCPTR_doscmd,a5),d0
  bsr toStringHex2

  lea (strPspId,pc),a1
  move.l (PRCPTR_psp_id,a5),d0
  bsr toStringHex8

  lea (strUspReg,pc),a1
  move.l (PRCPTR_usp_reg,a5),d0
  bsr toStringHex8

  lea (strDReg,pc),a1
  lea (PRCPTR_d_reg,a5),a2
  moveq #.sizeof.(d0-d7)/4-1,d0
  bsr stringifyRegisters

  lea (strAReg,pc),a1
  lea (PRCPTR_a_reg,a5),a2
  moveq #.sizeof.(a0-a6)/4-1,d0
  bsr stringifyRegisters

  lea (strSrReg,pc),a1
  move (PRCPTR_sr_reg,a5),d0
  bsr toStringHex4

  lea (strPcReg,pc),a1
  move.l (PRCPTR_pc_reg,a5),d0
  bsr toStringHex8

  lea (strSspReg,pc),a1
  move.l (PRCPTR_ssp_reg,a5),d0
  bsr toStringHex8

  lea (strInDosF,pc),a1
  moveq #0,d0
  move (PRCPTR_indosf,a5),d0
  bsr toStringDecimal

  lea (strInDosP,pc),a1
  move.l (PRCPTR_indosp,a5),d0
  bsr toStringHex8

  lea (strBufPtr,pc),a1
  move.l (PRCPTR_buf_ptr,a5),d0
  bsr toStringHex8

  lea (strName,pc),a1
  lea (PRCPTR_name,a5),a2
  bsr copyThreadName

  lea (strWaitTime,pc),a1
  move.b (PRCPTR_wait_time,a5),d0
  bsr toStringDecimal

  clr.b (a0)
  rts

toStringHex2:
  STRCPY a1,a0,-1
  bsr ToHexString2
  bra appendCrLf

toStringHex4:
  STRCPY a1,a0,-1
  bsr ToHexString4
  bra appendCrLf

toStringHex8:
  STRCPY a1,a0,-1
  bsr ToHexString8
  bra appendCrLf

toStringDecimal:
  STRCPY a1,a0,-1
  bsr ToDecString
  bra appendCrLf

stringifyRegisters:
  move d0,d3
  @@:
    STRCPY a1,a0,-1  ;ヘッダまたは", "をコピー
    move.b #'$',(a0)+
    move.l (a2)+,d0
    bsr ToHexString8
    lea (strComma,pc),a1
  dbra d3,@b
  bra appendCrLf

copyThreadName:
  STRCPY a1,a0,-1
  moveq #16-1,d0
  @@:
    move.b (a2)+,(a0)+
  dbeq d0,@b
  bne @f
    subq.l #1,a0
  @@:
  bra appendCrLf

appendCrLf:
  lea (strCrLf,pc),a1
  STRCPY a1,a0,-1
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4
  DEFINE_TODECSTRING ToDecString
  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_TOHEXSTRING4 ToHexString4
  DEFINE_TOHEXSTRING8 ToHexString8


.data

ThreadNameTooLong: .dc.b 'スレッド名が長すぎます。',CR,LF,0

strNextPtr:    .dc.b 'next_ptr: $',0
strWaitFlg:    .dc.b 'wait_flg: $',0
strCounter:    .dc.b 'counter: ',0
strMaxCounter: .dc.b 'max_counter: ',0
strDosCmd:     .dc.b 'doscmd: $',0
strPspId:      .dc.b 'psp_id: $',0
strUspReg:     .dc.b 'usp_reg: $',0
strDReg:       .dc.b 'd_reg[8]: ',0
strAReg:       .dc.b 'a_reg[7]: ',0
strSrReg:      .dc.b 'sr_reg: $',0
strPcReg:      .dc.b 'pc_reg: $',0
strSspReg:     .dc.b 'ssp_reg: $',0
strInDosF:     .dc.b 'indosf: ',0
strInDosP:     .dc.b 'indosp: $',0
strBufPtr:     .dc.b 'buf_ptr: $',0
strName:       .dc.b 'name[16]: ',0
strWaitTime:   .dc.b 'wait_time: ',0

strComma: .dc.b ',',0  ;一行が長くなるので,のあとにスペースは入れない

strCrLf: .dc.b CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR

Buffer: .ds.b 1024


.end ProgramStart

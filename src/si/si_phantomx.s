.title si_phantomx - show information: PhantomX

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

.include xputil.mac


PHANTOMX_EA8000_REG:  .equ $ea8000
PHANTOMX_EA8002_DATA: .equ $ea8002

PHANTOMX_VERSION:     .equ $0000
PHANTOMX_MPU:         .equ $0001
PHANTOMX_WAIT:        .equ $0002
PHANTOMX_FDD_SWAP:    .equ $0003
PHANTOMX_VRAMDISK_ID: .equ $0010
PHANTOMX_TEMPERATURE: .equ $00f0


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  lea (strPhantomX,pc),a0
  bsr print_a0

  bsr PhantomX_Exists
  bne @f
    lea (strNoPX,pc),a0
    bsr print_a0
    bra 9f
  @@:

  lea (strBuf,pc),a0
  lea (strVersion,pc),a1
  STRCPY a1,a0,-1
  bsr PhantomX_GetVersion
  bsr PhantomX_VersionToString

  lea (strMpu,pc),a1
  STRCPY a1,a0,-1
  bsr PhantomX_GetMpu
  bsr PhantomX_MpuToString

  lea (strWait,pc),a1
  STRCPY a1,a0,-1
  bsr PhantomX_GetWait
  bsr PhantomX_WaitToString

  lea (strFddSwap,pc),a1
  STRCPY a1,a0,-1
  bsr PhantomX_GetFddSwap
  bsr PhantomX_FddSwapToString

  lea (strTemp0,pc),a1
  STRCPY a1,a0,-1
  bsr PhantomX_GetTemperature
  bsr PhantomX_TemperatureToString
  lea (strTemp1,pc),a1
  STRCPY a1,a0

  lea (strBuf,pc),a0
  bsr print_a0
9:
  DOS _EXIT

print_a0:
  pea (a0)
  DOS _PRINT
  addq.l #4,sp
  rts


.data
strPhantomX: .dc.b 'PhantomX: ',0
strNoPX:     .dc.b 'PhantomXは装着されていません。',CR,LF,0
strVersion:  .dc.b 'version ',0
strMpu:      .dc.b ', MPU ',0
strWait:     .dc.b ', wait ',0
strFddSwap:  .dc.b ', FDD swap ',0
strTemp0:    .dc.b ', SOC ',0
strTemp1:    .dc.b '℃',CR,LF,0

.bss
.even
strBuf: .ds.b 256
.text


;PhantomXが装着されているか調べる。
;out d0/ccr
PhantomX_Exists::
  move.l a0,-(sp)
  lea (PHANTOMX_EA8000_REG),a0
  bsr DosBusErrWord
  bne @f
    moveq #1,d0
    bra 9f
  @@:
  moveq #0,d0
9:
  movea.l (sp)+,a0
  rts


;PhantomXのバージョンを取得する。
;  PhantomXの装着を確認しておくこと。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... バージョン(BCD 4桁、上位ワードは $0000)
PhantomX_GetVersion::
  moveq #PHANTOMX_VERSION,d0
  bra getData


;PhantomXのエミュレーションMPUを取得する。
;  PhantomXの装着を確認しておくこと。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... MPUの種類 0:68000 3:68030 4:68040 6:68060
PhantomX_GetMpu::
  moveq #PHANTOMX_MPU,d0
  bra getData


;PhantomXのウェイトレベルを取得する。
;  PhantomXの装着を確認しておくこと。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... ウェイトレベル(0,1...7)
PhantomX_GetWait::
  moveq #PHANTOMX_WAIT,d0
  bra getData


;PhantomXのFDDスワップ設定を取得する。
;  PhantomXの装着を確認しておくこと。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 0:off 1:on
PhantomX_GetFddSwap::
  moveq #PHANTOMX_FDD_SWAP,d0
  bsr getData
  andi #1,d0
  rts


;Raspberry Pi SOCの温度を取得する。
;  PhantomXの装着を確認しておくこと。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 温度(BCD 4桁、上位ワードは $0000)
PhantomX_GetTemperature::
  moveq #.notb.PHANTOMX_TEMPERATURE,d0
  not.b d0
  bra getData


getData:
  PUSH_SR_DI
  move d0,(PHANTOMX_EA8000_REG)
  move (PHANTOMX_EA8002_DATA),d0
  POP_SR
  rts


;PhantomXのバージョンを文字列化する。
;in
;  d0.l ... バージョン(PhantomX_GetVersion の返り値)
;  a0.l ... 文字列バッファ(今のところ8バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
PhantomX_VersionToString::
  PUSH d1-d2
  bsr toHexString1  ;10の位
  moveq #$f,d1
  and.b d0,d1
  bne @f
    subq.l #1,a0  ;10の位が0だったら省略する
  @@:
  bsr toHexString1  ;1の位
  move.b #'.',(a0)+
  bsr toHexString2  ;小数部
  POP d1-d2
  rts


;PhantomXのエミュレーションMPUを文字列化する。
;in
;  d0.l ... MPU(PhantomX_GetMpu の返り値)
;  a0.l ... 文字列バッファ(今のところ8バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
PhantomX_MpuToString::
  move.b #'6',(a0)+
  move.b #'8',(a0)+
  move.b #'0',(a0)+
  addi.b #'0',d0
  move.b d0,(a0)+
  move.b #'0',(a0)+
  clr.b (a0)
  rts


;PhantomXのウェイトレベルを文字列化する。
;in
;  d0.l ... ウェイトレベル(PhantomX_GetWait の返り値)
;  a0.l ... 文字列バッファ(今のところ8バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
PhantomX_WaitToString::
  addi.b #'0',d0
  move.b d0,(a0)+
  clr.b (a0)
  rts


;PhantomXのFDDスワップ設定を文字列化する。
;in
;  d0.l ... FDDスワップ設定(PhantomX_GetFddSwap の返り値)
;  a0.l ... 文字列バッファ(今のところ8バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
PhantomX_FddSwapToString::
  move.l a1,-(sp)
  lea (strOff,pc),a1
  lsr #1,d0
  bcc @f
    addq.l #strOn-strOff,a1
  @@:
  STRCPY a1,a0,-1
  movea.l (sp)+,a1
  rts

strOff: .dc.b 'off',0
strOn:  .dc.b 'on',0
.even


;Raspberry Pi SOCの温度を文字列化する。
;in
;  d0.l ... 温度(PhantomX_GetTemperature の返り値)
;  a0.l ... 文字列バッファ(今のところ8バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
PhantomX_TemperatureToString::
  PUSH d1-d2
  bsr toHexString2
  move.b #'.',(a0)+
  bsr toHexString2
  POP d1-d2
  rts


toHexString1:
  moveq #1-1,d2
  bra @f
toHexString2:
  moveq #2-1,d2
  @@:
    rol #4,d0
    moveq #$f,d1
    and.b d0,d1
    move.b (hexTable,pc,d1.w),(a0)+
  dbra d2,@b
  clr.b (a0)
  rts

hexTable: .dc.b '0123456789abcdef'
.even


  DEFINE_DOSBUSERRWORD DosBusErrWord


.end ProgramStart

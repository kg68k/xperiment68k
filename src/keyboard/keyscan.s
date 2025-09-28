.title keyscan - show keyboard scan code

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

.include iomap.mac
.include macro.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


MFP_USART_RCV_BUF_FULL_VEC: .equ $4c

SCANCODE_COMPACT:   .equ $fe
SCANCODE_CONNECTED: .equ $ff

USART_BUF_SIZE: .equ 16


.cpu 68000
.text

Start:
  IOCS_B_PRINT (Notice,pc)

  bsr UsartInitBuffer
  bsr UsartHook
  bsr mainLoop
  bsr UsartUnhook

  DOS _EXIT

mainLoop:
  1:
    bsr UsartReadFromBuffer
    move.l d0,d1
    bmi @f
      move.l d0,-(sp)
      bsr printScanCode
      move.l (sp)+,d0
      bsr printKeyName
      B_PRINT_CRLF
    @@:
    IOCS _MS_GETDT
    tst.b d0
    beq @f
      bsr requestIdentifyCompact  ;右ボタン押し下げでCompactキーボード判別要求
      bra 1b
    @@:
    cmpi #$0100,d0  ;左ボタン押し下げで終了
    bcs 1b
  rts

requestIdentifyCompact:
  @@:
    IOCS _MS_GETDT
  tst.b d0
  bne @b  ;右ボタンが離されるまで待つ

  IOCS _MS_CUROF  ;マウスポインタ消去
  moveq #-1,d1
  IOCS _SKEY_MOD  ;ソフトキーボード消去

  moveq #$47,d0
  bsr UsertSendData

  IOCS_B_PRINT (ReqIdentifyCompact,pc)
  rts


;MFP USART データ送信
UsertSendData:
  move.l d0,d1
  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,-(sp)

  move.l d1,d0
  bsr OutputKeyboardControl

  move.l (sp)+,d0
  bmi @f
    movea.l d0,a1
    IOCS _B_SUPER
  @@:
  rts

OutputKeyboardControl:
  move sr,d1
  @@:
    move d1,sr
    nop
    DI
    tst.b (MFP_TSR)
  bpl @b

  move.b d0,(MFP_UDR)
  move d1,sr
  rts

;MFP USART 受信バッファを初期化する
UsartInitBuffer:
  lea (UsartBuffer,pc),a0
  move.l a0,(UsartReadPtr)
  move.l a0,(UsartWritePtr)
  clr (UsartDataLength)
  rts

;MFP USART 受信バッファフル割り込みを差し替える
UsartHook:
  moveq #MFP_USART_RCV_BUF_FULL_VEC,d1
  lea (UsartInt,pc),a1
  IOCS _B_INTVCS
  move.l d0,(UsartOldVec)
  rts

;MFP USART 受信バッファフル割り込みをもとに戻す
UsartUnhook:
  moveq #MFP_USART_RCV_BUF_FULL_VEC,d1
  movea.l (UsartOldVec,pc),a1
  IOCS _B_INTVCS
  rts

;MFP USART 受信バッファフル割り込み
UsartInt:
  PUSH d0/a0
  move.b (MFP_UDR),d0
  cmpi #USART_BUF_SIZE,(UsartDataLength)
  beq 9f
    addq #1,(UsartDataLength)
    movea.l (UsartWritePtr,pc),a0
    move.b d0,(a0)+
    cmpa.l #UsartBufferEnd,a0
    bne @f
      lea (UsartBuffer,pc),a0
    @@:
    move.l a0,(UsartWritePtr)
  9:
  POP d0/a0
  rte

;MFP USART 受信データを読み込む
;out d0.l = $00-$ff: 受信データ
;         = -1: データなし
UsartReadFromBuffer:
  clr.l -(sp)  ;return value

  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,-(sp)

  bsr UsartReadFromBufferSuper
  move.l d0,(4,sp)

  move.l (sp)+,d0
  bmi @f
    movea.l d0,a1
    IOCS _B_SUPER
  @@:
  move.l (sp)+,d0
  rts

;MFP USART 受信データを読み込む(スーパーバイザモード専用)
UsartReadFromBufferSuper:
  move sr,d1
  DI
  move (UsartDataLength,pc),d0
  beq 8f
    subq #1,(UsartDataLength)
    movea.l (UsartReadPtr,pc),a0
    moveq #0,d0
    move.b (a0)+,d0
    cmpa.l #UsartBufferEnd,a0
    bne @f
      lea (UsartBuffer,pc),a0
    @@:
    move.l a0,(UsartReadPtr)
    bra 9f
  8:
    moveq #-1,d0
  9:
  move d1,sr
  rts


printKeyName:
  cmpi.b #SCANCODE_COMPACT,d0
  lea (ScanCode_fe,pc),a1
  beq 8f
  lea (ScanCode_ff,pc),a1
  bhi 8f
    moveq #$7f,d1
    and.b d0,d1
    lea (KeyDown,pc),a1
    tst.b d0
    bpl @f
      addq.l #KeyUp-KeyDown,a1
    @@:
    IOCS _B_PRINT
  
    lea (keyTable,pc),a1
    add d1,d1
    add (a1,d1.w),a1
  8:
  IOCS _B_PRINT
  rts

printScanCode:
  lea (Buffer,pc),a0
  move.b #'$',(a0)+
  bsr ToHexString2
  move.b #' ',(a0)+
  clr.b (a0)
  IOCS_B_PRINT (Buffer,pc)
  rts

  DEFINE_TOHEXSTRING2 ToHexString2


.data

Notice: .dc.b 'マウス左ボタンで終了、右ボタンでキーボード判別コマンドを送信します。',CR,LF,0
ReqIdentifyCompact: .dc.b 'キーボード判別コマンド($47)を送信しました。',CR,LF,0

ScanCode_fe: .dc.b 'Compact',0
ScanCode_ff: .dc.b 'Connected',0

KeyDown: .dc.b '+',0
KeyUp:   .dc.b '-',0

KEYLIST: .macro macroName
  macroName key00,'$00'
  macroName key01,'ESC'
  macroName key02,'1'
  macroName key03,'2'
  macroName key04,'3'
  macroName key05,'4'
  macroName key06,'5'
  macroName key07,'6'
  macroName key08,'7'
  macroName key09,'8'
  macroName key0a,'9'
  macroName key0b,'0'
  macroName key0c,'-'
  macroName key0d,'^'
  macroName key0e,'\'
  macroName key0f,'BS'
  macroName key10,'TAB'
  macroName key11,'Q'
  macroName key12,'W'
  macroName key13,'E'
  macroName key14,'R'
  macroName key15,'T'
  macroName key16,'Y'
  macroName key17,'U'
  macroName key18,'I'
  macroName key19,'O'
  macroName key1a,'P'
  macroName key1b,'@'
  macroName key1c,'['
  macroName key1d,'RETURN'
  macroName key1e,'A'
  macroName key1f,'S'
  macroName key20,'D'
  macroName key21,'F'
  macroName key22,'G'
  macroName key23,'H'
  macroName key24,'J'
  macroName key25,'K'
  macroName key26,'L'
  macroName key27,';'
  macroName key28,':'
  macroName key29,']'
  macroName key2a,'Z'
  macroName key2b,'X'
  macroName key2c,'C'
  macroName key2d,'V'
  macroName key2e,'B'
  macroName key2f,'N'
  macroName key30,'M'
  macroName key31,','
  macroName key32,'.'
  macroName key33,'/'
  macroName key34,'_'
  macroName key35,'SPACE'
  macroName key36,'HOME'
  macroName key37,'DEL'
  macroName key38,'ROLL_UP'
  macroName key39,'ROLL_DOWN'
  macroName key3a,'UNDO'
  macroName key3b,'←'
  macroName key3c,'↑'
  macroName key3d,'→'
  macroName key3e,'↓'
  macroName key3f,'CLR'
  macroName key40,'ten/'
  macroName key41,'ten*'
  macroName key42,'ten-'
  macroName key43,'ten7'
  macroName key44,'ten8'
  macroName key45,'ten9'
  macroName key46,'ten+'
  macroName key47,'ten4'
  macroName key48,'ten5'
  macroName key49,'ten6'
  macroName key4a,'ten='
  macroName key4b,'ten1'
  macroName key4c,'ten2'
  macroName key4d,'ten3'
  macroName key4e,'ENTER'
  macroName key4f,'ten0'
  macroName key50,'ten,'
  macroName key51,'ten.'
  macroName key52,'記号入力'
  macroName key53,'登録'
  macroName key54,'HELP'
  macroName key55,'XF1'
  macroName key56,'XF2'
  macroName key57,'XF3'
  macroName key58,'XF4'
  macroName key59,'XF5'
  macroName key5a,'かな'
  macroName key5b,'ローマ字'
  macroName key5c,'コード入力'
  macroName key5d,'CAPS'
  macroName key5e,'INS'
  macroName key5f,'ひらがな'
  macroName key60,'全角'
  macroName key61,'BREAK'
  macroName key62,'COPY'
  macroName key63,'F1'
  macroName key64,'F2'
  macroName key65,'F3'
  macroName key66,'F4'
  macroName key67,'F5'
  macroName key68,'F6'
  macroName key69,'F7'
  macroName key6a,'F8'
  macroName key6b,'F9'
  macroName key6c,'F10'
  macroName key6d,'$6d'
  macroName key6e,'$6e'
  macroName key6f,'$6f'
  macroName key70,'SHIFT'
  macroName key71,'CTRL'
  macroName key72,'OPT.1'
  macroName key73,'OPT.2'
  macroName key74,'Num'
  macroName key75,'$75'
  macroName key76,'$76'
  macroName key77,'$77'
  macroName key78,'$78'
  macroName key79,'$79'
  macroName key7a,'$7a'
  macroName key7b,'$7b'
  macroName key7c,'$7c'
  macroName key7d,'$7d'
  macroName key7e,'$7e'
  macroName key7f,'$7f'
.endm

KEY_OFFSET: .macro label,str
  .dc label-keyTable
.endm

KEY_NAME: .macro label,str
  label: .dc.b str,0
.endm

.even
keyTable:
  KEYLIST KEY_OFFSET

  KEYLIST KEY_NAME


.bss
.quad

UsartOldVec: .ds.l 1
UsartReadPtr:  .ds.l 1
UsartWritePtr: .ds.l 1
UsartDataLength: .ds 1

UsartBuffer: .ds.b USART_BUF_SIZE
UsartBufferEnd:

Buffer: .ds.b 128


.end

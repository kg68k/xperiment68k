.title bitsns - show IOCS _BITSNS result

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include macro.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


KEYCODE_GROUP_NUM: .equ $f


.cpu 68000
.text

Start:
  lea (Notice,pc),a1
  IOCS _B_PRINT

  lea (BitsnsBuffer0,pc),a2
  lea (BitsnsBuffer1,pc),a3

  lea (a2),a0
  bsr readBitsns
  lea (a2),a0
  bsr printBitsns
  lea (CrLf,pc),a1
  IOCS _B_PRINT

  loop:
    DOS _CHANGE_PR
    exg a2,a3

    lea (a2),a0
    bsr readBitsns
    lea (a2),a0
    lea (a3),a1
    bsr compareBitsns
    beq @f
      lea (a2),a0
      lea (a3),a1
      bsr printBitsnsWithChange
      bsr FlushIocsKey
      bra loop
    @@:
  IOCS _MS_GETDT
  tst d0
  beq loop

  bsr FlushIocsKey
  bsr FlushDosKey
  DOS _EXIT


@@:
  IOCS _B_KEYINP
FlushIocsKey:
  IOCS _B_KEYSNS
  tst.l d0
  bne @b
  rts

FlushDosKey:
  move.l #(.low._INPOUT)<<16+$ff,-(sp)
  DOS _KFLUSH
  addq.l #4,sp
  rts


compareBitsns:
  moveq #KEYCODE_GROUP_NUM-1,d0
  @@:
    cmpm.b (a0)+,(a1)+
  dbne d0,@b
  rts


readBitsns:
  lea (KEYCODE_GROUP_NUM,a0),a0
  moveq #KEYCODE_GROUP_NUM-1,d1
  @@:
    IOCS _BITSNS
    move.b d0,-(a0)
  dbra d1,@b
  rts


printBitsnsWithChange:
  PUSH a0-a1
  bsr printBitsns
  lea (Space,pc),a1
  IOCS _B_PRINT
  POP a0-a1

  bsr printKeyChange

  lea (CrLf,pc),a1
  IOCS _B_PRINT
  rts

printKeyChange:
  PUSH d2-d7/a2-a3
  lea (a0),a2  ;現在のキー状態
  lea (a1),a3  ;前回のキー状態
  moveq #0,d7  ;キーコードグループ番号
  1:
    move.b (a2)+,d4
    move.b (a3)+,d5
    eor.b d4,d5  ;変化のあったキーが%1になる
    beq 9f
      moveq #0,d6  ;ビット位置
      2:
        btst d6,d5
        beq 8f
          ;キー状態に変化があった
          btst d6,d4
          sne d0  ;$00=key up, $ff=key down
          move d7,d1
          lsl #3,d1
          or d6,d1  ;スキャンコード
          bsr printKeyName
        8:
        addq #1,d6
      cmpi #8,d6
      bne 2b
    9:
    addq #1,d7
  cmpi  #KEYCODE_GROUP_NUM,d7
  bne 1b

  POP d2-d7/a2-a3
  rts

printKeyName:
  lea (KeyDown,pc),a1
  tst.b d0
  bne @f
    addq.l #KeyUp-KeyDown,a1
  @@:
  IOCS _B_PRINT

  lea (keyTable,pc),a1
  add d1,d1
  add (a1,d1.w),a1
  IOCS _B_PRINT
  rts


printBitsns:
  PUSH d6-d7
  lea (a0),a1
  lea (Buffer,pc),a0
  moveq #%0001_0001,d6  ;4バイトごとに | を表示する
  moveq #KEYCODE_GROUP_NUM-1,d7
  1:
    move.b (a1)+,d0
    bsr ToHexString2
    move.b #' ',(a0)+
    rol.b #1,d6
    bcc @f
      move.b #'|',(a0)+
      move.b #' ',(a0)+
    @@:
  dbra d7,1b
  clr.b -(a0)

  lea (Buffer,pc),a1
  IOCS _B_PRINT
  POP d6-d7
  rts


  DEFINE_TOHEXSTRING2 ToHexString2


.data

Notice: .dc.b 'マウスボタン押し下げで終了します。',CR,LF,0
CrLf: .dc.b CR,LF,0
Space: .dc.b ' ',0

KeyDown: .dc.b ' +',0
KeyUp:   .dc.b ' -',0

KEYLIST: .macro macroName
  macroName key00,'??'
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
.even

Buffer: .ds.b 128

BitsnsBuffer0: .ds.b KEYCODE_GROUP_NUM
BitsnsBuffer1: .ds.b KEYCODE_GROUP_NUM


.end

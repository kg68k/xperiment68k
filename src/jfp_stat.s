.title jfp_stat - show FEP status

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

.include xputil.mac


;日本語FPのファンクションコール番号
FP_GET_CONV_MODE:   .equ 2
FP_GET_FLUSH_MODE:  .equ 4
FP_GET_INPUT_MODE:  .equ 6
FP_SET_LOCK_MODE:   .equ 7
FP_GET_LOCK_MODE:   .equ 8
FP_GET_CODE_MODE:   .equ 10
FP_GET_LEARN_MODE:  .equ 12
FP_GET_FP_VERSION:  .equ 50
FP_GET_DIC_VERSION: .equ 51
FP_GET_ECHO_MODE:   .equ 55


.offset 0
TBL_FUNC_NO:   .ds.b 1
TBL_COUNT:     .ds.b 1
TBL_TITLE_OFS: .ds.w 1
TBL_OFS_BASE:
TBL_LIST:
.text


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d1,d7  ;hex
  tst d0
  beq @f
    bsr WaitReturnKey  ;-k指定時はキー入力を待つ
  @@:

  moveq #FP_GET_FP_VERSION,d0
  lea (strFpVersion,pc),a0
  bsr GetAndPrintVersion
  moveq #FP_GET_DIC_VERSION,d0
  lea (strDicVersion,pc),a0
  bsr GetAndPrintVersion

  lea (ConvModeTable,pc),a0
  bsr GetAndPrintMode
  lea (FlushModeTable,pc),a0
  bsr GetAndPrintMode
  lea (InputModeTable,pc),a0
  bsr GetAndPrintMode
  lea (LockModeTable,pc),a0
  bsr GetAndPrintMode
  lea (CodeModeTable,pc),a0
  bsr GetAndPrintMode
  lea (LearnModeTable,pc),a0
  bsr GetAndPrintMode
  lea (EchoModeTable,pc),a0
  bsr GetAndPrintMode

  bsr PrintFpEnabled

  DOS _EXIT


;直接入力か変換モードか調べて表示する
;  直接調べるファンクションコールはないので、コール番号7で戻り値が d0.l == 2
;  かどうかで判別する。ただし固定モードを変更しないようにコール番号8で状態を調べ、
;  「現状と同じモードに変更する」という形をとる。
;  FEPが組み込まれていない場合はDOS _KNJCTRLで-1が返るので、特別扱いしなくても
;  直接入力として扱われる。
PrintFpEnabled:
  DOS_PRINT (strFpMode,pc)

  pea (FP_GET_LOCK_MODE)
  or.l d7,(sp)
  DOS _KNJCTRL
  move.l d0,(sp)
  pea (FP_SET_LOCK_MODE)
  or.l d7,(sp)
  DOS _KNJCTRL
  addq.l #8,sp

  lea (strFpDisabled,pc),a0
  subq.l #2,d0
  bne @f
    lea (strFpEnabled,pc),a0  ;d0.l==2が返った場合は変換モードになっている。
  @@:
  DOS_PRINT (a0)
  DOS_PRINT (CrLf,pc)
  rts


WaitReturnKey:
  DOS_PRINT (strTypeReturnKey,pc)
  subq.l #8,sp  ;入力バッファを確保
  move #4<<8+0,(sp)
  pea (sp)
  DOS _GETS
  addq.l #4,sp
  addq.l #8,sp  ;入力バッファを解放
  rts


GetAndPrintVersion:
  move.l d0,-(sp)
  or.l d7,(sp)
  DOS_PRINT (a0)
  DOS _KNJCTRL
  addq.l #4,sp
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  rts


GetAndPrintMode:
  move (TBL_TITLE_OFS,a0),d0
  DOS_PRINT (TBL_OFS_BASE,a0,d0.w)

  moveq #0,d0
  move.b (TBL_FUNC_NO,a0),d0
  move.l d0,-(sp)
  or.l d7,(sp)
  DOS _KNJCTRL
  addq.l #4,sp

  move.l d0,d2
  bsr Print$4_4
  DOS_PRINT (Space,pc)

  moveq #0,d0
  move.b (TBL_COUNT,a0),d0
  lea (strUnknown,pc),a1
  cmp.l d0,d2
  bcc @f
    add.l d2,d2
    move (TBL_LIST,a0,d2.l),d0  ;文字列までのオフセット
    lea (TBL_OFS_BASE,a0,d0.w),a1
  @@:
  DOS_PRINT (a1)

  DOS_PRINT (CrLf,pc)
  rts


AnalyzeArgument:
  PUSH d6-d7
  moveq #0,d6  ;-k
  moveq #0,d7  ;hex
  1:
    SKIP_SPACE a0
    beq 9f
    cmpi.b #'-',(a0)
    bne @f
      cmpi.b #'k',(1,a0)
      bne PrintUsage
        addq.l #2,a0
        moveq #1,d6  ;-k
        bra 1b
    @@:
    FPACK __STOH
    bcs NumberError
    move.l d0,d7  ;hex
    bra 1b
  9:
  move.l d7,d1
  move.l d6,d0
  POP d6-d7
  rts


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT

NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strUsage:
  .dc.b 'usage: jfp_stat [-k] [hex]',CR,LF
  .dc.b '  -k ... 起動時にRETURNキー入力を待つ',CR,LF
  .dc.b '  hex ... ファンクションコール番号にORする値',CR,LF
  .dc.b 0

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0


strTypeReturnKey: .dc.b 'RETURNキーを押してください。',CR,LF,0

strFpVersion:  .dc.b '日本語FPバージョン: ',0
strDicVersion: .dc.b 'メイン辞書バージョン: ',0

strUnknown: .dc.b '不明',0

.even
ConvModeTable:
  .dc.b FP_GET_CONV_MODE
  .dc.b (ConvModeTableEnd-@f)/2
  .dc strConvMode-@f
@@:
  .dc strConvMode0-@b
  .dc strConvMode1-@b
  .dc strConvMode2-@b
  .dc strConvMode3-@b
ConvModeTableEnd:

strConvMode:  .dc.b 'かな漢字変換モード: ',0
strConvMode0: .dc.b '変換なし',0
strConvMode1: .dc.b '一括変換(先読みなし)',0
strConvMode2: .dc.b '一括変換(先読みあり)',0
strConvMode3: .dc.b '逐次変換',0

.even
FlushModeTable:
  .dc.b FP_GET_FLUSH_MODE
  .dc.b (FlushModeTableEnd-@f)/2
  .dc strFlushMode-@f
@@:
  .dc strFLushMode0-@b
  .dc strFLushMode1-@b
FlushModeTableEnd:

strFlushMode:  .dc.b 'フラッシュモード: ',0
strFLushMode0: .dc.b '解除',0
strFLushMode1: .dc.b '設定',0

.even
InputModeTable:
  .dc.b FP_GET_INPUT_MODE
  .dc.b (InputModeTableEnd-@f)/2
  .dc strInputMode-@f
@@:
  .dc strInputMode0-@b  ;bit2, bit1, bit0のビットマップ値だが面倒なのでベタ書き。
  .dc strInputMode1-@b
  .dc strInputMode2-@b
  .dc strInputMode3-@b
  .dc strInputMode4-@b
  .dc strInputMode5-@b
  .dc strInputMode6-@b
  .dc strInputMode7-@b
InputModeTableEnd:

strInputMode:  .dc.b '入力モード: ',0
strInputMode0: .dc.b '半角 カタカナ 通常モード',0
strInputMode1: .dc.b '半角 カタカナ ローマ字変換',0
strInputMode2: .dc.b '半角 ひらがな 通常モード',0
strInputMode3: .dc.b '半角 ひらがな ローマ字変換',0
strInputMode4: .dc.b '全角 カタカナ 通常モード',0
strInputMode5: .dc.b '全角 カタカナ ローマ字変換',0
strInputMode6: .dc.b '全角 ひらがな 通常モード',0
strInputMode7: .dc.b '全角 ひらがな ローマ字変換',0

.even
LockModeTable:
  .dc.b FP_GET_LOCK_MODE
  .dc.b (LockModeTableEnd-@f)/2
  .dc strLockMode-@f
@@:
  .dc strLockMode0-@b
  .dc strLockMode1-@b
LockModeTableEnd:

strLockMode:  .dc.b '固定モード: ',0
strLockMode0: .dc.b '固定',0
strLockMode1: .dc.b '固定解除',0

.even
CodeModeTable:
  .dc.b FP_GET_CODE_MODE
  .dc.b (CodeModeTableEnd-@f)/2
  .dc strCodeMode-@f
@@:
  .dc strCodeMode0-@b
  .dc strCodeMode1-@b
CodeModeTableEnd:

strCodeMode:  .dc.b 'JIS/区点モード: ',0
strCodeMode0: .dc.b 'JIS/Shift-JIS',0
strCodeMode1: .dc.b '区点',0

.even
LearnModeTable:
  .dc.b FP_GET_LEARN_MODE
  .dc.b (LearnModeTableEnd-@f)/2
  .dc strLearnMode-@f
@@:
  .dc strLearnMode0-@b
  .dc strLearnMode1-@b
LearnModeTableEnd:

strLearnMode:  .dc.b '学習モード: ',0
strLearnMode0: .dc.b '一時学習(メモリ学習)',0
strLearnMode1: .dc.b '辞書更新学習(ディスク学習)',0

.even
EchoModeTable:
  .dc.b FP_GET_ECHO_MODE
  .dc.b (EchoModeTableEnd-@f)/2
  .dc strEchoMode-@f
@@:
  .dc strEchoMode0-@b
  .dc strEchoMode1-@b
EchoModeTableEnd:

strEchoMode:  .dc.b 'エコーモード: ',0
strEchoMode0: .dc.b 'システムライン',0
strEchoMode1: .dc.b 'エコー',0

strFpMode:     .dc.b '変換モード: ',0
strFpDisabled: .dc.b '変換なし(直接入力)',0
strFpEnabled:  .dc.b '変換あり',0

Space: .dc.b ' ',0
CrLf: .dc.b CR,LF,0


.end ProgramStart

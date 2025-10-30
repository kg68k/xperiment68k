.title minish - minimal shell

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
.include filesys.mac
.include process.mac

.include xputil.mac

VERSION: .reg '1.0.0'


.cpu 68000
.text

ProgramStart:
  bra.s @f
    .dc.b 'minish ',VERSION,0
    .even
  @@:
  move.l (PSP_ShellFlag,a0),d7

  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  DOS_PRINT (strStartMessage,pc)
  bsr mainLoop

  tst.l d7
  beq @f  ;通常起動
    DOS_PRINT (strExitShell,pc)  ;シェル起動
  @@:
  DOS _EXIT

mainLoop:
  bsr PrintPrompt

  lea (GetsBuffer,pc),a0
  move.b #255,(INPPTR_MAX,a0)
  pea (a0)
  DOS _GETS
  addq.l #4,sp
  move.l d0,d1
  DOS_PRINT (strCrLf,pc)

  addq.l #INPPTR_BUFFER,a0
  bsr SkipBlank
  tst.b (a0)
  beq mainLoop

  lea (GetsBuffer,pc),a1  ;pathchk用にバッファ先頭に転送する
  STRCPY a0,a1

  lea (GetsBuffer,pc),a0
  cmpi #':q',(a0)
  beq 9f  ;終了コマンド :q

  bsr Execute
  tst.l d0
  bmi @f
    move.l d1,d0
    bsr PrintExitCode  ;終了コードを表示
  @@:
  bra mainLoop
9:
  rts


@@:
  addq.l #1,a0
SkipBlank:
  cmpi.b #SPACE,(a0)
  beq @b
  cmpi.b #TAB,(a0)
  beq @b
  rts


PrintPrompt:
  link a6,#-(sizeof_NAMECK+1)
  pea (sp)
  pea (strEmpty,pc)
  DOS _NAMECK  ;カレントディレクトリのパス名を得る
  addq.l #8,sp
  tst.l d0
  lea (strUnknownPath,pc),a0
  bmi @f
    lea (NAMECK_Path+.sizeof.('\'),sp),a0
    tst.b (a0)
    beq 1f  ;ルートディレクトリなら'D:\'のまま表示する
      STREND a0
      clr.b -(a0)  ;パス名末尾の'\'を削除する
    1:
    lea (NAMECK_Drive,sp),a0
  @@:
  DOS_PRINT (a0)
  DOS_PRINT (strPromptFooter,pc)

  unlk a6
  rts


Execute:
  PUSH d3-d7/a3-a6

  clr.l -(sp)
  pea (CmdLineBuffer,pc)
  pea (a0)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bpl @f
    lea (strPathchkError,pc),a0
    bsr PrintExecError
    bra 9f
  @@:

  clr.l -(sp)
  pea (CmdLineBuffer,pc)
  pea (a0)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  move.l d0,d1
  bpl @f
    lea (strLoadExecError,pc),a0
    bsr PrintExecError
    bra 9f
  @@:

  moveq #0,d0
9:
  POP d3-d7/a3-a6
  rts

PrintExecError:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr Print$4_4
  DOS_PRINT (strCrLf,pc)
  moveq #-1,d0
  rts


PrintExitCode:
  cmpi.l #$100,d0
  bcc 1f
    bsr PrintDecString
    bra @f
  1:
    bsr Print$4_4
  @@:
  DOS_PRINT (strSemiColon,pc)  ;改行せず、続けてプロンプトを表示させる
  rts


  DEFINE_PRINT$4_4 Print$4_4
  DEFINE_PRINTDECSTRING PrintDecString


.data

strStartMessage:
  .dc.b CR,LF
  .dc.b 'minish ',VERSION,CR,LF
  .dc.b '  input ":q" or ^C to quit.',CR,LF
  .dc.b CR,LF
  .dc.b 0

strEmpty: .dc.b 0
strUnknownPath: .dc.b '??',0
strPromptFooter: .dc.b '>',0
strSemiColon: .dc.b '; ',0

strPathchkError: .dc.b '実行ファイル検索エラー: ',0
strLoadExecError: .dc.b 'ファイル実行エラー: ',0

strExitShell: .dc.b 'シェルとして起動しましたが、終了してHuman68kに戻ります。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.bss

.even
GetsBuffer: .ds.b sizeof_INPPTR

CmdLineBuffer: .ds.b sizeof_CMDLINE


.end ProgramStart

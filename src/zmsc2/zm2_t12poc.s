.title zm2_t12poc - Z-MUSIC v2 trap #12 (COPY key) memory overwriting PoC

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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


MARKER: .equ $DEADBEEF


.cpu 68000
.text

ProgramStart:
  lea (a0),a5  ;自分自身のPSP

  lea (sizeof_MEMBLK,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  bsr AnalyzeArguments
  tst.l d0
  beq ParentMode
  bgt ChildMode

  PRINT_1LINE_USAGE 'usage: zm2_t12poc [zmsc.x]'
  DOS _EXIT


;親プロセスモード
ParentMode:
  bsr PathchkZmscX
  lea (a5),a0
  bsr MakeSelfPath
  bsr MakeCmdline  ;-! d:\dir\zmsc.x

  bsr ExecuteSelfAsChild
  movea.l a0,a5  ;実行した子プロセスのメモリ管理ポインタ
  move.l a0,d0   ;(ただし子プロセスは終了しているので、メモリブロックも解放済み)
  lea (strChildAddress,pc),a0
  bsr PrintMemoryBlock

  bsr AllocateMemory
  move.l d0,d7  ; 確保したメモリブロックのメモリ管理ポインタ(データ領域の先頭ではない)
  lea (strMemblkAddress,pc),a0
  bsr PrintMemoryBlock

  ;常駐したzmsc.xの親プロセス(=子プロセスモードで実行した自分自身の実行ファイル)
  ;と同じアドレスにメモリブロックが確保される必要がある
  cmpa.l d7,a5
  bne AddressMismatchError

  move.l #MARKER,(PSP_Trap12,a5)
  move.l a5,-(sp)
  bsr ExecuteZmscToRelease
  movea.l (sp)+,a5

  cmpi.l #MARKER,(PSP_Trap12,a5)
  bne 1f
    DOS_PRINT (strMemoryNotBroken,pc)
    bra 9f
  1:
    DOS_PRINT (strMemoryHasBroken,pc)
    move.l (PSP_Trap12,a5),d0
    bsr Print$4_4
    DOS_PRINT_CRLF
9:
  DOS _EXIT


;zmsc.xを検索する
PathchkZmscX:
  lea (ZmscXPathBuffer,pc),a1
  STRCPY a0,a1

  clr.l -(sp)
  pea (CmdLineBuffer,pc)
  pea (ZmscXPathBuffer,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi PathchkError
  rts


;自分自身の実行ファイルのフルパスを作成する
;in a0.l 自分自身のPSP
MakeSelfPath:
  lea (SelfPathBuffer,pc),a2
  lea (PSP_Drive,a0),a1
  STRCPY a1,a2,-1
  lea (PSP_Filename,a0),a1
  STRCPY a1,a2
  rts


;子プロセスに渡すコマンドライン引数を作成する
MakeCmdline:
  lea (CmdLineBuffer+CMDLINE_BUFFER,pc),a1
  lea (strChildModeOption,pc),a0
  STRCPY a0,a1,-1
  lea (ZmscXPathBuffer,pc),a0
  STRCPY a0,a1

  lea (CmdLineBuffer+CMDLINE_BUFFER,pc),a1
  STRLEN a1,d0
  lea (CmdLineBuffer+CMDLINE_LEN,pc),a0
  move.b d0,(a0)  ;コマンドラインの文字列長
  rts


;自分自身の実行ファイルを実行する
;out d0.l/a0.l
ExecuteSelfAsChild:
  DOS_PRINT (strExecSelf,pc)

  clr.l -(sp)
  pea (CmdLineBuffer,pc)
  pea (SelfPathBuffer,pc)
  move #EXECMODE_LOAD,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi LoadError

  move.l a0,-(sp)  ;_EXECで破壊されるので保存
  pea (a4)
  move #EXECMODE_EXECONLY,-(sp)
  DOS _EXEC
  addq.l #6,sp
  movea.l (sp)+,a0  ;実行したプロセスのPSPアドレスを返す
  tst.l d0
  bmi ExecError
  rts


;メモリ管理ポインタの値を表示する
PrintMemoryBlock:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


;メモリを確保して、メモリ管理ポインタのアドレスを返す
AllocateMemory:
  move.l #sizeof_PSP-sizeof_MEMBLK,-(sp)
  DOS _MALLOC
  move.l d0,(sp)+
  bmi MallocError
  subi.l #sizeof_MEMBLK,d0
  rts


;zmsc.xを常駐解除させるために実行する
ExecuteZmscToRelease:
  clr.l -(sp)
  pea (ZmscReleaseCmdline,pc)
  pea (ZmscXPathBuffer,pc)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi ExecError
  rts


;子プロセスモード
ChildMode:
  DOS_PRINT (strExecutedAsChild,pc)

  bsr ExecuteZmscToKeep

  DOS _EXIT


;zmsc.xを常駐解除させるために実行する
ExecuteZmscToKeep:
  clr.l -(sp)
  pea (ZmscKeepCmdline,pc)
  pea (a0)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi ExecError
  rts


AnalyzeArguments:
  moveq #0,d1  ;標準では親プロセスモード
  lea (strZmscX,pc),a1
  1:
    SKIP_SPACE a0
    beq 9f
    cmpi.b #'-',(a0)
    beq @f
      lea (a0),a1  ;zmsc.xのパス指定
      bra 9f
    @@:
    addq.l #1,a0
    cmpi.b #'!',(a0)+
    bne @f
      moveq #1,d1  ;-! 子プロセスモードとして動作する
      bra 1b
    @@:
    moveq #-1,d1
  9:
  move.l d1,d0
  lea (a1),a0
  rts


AddressMismatchError:
  DOS_PRINT (strAdrsMismatchError,pc)
  bra Error2

PathchkError:
  lea (strPathchkError,pc),a0
  bra Error
LoadError:
  lea (strLoadError,pc),a0
  bra Error
ExecError:
  lea (strExecError,pc),a0
  bra Error
MallocError:
  lea (strMallocError,pc),a0
  bra Error

Error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
Error2:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4
  DEFINE_PRINT$4_4 Print$4_4


.data

strZmscX: .dc.b 'zmsc.x',0
strChildModeOption: .dc.b '-! ',0

strExecSelf: .dc.b '自分自身を子プロセスとして実行します。',CR,LF,0
strChildAddress:  .dc.b '子プロセスのロードアドレス:       ',0
strMemblkAddress: .dc.b '確保したメモリブロックのアドレス: ',0

strExecutedAsChild: .dc.b '子プロセスモードで起動しました。',CR,LF,0

strAdrsMismatchError:
  .dc.b 'メモリブロックを同じアドレスに確保できなかったため、処理を中断します。',CR,LF,0

strMemoryNotBroken: .dc.b 'メモリ内容は破壊されませんでした。',CR,LF,0
strMemoryHasBroken: .dc.b 'メモリ内容が破壊されました: ',0

strPathchkError: .dc.b 'pathchk error: ',0
strLoadError:    .dc.b 'load error: ',0
strExecError:    .dc.b 'exec error: ',0
strMallocError:  .dc.b 'malloc error: ',0

MAKE_CMDLINE: .macro str
  .dc.b .sizeof.(str)
  .dc.b str,0
.endm

ZmscKeepCmdline:    MAKE_CMDLINE '-p0 -t0'
ZmscReleaseCmdline: MAKE_CMDLINE '-r'


.bss
.even

SelfPathBuffer: .ds.b 92
ZmscXPathBuffer: .ds.b 92
CmdLineBuffer: .ds.b sizeof_CMDLINE


.end ProgramStart

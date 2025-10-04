.title existsdir - check if directory exists

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

.include xputil.mac


.cpu 68000
.text

Start:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    PRINT_1LINE_USAGE 'usage: existsdir <dir>'
    DOS _EXIT
  @@:

  lea (NamestsBuffer,pc),a3
  pea (a3)
  pea (a2)
  DOS _NAMESTS
  addq.l #8,sp
  tst.l d0
  lea (NamestsMessage,pc),a0
  bmi error

  lea (FilesBuffer,pc),a4
  move.b (NAMESTS_Wild,a3),d0
  beq noWildCard
    cmpi.b #-1,d0
    beq @f  
      ;ワイルドカードが使用されていた場合('foo/bar*.*')
      DOS_PRINT (WildCardMessage,pc)
      DOS _EXIT
    @@:
    ;指定したパス名の末尾がパスデリミタで終わっていた場合('foo/bar/')
    move #$0100+$ff,-(sp)  ;補完モード
    pea (a2)
    pea (a4)
    DOS _FILES
    lea (10,sp),sp
    move.l d0,d7
    lea (FilesMessage1,pc),a0
    bsr PrintResult

    tst.l d7
    beq dirExists  ;ディレクトリ内にエントリがあった(普通は'.'が見つかる)
    cmpi.l #DOSE_NOENT,d7
    beq dirExists  ;ディレクトリはあるがエントリがない(仮想ディレクトリの場合)

    cmpi.l #DOSE_NODIR,d7  ;ディレクトリがない
    beq dirNotExists       ;('foo/bar/'における'foo/'がない場合と'bar/'がない場合のどちらか)
    bra otherError

  ;指定したパス名の末尾がディレクトリ名で終わっていた場合('foo/bar')
  noWildCard:
    move #1<<FILEATR_DIRECTORY,-(sp)
    pea (a2)
    pea (a4)
    DOS _FILES
    lea (10,sp),sp
    move.l d0,d7
    lea (FilesMessage2,pc),a0
    bsr PrintResult

    tst.l d7
    beq dirExists  ;同名でディレクトリ属性のエントリがあった

    cmpi.l #DOSE_NOENT,d7
    beq dirNotExists  ;同名かつディレクトリ属性のエントリがない
    cmpi.l #DOSE_NODIR,d7
    beq dirNotExists  ;ディレクトリがない('foo/bar'における'foo/'がない場合)
    bra otherError

otherError:
  DOS_PRINT (OtherErrorMessage,pc)
  DOS _EXIT

dirExists:
  DOS_PRINT (ExistsMessage,pc)
  DOS _EXIT

dirNotExists:
  DOS_PRINT (NotExistsMessage,pc)
  DOS _EXIT


error:
  bsr PrintResult
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


PrintResult:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

WildCardMessage: .dc.b 'ワイルドカードは指定できません。',CR,LF,0

NamestsMessage: .dc.b 'DOS _NAMESTS: ',0
FilesMessage1: .dc.b 'DOS _FILES (atr=$01ff): ',0
FilesMessage2: .dc.b 'DOS _FILES (atr=$0010): ',0

ExistsMessage:     .dc.b 'ディレクトリが存在します。',CR,LF,0
NotExistsMessage:  .dc.b 'ディレクトリは存在しません。',CR,LF,0
OtherErrorMessage: .dc.b 'ディレクトリは存在しません(その他のエラー)。',CR,LF,0


.bss
.even

NamestsBuffer: .ds.b sizeof_NAMESTS
FilesBuffer:  .ds.b sizeof_FILES


.end

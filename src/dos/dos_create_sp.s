.title dos_create_sp - DOS _CREATE special mode

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

.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq NoArgError

  bsr OpenFile  ;既存ファイルを上書きしないよう確認する
  beq FileExistError

  lea (a0),a2
  moveq #1<<FILEATR_ARCHIVE,d0
  bsr CreateFile

  lea (a2),a0
  move #1<<FILEATR_ARCHIVE+$8000,d0
  bsr CreateFile

  DOS _EXIT


FileExistError:
  pea (FileExistMessage,pc)
  bra @f
NoArgError:
  pea (NoArgMessage,pc)
@@:
  DOS _PRINT
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


OpenFile:
  move #OPENMODE_READ,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  tst.l d0
  bmi @f
    move d0,-(sp)
    DOS _CLOSE
    addq.l #2,sp
    moveq #0,d0
@@:
  rts

CreateFile:
  move d0,-(sp)
  pea (a0)
  DOS _CREATE
  addq.l #6,sp

  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

NoArgMessage: .dc.b 'no filename',CR,LF,0
FileExistMessage: .dc.b '同名のファイルがすでに存在します。',CR,LF,0


.end ProgramStart

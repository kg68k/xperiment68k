.title dos_create_sp - DOS _CREATE special mode

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

.include dosdef.mac
.include console.mac
.include doscall.mac

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
  moveq #1<<ATR_ARC,d0
  bsr CreateFile

  lea (a2),a0
  move #$8000+1<<ATR_ARC,d0
  bsr CreateFile

  DOS _EXIT


FileExistError:
  pea (FileExistMessage,pc)
  bra @f
NoArgError:
  pea (NoArgMessage,pc)
@@:
  DOS _PRINT
  move #1,-(sp)
  DOS _EXIT2


OpenFile:
  move #ROPEN,-(sp)
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

  lea (Buffer,pc),a0
  move.b #'$',(a0)+
  bsr ToHexString4_4

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

NoArgMessage: .dc.b 'no filename',CR,LF,0
FileExistMessage: .dc.b '同名のファイルがすでに存在します。',CR,LF,0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart

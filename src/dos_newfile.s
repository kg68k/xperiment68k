.title dos_newfile - DOS _NEWFILE

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq NoArgError

  moveq #1<<FILEATR_ARCHIVE,d0
  bsr NewfileFile

  DOS _EXIT


NoArgError:
  DOS_PRINT (NoArgMessage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


NewfileFile:
  move d0,-(sp)
  pea (a0)
  DOS _NEWFILE
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
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart

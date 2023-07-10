.title pt_7e - print text: 0x7e (overline/tilde)

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


.include console.mac
.include doscall.mac


.cpu 68000
.text

ProgramStart:
  pea (Message,pc)
  DOS _PRINT
  addq.l #4,sp

  DOS _EXIT


.data

Message:
  .dc.b CR,LF
  .dc.b 'a',    $7e,'z ... $7e',CR,LF
  .dc.b CR,LF
  .dc.b 'a',$f0,$7e,'z ... $f07e (上付き',$f0,'1/',$f2,'4角文字カタカナ)',CR,LF
  .dc.b CR,LF
  .dc.b 'a',$f1,$7e,'z ... $f17e (上付き',$f0,'1/',$f2,'4角文字ひらがな)',CR,LF
  .dc.b CR,LF
  .dc.b 'a',$f2,$7e,'z ... $f27e (下付き',$f0,'1/',$f2,'4角文字カタカナ)',CR,LF
  .dc.b CR,LF
  .dc.b 'a',$f3,$7e,'z ... $f37e (下付き',$f0,'1/',$f2,'4角文字ひらがな)',CR,LF
  .dc.b CR,LF
  .dc.b 0


.end ProgramStart

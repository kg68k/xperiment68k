.title reset68k - software reset

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

.cpu 68000
.text

ProgramStart:
  addq.w #(d0Value+4-ProgramStart)/2,a4
  addq.w #(d0Value+4-ProgramStart)/2,a4
  move.l -(a4),d0
  trap #10

d0Value:
  .dc.b 'X68k'
  .dc.b 13,10


.end

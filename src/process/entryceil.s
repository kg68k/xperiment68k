.title entryceil - entry in the ceiling of memory

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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

.include doscall.mac


.cpu 68000
.text

Main:
  bsr.s @f  ;pea (d16,pc) の代わり
    .dc.b 'OK.',13,10,0
    .even
  @@:
  DOS _PRINT
  DOS _EXIT

Start:
  bra.s Main

;bra.s 命令を末尾にするとM68000の仕様で次のワードをリードして
;バスエラーが発生してしまうので、ダミーのデータを置く。
;バイトまたはワード単位でHUPAIR準拠表示を比較するコードに途中まで
;準拠表示と信じ込ませるために、ダミーデータは'#H'とする。
  .dc.b '#H'

.end Start

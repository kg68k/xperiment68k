.title si_memory - show information: main memory and high memory

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

.include xputil.mac


;IOCSワーク
IOCS_VECTBL: .equ $400
MPUTYPE: .equ $cbc

;HIMEM.SYSで使用可能になるIOCSコール
.ifndef _HIMEM
_HIMEM: .equ $f8
.endif
_HIMEM_GETSIZE: .equ 3
_HIMEM_GETAREA: .equ 10  ;TS16DRVp.X v1.2+ で拡張されたコール

;DOSワーク
DOS_MEMORY_LIMIT:   .equ $1C00
DOS_MEMORY_START:   .equ $1C04
DOS_PROCESS_HANDLE: .equ $1C28

;メモリ管理ポインタ
.offset	0
MM_PREV:   .ds.l 1
MM_PARENT: .ds.l 1
MM_TAIL:   .ds.l 1
MM_NEXT:   .ds.l 1
sizeof_MM:

HIGHMEM_ADDR_MIN: .equ $0100_0000
TS6BE16_START: .equ $0100_0000
TS6BE16_SIZE:  .equ 16*1024*1024


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  DOS_PRINT (strMainMem,pc)

  bsr Memory_GetHighArea
  movem.l d0-d1,(highArea)
  sub.l d0,d1
  moveq #3,d0
  cmpi.l #1000*1024*1024,d1
  bcs @f
    moveq #4,d0  ;ハイメモリが1000MB以上ならメインメモリも4桁表示
  @@:
  move.b d0,(memWidth)

  bsr Memory_GetMainArea
  move.l d1,d2
  sub.l d0,d2  ;メインメモリのバイト数
  subq.l #1,d1
  move.l d0,-(sp)
  bsr Memory_GetMainFreeSize
  move.l d0,d3
  move.l (sp)+,d0
  bsr print_mem

  DOS_PRINT (strHighMem,pc)

  movem.l (highArea,pc),d0-d1
  move.l d1,d2
  beq no_himem
  sub.l d0,d2  ;ハイメモリのバイト数
  subq.l #1,d1
  move.l d0,-(sp)
  bsr Memory_GetHighFreeSize
  move.l d0,d3
  move.l (sp)+,d0
  bsr print_mem
  bra 9f
no_himem:
  DOS_PRINT (strNoHighMem,pc)
9:
  DOS _EXIT


print_mem:
  lea (strBuf,pc),a0
  bsr Memory_AreaToString

  move.b #' ',(a0)+
  move.l d2,d0
  moveq #0,d1
  move.b (memWidth,pc),d1
  bsr Memory_SizeToString

  move.b #' ',(a0)+
  move.b #'(',(a0)+
  move.l d3,d0
  bsr Memory_FreeSizeToString
  lea (strFree,pc),a1
  STRCPY a1,a0

  DOS_PRINT (strBuf,pc)
  rts


is_060turbo:
  PUSH d1/a1
  suba.l a1,a1  ;エラー時の a1 != '060T' を保証
  move #$8000,d1
  IOCS _SYS_STAT
  cmpa.l #'060T',a1
  POP d1/a1
  rts


  DEFINE_DOSBUSERRWORD DosBusErrWord
  DEFINE_TODECSTRINGWIDTH ToDecStringWidth
  DEFINE_TOHEXSTRING8 ToHexString8


.data
strMainMem: .dc.b 'Main memory: ',0
strHighMem: .dc.b 'High memory: ',0
strNoHighMem: .dc.b 'ハイメモリは装着されていません。',CR,LF,0
strFree: .dc.b ' free)',CR,LF,0

.bss
.even
strBuf: .ds.b 256

.even
highArea: .ds.l 2
memWidth: .ds.b 1
.text


;メインメモリのアドレス範囲を得る。
;out d0.l ... 先頭アドレス
;    d1.l ... 末尾アドレス+1
Memory_GetMainArea::
  move.l a0,-(sp)
  suba.l a0,a0
@@:
  bsr DosBusErrWord
  bne @f
  adda.l #$10_0000,a0
  cmpa.l #$c0_0000,a0
  bcs @b
@@:
  move.l a0,d1
  moveq #0,d0
  movea.l (sp)+,a0
  rts


;メインメモリの空き容量を得る。
;  スーパーバイザモードで呼び出すこと。
;  自分自身のプロセスそのものであるメモリブロックについても、DOS _SETBLOCK で拡大可能な
;  最大サイズを空き容量として扱う。
;
;  DOS _SETBLOCK/_MALLOC を使用する方法ではハイメモリの影響を受けてしまうので、直接
;  Human68k のメモリ管理を参照して計算する。
;out d0.l ... バイト数
Memory_GetMainFreeSize::
  PUSH d1-d3/a0-a1
  moveq #HIGHMEM_ADDR_MIN>>24,d3
  ror.l #8,d3
  movea.l (DOS_MEMORY_LIMIT),a1

  ;自分自身のメモリブロックの最大サイズを計算する
  movea.l (DOS_PROCESS_HANDLE),a0
  movea.l (a0),a0  
  moveq #0,d0
  cmpa.l d3,a0
  bcc 1f   ;ハイメモリでの実行時は無視する
    move.l (MM_NEXT,a0),d0
    bne @f
      move.l a1,d0  ;末尾のメモリブロックだった
    @@:
    sub.l a0,d0  ;このブロックの最大サイズ
  1:
  movea.l (DOS_MEMORY_START),a0
  bra getmainfree_next

  getmainfree_loop:
    move.l (MM_NEXT,a0),d1
    bne @f
      move.l a1,d1
    @@:
    moveq #sizeof_MM+(16-1),d2
    add.l (MM_TAIL,a0),d2
    andi #.not.(16-1),d2  ;16バイト単位に切り上げ
    sub.l d2,d1  ;d1=次ブロック先頭-現ブロック先頭-メモリ管理ポインタサイズ
    bls @f
      cmp.l d1,d0
      bcc @f
        move.l d1,d0  ;最大空きブロック容量を更新
    @@:
    move.l (MM_NEXT,a0),d1
    beq getmainfree_end

    movea.l d1,a0
  getmainfree_next:
  cmpa.l d3,a0   ;ハイメモリに着いたらやめる
  bcs getmainfree_loop
getmainfree_end:
  POP d1-d3/a0-a1
  rts


;ハイメモリのアドレス範囲を得る。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 先頭アドレス(0なら未実装)
;    d1.l ... 末尾アドレス+1(0なら未実装)
Memory_GetHighArea::
  move.l a1,-(sp)
  movea.l (_HIMEM*4+IOCS_VECTBL),a1
  cmpi #'M'<<8,-(a1)
  bne gethigharea_err
  cmpi.l #'HIME',-(a1)
  bne gethigharea_err  ;HIMEM.SYS または互換ドライバが組み込まれていない

    cmpi.b #6,(MPUTYPE)
    bne @f
    bsr is_060turbo
    bne @f  ;060turbo.sys は組み込まれていない
      move #$4000,d1
      IOCS _SYS_STAT
      tst.l d0
      beq gethigharea_err

        add.l a1,d0   ;末尾アドレス+1
        move.l a1,d1  ;先頭アドレス
        exg d0,d1
        bra gethigharea_end
    @@:
    moveq #_HIMEM_GETAREA,d1
    IOCS _HIMEM
    tst.l d0
    bgt gethigharea_end  ;拡張されたコマンドで取得できた

      ;TS-6BE16 の仕様通りの値を返す
      moveq #TS6BE16_START>>24,d0
      ror.l #8,d0
      moveq #(TS6BE16_START+TS6BE16_SIZE)>>24,d1
      ror.l #8,d1
      bra gethigharea_end
gethigharea_err:
  moveq #0,d0
  moveq #0,d1
gethigharea_end:
  movea.l (sp)+,a1
  rts


;ハイメモリの空き容量を得る。
;  事前に Memory_GetHighArea でハイメモリの存在を確認しておくこと。
;out d0.l ... バイト数
Memory_GetHighFreeSize::
  move.l d1,-(sp)
  moveq #_HIMEM_GETSIZE,d1
  IOCS _HIMEM
  move.l d1,d0
  move.l (sp)+,d1
  rts


;アドレス範囲を文字列化する。
;in
;  d0.l ... 先頭アドレス
;  d1.l ... 末尾アドレス
;  a0.l ... 文字列バッファ(今のところ32バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
Memory_AreaToString::
  move.b #'$',(a0)+
  bsr ToHexString8

  move.b #'-',(a0)+

  move.b #'$',(a0)+
  move.l d1,d0
  bra ToHexString8
; rts


;メモリ容量を文字列化する。
;in
;  d0.l ... バイト数
;  d1.l ... 最小桁数
;  a0.l ... 文字列バッファ(今のところ16バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
Memory_SizeToString::
  clr d0
  swap d0
  lsr #4,d0  ;1024*1024で割ってメガバイト単位に変換
  bsr ToDecStringWidth

  move.b #'M',(a0)+
  move.b #'B',(a0)+
  clr.b (a0)
  rts


;空きメモリ容量を文字列化する。
;in
;  d0.l ... バイト数
;  a0.l ... 文字列バッファ(今のところ16バイトあれば足りる)
;out
;  a0.l ... 文字列末尾のアドレス(NUL を指す)
;break d0
Memory_FreeSizeToString::
  move.l d1,-(sp)
  lsr.l #8,d0
  lsr.l #2,d0  ;1024で割ってキロバイト単位に変換

  moveq #1,d1
  bsr ToDecStringWidth

  move.b #'K',(a0)+
  move.b #'B',(a0)+
  clr.b (a0)
  move.l (sp)+,d1
  rts


.end ProgramStart

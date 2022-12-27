# Xperiment68k
実験的なコードとかいろいろ。

無保証です。  
十分なテストを行っていないので、不具合があるかもしれません。


## Build
PCやネット上での取り扱いを用意にするために、src/内のファイルはUTF-8で記述されています。  
X68000上でビルドする際には、UTF-8からShift_JISへの変換が必要です。

### u8tosjを使用する方法

あらかじめ、[u8tosj](https://github.com/kg68k/u8tosj)をビルドしてインストールしておいてください。

トップディレクトリで`make`を実行してください。以下の処理が行われます。
1. build/ディレクトリの作成。
2. src/内の各ファイルをShift_JISに変換してbuild/へ保存。

次に、カレントディレクトリをbuild/に変更し、`make`を実行してください。  
実行ファイルが作成されます。

### u8tosjを使用しない方法

ファイルを適当なツールで適宜Shift_JISに変換してから`make`を実行してください。  
UTF-8のままでは正しくビルドできませんので注意してください。


## Description

### a2arg
プログラム起動時にa2レジスタで渡されるコマンドライン引数の内容を表示します。  
HUPAIRに準拠してエンコードされた引数の場合はHUPAIRマークとARG0も表示します。

このプログラムにはHUPAIRマークを埋め込んであるため、親プロセスがHUPAIR
準拠であればコマンドライン引数もHUPAIRに従ってエンコードされるはずです。


### chxdummy
※SRAMの内容を破壊するので、破壊しても構わないエミュレータ上でのみ試してください。

Xellent30用インストーラch30inst.x、chxinst.xは、SRAMに既に別のプログラムが組み込まれていても
空き領域を検索し共存してインストールすることができます。
その機能を試すためのツールです。

ch30*.sysがインストールできる最小限の領域だけ残して、何もしないダミープログラムを組み込みます。

使用法:
```
chxdummy ch30_omake.sys
chxinst ch30_omake.sys
```

### dbrams
IOCSワーク$cb8、$cbaの値を再計測します。  
MPU 68000、IOCS ROM version 1.1、1.2、1.3、1.6(XEiJ)専用です。


### dos_create_sp
コマンドライン引数で指定したファイルをDOS _CREATEの通常モードと特殊モード
(ファイル属性のビット15を1にする)で連続して開き、
戻り値(ファイルハンドルまたはエラーコード)を表示します。

特殊モードの動作により、同名のファイルが2個作成されます。


### dos_keyctrl01
`DOS _KEYCTRL`によるキー入力を行い、キーコードを表示します。  
OPT.1キーまたはOPT.2キーを押し下げると終了します
(終了しない場合はどちらかのキーを押し下げたまま文字キーを押してください)。

左端の16進数はループ回数です。
先読みして入力がない状態が連続した場合は表示を省略するので、ループ回数が飛びます。  

コマンドライン引数でキー入力の方法を指定できます(無指定時は`1`)。
- `0` ... `MD=0`(キー入力)を使用します。
- `1` ... `MD=1`(キー先読み)と`MD=0`(キー入力)を組み合わせて使用します。

Human68k version 3.02では`0`(`MD=0`)で入力がない場合に入力待ちをしませんが、
ASK68K 組み込み時は入力待ちをするなど、FEP組み込み状態によって挙動が一致しません。


### dos_nameck
コマンドライン引数で指定したファイルをDOS _NAMECKで展開し、
戻り値と展開結果を表示します。


### dos_open
コマンドライン引数で指定したファイルをDOS _OPENで開き、
戻り値(ファイルハンドルまたはエラーコード)を表示します。


### esc_dsr
エスケープシーケンス `ESC [6n` (DSR = Device Status Report)
を表示した際にキーバッファに入力されたデータを読み取って表示します。  
Human68Kの標準では `ESC [{pl};{pc}R` (CPR = Cursor Position Report)
が入力されますが、FEPによっては対応していません。


### keyflush
SHIFTキーが押し下げられるまで待機し、キー入力をフラッシュしてから終了します。  
コマンドライン引数でキーフラッシュの方法を指定できます(無指定時は`i`)。
- `i` ... `IOCS _KEYSNS`/`_KEYINP`を使用します。
- `c` ... `DOS _KEYCTRL`を使用します。
- `f` ... `DOS _KFLUSH`を使用します。

`c`は、FEPを組み込んでいると完全に消去できない場合があります。

`f`は「標準入力に対するフラッシュ」なので、`keyflush f < nul`
とすると(NUL デバイスに対してフラッシュを行うため)キーボード入力は消去されません。

### mallocall
プロセス自身のメモリブロックのアドレスとサイズを表示したあと、
可能な限りメモリブロックを確保してそのアドレスとサイズを表示します。  
コマンドライン引数で動作モードを指定できます。  
- `s` ... プロセスのメモリブロックを最小まで縮小します。
- `e` ... プロセスのメモリブロックを最大まで拡大します。
- `2` ... DOS _SETBLOCKの代わりにDOS _SETBLOCK2を使います(要060turbo.sys)。
- `3` ... DOS _MALLOCの代わりにDOS _MALLOC3を使います(要060turbo.sys)。


### midi_reg
MIDIボード(#1 = $00eafa00-$00eafa0f)のYM3802のレジスタの値を表示します(読み込みレジスタのみ)。  
YM3802はレジスタへのアクセス手順が分かりにくかったので、その確認用です。


### pt_dbhw
X68000の機種依存文字の文字表を表示します。  
コマンドライン引数で動作モードを指定できます(無指定時は`80`)。
- `80` ... 0x80?? 半角ひらがな
- `f0` ... 0xf0?? 上付き1/4角カタカナ
- `f1` ... 0xf1?? 上付き1/4角ひらがな
- `f2` ... 0xf2?? 下付き1/4角カタカナ
- `f3` ... 0xf3?? 下付き1/4角ひらがな
- `f4` ... 0xf4?? 半角外字
- `f5` ... 0xf5?? 半角外字


### putmes24
コマンドライン引数で指定した文字列を、テキスト画面に24ドットフォントで描画します。  


### si_acc
装着されているアクセラレータの種類を表示します。


### si_emu
実行中のエミュレータの種類を表示します。


### si_midi
MIDIボードの種類を表示します。


### si_memory
メインメモリとハイメモリの情報を表示します。  
ハイメモリについては、HIMEM.SYSまたは互換メモリドライバが必要です。


### si_model
本体の機種名を表示します。


### si_phantomx
PhantomXの情報を表示します。


### si_scsiex
SCSIボードの機種名を表示します。


### si_sram
SRAMの容量と使用状況を表示します。

ch30*_omake.sysが組み込まれている場合はそのバージョンを表示します。  
(対応しているバージョンは、バイナリエディタで開いてオフセット`$19`の値が`$41 'A'`のもの)


### sjis_tbl
Shift_JISの2バイト文字の文字表を表示します。  
コマンドライン引数として`f`を指定すると、X680x0独自拡張の2バイト半角文字
`0xf000-0xf5ff`の文字表を表示します(下位バイトとして有効な値の範囲は要検証)。


## License
GNU General Public License version 3 or later.


## Author
TcbnErik / 立花@桑島技研  
https://github.com/kg68k/xperiment68k

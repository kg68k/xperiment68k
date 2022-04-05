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

### dbrams.x
IOCSワーク$cb8、$cbaの値を再計測します。
MPU 68000、IOCS ROM version 1.1、1.2、1.3、1.6(XEiJ)専用です。


### mallocall
プロセス自身のメモリブロックのアドレスとサイズを表示したあと、
可能な限りメモリブロックを確保してそのアドレスとサイズを表示します。
コマンドライン引数で動作モードを指定できます。
- s ... プロセスのメモリブロックを最小まで縮小します。
- e ... プロセスのメモリブロックを最大まで拡大します。
- 2 ... DOS _SETBLOCKの代わりにDOS _SETBLOCK2を使います(要060turbo.sys)。
- 3 ... DOS _MALLOCの代わりにDOS _MALLOC3を使います(要060turbo.sys)。


### midi_reg
MIDIボード(#1 = $00eafa00-$00eafa0f)のYM3802のレジスタの値を表示します(読み込みレジスタのみ)。
YM3802はレジスタへのアクセス手順が分かりにくかったので、その確認用です。


### si_acc
装着されているアクセラレータの種類を表示します。


### si_emu
実行中のエミュレータの種類を表示します。


### si_midi
MIDIボードの種類を表示します。


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


## License
GNU General Public License version 3 or later.


## Author
TcbnErik / 立花@桑島技研
https://github.com/kg68k/xperiment68k

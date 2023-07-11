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

### 必要環境
* Human68k version 3.02
* GNU make 3.79 human68k-1.4 以降
* HAS060.X version 3.09+91 以降(必須)
* HLK evolution version 3.01+16 以降
* gcc2


## Description

### a2arg
プログラム起動時にa2レジスタで渡されるコマンドライン引数の内容を表示します。  
HUPAIRに準拠してエンコードされた引数の場合はHUPAIRマークとARG0も表示します。

このプログラムにはHUPAIRマークを埋め込んであるため、親プロセスがHUPAIR
準拠であればコマンドライン引数もHUPAIRに従ってエンコードされるはずです。


### adpcmotchk
`IOCS _ADPCMAOT`、`IOCS _ADPCMLOT`を実行してDMACの一部のレジスタの値を表示します。  
DMACのレジスタの値を確認するためのものですが、手抜きでDMAを動作させるのに
IOCSコールを使っているのでADPCMドライバなどは組み込んでいない状態で実行してください。


### bitsns
`IOCS _BITSNS`を実行してキーの押し下げ状態を表示します。  
マウスのボタンを押すと終了します。

IOCSワークに保存されているキー状態をIOCSコール経由で取得しているだけなので、
実際にキーボードから送られたスキャンコードがそのまま表示されるわけではありません。  
キーボードから送信されるスキャンコードをそのまま得たい場合は、[keyscan](#keyscan)を使用してください。


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

### colorbar
カラーバーのような画像を描画します。  
(カラーバーではないのでカラーバーとして使うことはできません。)


### con_scroll
コンソール画面のスクロールをテストします。  
なにかキーを押すと次のモードに進みます。


### dbrams
IOCSワーク$cb8、$cbaの値を再計測します。  
MPU 68000、IOCS ROM version 1.1、1.2、1.3、1.6(XEiJ)専用です。


### dos_create_sp
コマンドライン引数で指定したファイルをDOS _CREATEの通常モードと特殊モード
(ファイル属性のビット15を1にする)で連続して開き、
戻り値(ファイルハンドルまたはエラーコード)を表示します。

特殊モードの動作により、同名のファイルが2個作成されます。


### dos_fatchk
コマンドライン引数で指定したファイルをDOS _FATCHKで調べ、結果を表示します。


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


### entryceil
上位メモリから起動して「OK.」と表示するだけのプログラムで、
HUPAIR準拠表示の判別を行うコードの動作テスト用です。

Human68kの非公開機能を使って上位メモリにロードさせます。  
そのためのフラグをHLK evolutionの`-g2`オプションで設定するので、
リンカとしてHLK evolutionを使う必要があります。

RAMDISKなど上位メモリを使用するドライバは組み込まずに起動し、
HUPAIRに対応したシェルなどからentryceilを実行します
(スーパーバイザモードで動作するシェルの場合はメインメモリ実装量を11MB以下にしておきます)。  
子プロセスのメモリブロック範囲外を参照する判別コードの場合、
未実装メモリを参照してバスエラーが発生します。


### esc_dsr
エスケープシーケンス `ESC [6n` (DSR = Device Status Report)
を表示した際にキーバッファに入力されたデータを読み取って表示します。  
Human68Kの標準では `ESC [{pl};{pc}R` (CPR = Cursor Position Report)
が入力されますが、FEPによっては対応していません。


### execas
「ファイルを別名で実行するR形式実行ファイル」を作成します
(作成にはシェルのリダイレクト機能を用います)。
```
execas 実行ファイル名 > 新ファイル名.r
```
実行ファイルは(通常であればカレントディレクトリと)環境変数`path`からの検索が行われ、
絶対パス名に正規化されて新ファイルに埋め込まれます。

指定する実行ファイルはHUPAIRに対応している必要があります。

作成されたファイルを実行すると、作成時に指定された実行ファイルをロードし、
そのプロセスのPSP内に新ファイルのパス名とファイル名を上書きしてから実行します。

たとえば`execas C:\dir\gzip.x > D:\folder\gunzip.r`として作成されたgunzip.rを実行すると、
gunzip.rから実行された`C:\dir\gzip.x`からは自分自身が`D:\folder\gunzip.r`
というファイル名であるかのように見えます。


### fatchk_bof
`DOS _FATCHK`でバッファの範囲外に書き込んでしまう不具合(Human68k v3.02)を検証します。


### fntget
コマンドライン引数で指定した文字のフォントを拡大してテキストとして表示します。  
文字の代わりに、2桁または4桁の16進数による文字コードで指定することもできます。

コマンドライン引数でフォントの大きさを指定できます(無指定時は`-8`)。
- `-6` .... 半角6×12、全角12×12。
- `-8` .... 半角8×16、全角16×16。
- `-12` ... 半角12×24、全角24×24。


### fntsize
コマンドライン引数で指定した文字(省略時は半角スペース)について、
`IOCS _FNTADR`、`IOCS _FNTGET`の結果を一覧表示します。  
フォントサイズは未定義の値も含め各サイズを指定します。

`_FNTADR`でd2.b = 0～5、`_FNTGET`でd1.hw = 1～5のサイズを指定した場合、
IOCS環境(ROMまたはIOCS.Xのバージョン)によって結果が異なります。


### iocs_txfill
`IOCS _TXFILL`のサンプルです。


### iocs_txyline
`IOCS _TXYLINE`のサンプルです。


### iocs_txrascpy
`IOCS _TXRASCPY`によるラスタコピーを行います。  
使用法: iocs_txrascpy コピー元 コピー先 ラスタ数 移動方向(0:下,-1:上) テキストプレーン  
移動方向、テキストプレーンは省略できます(省略時は0:下、%0011となります)。

X68000をクロックアップ改造しているとラスタコピーに失敗して画面が乱れることがあります。  
IOCS.XやHIOCS.Xを組み込んでいるとコンソールのスクロールに内部のルーチンを使うほか、
アプリケーションによっては独自のラスタコピールーチンを持っているため、
`IOCS _TXRASCPY`が呼び出される機会がなく後から問題に気づくこともしばしばあるようです。

画面が乱れる場合は、`IOCS _TXRASCPY`を高クロック対応ルーチンに差し替えるドライバを組み込んでください
(HIOCS PLUS version 1.10+16.17以降など)。


### joyget
`IOCS _JOYGET`によるジョイスティック入力を行い、入力状態を表示します。  
キーを押すと終了します。


### kbdctrl
キーボード制御コマンドコードをキーボードに送信します。
コードはコマンドライン引数で16進数2桁で指定します(省略時は`$47` = Compactキーボード判別)。


### keepceil
上位メモリに常駐するだけのプログラムで、常駐プロセスの常駐検査を行うコードの動作テスト用です。

Human68kの非公開機能を使って上位メモリにロードさせます。  
そのためのフラグをHLK evolutionの`-g2`オプションで設定するので、
リンカとしてHLK evolutionを使う必要があります。

メインメモリ実装量を11MB以下にし、RAMDISKなど上位メモリを使用するドライバは組み込まずに起動し、
keepceilを常駐してから常駐検査コードを実行します。  
常駐プロセスのメモリブロック範囲外を参照する検査コードの場合、未実装メモリを参照してバスエラーが発生します
(ただしkeepceilの本体が16バイトあるので、その範囲内しか見ない検査コードであれば問題を検出できません)。


### keyflush
SHIFTキーが押し下げられるまで待機し、キー入力をフラッシュしてから終了します。  
コマンドライン引数でキーフラッシュの方法を指定できます(無指定時は`i`)。
- `i` ... `IOCS _KEYSNS`/`_KEYINP`を使用します。
- `c` ... `DOS _KEYCTRL`を使用します。
- `f` ... `DOS _KFLUSH`を使用します。

`c`は、FEPを組み込んでいると完全に消去できない場合があります。

`f`は「標準入力に対するフラッシュ」なので、`keyflush f < nul`
とすると(NUL デバイスに対してフラッシュを行うため)キーボード入力は消去されません。


### keyscan
キーボードから受信したスキャンコードを表示します。  
マウスの左ボタンを押すと終了します。  
マウスの右ボタンを押すとキーボード判別コマンド(`$47`)を送信します(動作未確認)。

MFP USART受信バッファフル割り込みを差し替えているので、動作中にIOCSレベルのキー入力は行われません。  
実行後はX680x0本体のリセットボタンによる再起動を推奨します。


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


### pt_7e
文字コード`0x7e`の文字(オーバーラインまたはチルダ)を、X68000の機種依存文字も含め表示します。  
aとzはフォントの配置を分かりやすくするための対照群です(どの行も通常の半角文字です)。



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


### putmes12
コマンドライン引数で指定した文字列を、テキスト画面に12ドットフォントで描画します。  


### putmes24
コマンドライン引数で指定した文字列を、テキスト画面に24ドットフォントで描画します。  


### reset68k
`trap #10`命令によるソフトウェアリセットを行います。

X680x0のネタとして`NJ`の2文字をR形式実行ファイルにするとソフトウェアリセットができるという話がありますが、
プロセス起動直後のd0レジスタの内容は不定なので厳密に言うと確実ではありません
(`pxNJ`などであれば問題ありません)。
このプログラムではd0レジスタに`'X68k'`を入れて`trap #10`を実行します。

COMMAND.Xで下記のコマンドを実行すると同一内容の実行ファイルを作成できます。
```
echo \L\L $NJX68k>reset68k.r
```


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


### skeyset
指定したスキャンコードを引数として`IOCS _SKEYSET`を呼び出し、
その直後に`IOCS _B_KEYINP`で取得したキーデータを表示します。


### sp3tx0gr2
画面間プライオリティを特殊な設定にして各画面に図形を描画します。  
手前からテキスト画面(横長の長方形)、スプライト(16x16の正方形)、
グラフィック画面(縦長の長方形)が表示されるはずです。  
何かコマンドライン引数を指定するとビデオコントローラに半透明の設定を書き込みますが、
表示結果は同じになるはずです。


### splimchk
スプライトを画面中央に左右に並べて表示します。  
1ラインあたりの表示限界の確認用です(実機は1ラインあたり最大32個)。  
コマンドライン引数で動作モードを指定できます(無指定時は`1`)。
- `1` ... 画面右端から左端にスプライトを128個表示します。
- `2` ... 画面右端から左端にスプライトを64個、その下の段に左端から右端に64個表示します。


### sq64k
画面モードが0番(通常の768×512の画面、IOCS _CRTMODの16番)でない場合はそれに変更し、
グラフィック画面を65536色モードに設定します。  


### sysport
システムポート領域($00e8e000-$00e8e00f、ポート未割り当てのアドレスも含む)
を読み込んで値を表示します。


### zerounit
ディスクを破壊する可能性があるため、試す場合は独立したエミュレータ環境でのみ使用して下さい。

ブロックデバイスが初期化時にユニット数=0を返してはいけないことを検証します。  
これは本来あってはならない動作であり、Human68kがDPBを65536個作成してしまいます。

リモートドライブのデバイスドライバとして作られており、CONFIG.SYSの`DEVICE =`
行で組み込むことができますが、初期化するとユニット数=0を返す以外の機能はありません。


## License
GNU General Public License version 3 or later.


## Author
TcbnErik / 立花@桑島技研  
https://github.com/kg68k/xperiment68k

# Xperiment68k
実験的なコードとかいろいろ。

無保証です。  
十分なテストを行っていないので、不具合があるかもしれません。

長いファイル名を使用しているため、TwentyOne +Tなどのファイル名を21文字認識する環境が必要です。


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
* [GNU make](https://github.com/kg68k/gnu-make-human68k) 3.79 human68k-1.4 以降
* [HAS060.X](http://retropc.net/x68000/software/develop/as/has060/) version 3.09+91 以降
  * 作者は[HAS060X.X](https://github.com/kg68k/has060xx)をhas060.xにリネームして使っています。
* [HLKX](https://github.com/kg68k/hlkx) 1.0.0 以降
  * 環境変数`LD=hlkx`を設定するか、make 実行時のコマンドラインオプションで指定してください。
  * 指定しない場合はHLKが使用されますが、一部のファイルがビルドされません。
* gcc2


## Description

### a2arg
プログラム起動時にa2レジスタで渡されるコマンドライン引数の内容を表示します。  
HUPAIRに準拠してエンコードされた引数の場合はHUPAIRマークとARG0も表示します。

このプログラムにはHUPAIRマークを埋め込んであるため、親プロセスがHUPAIR
準拠であればコマンドライン引数もHUPAIRに従ってエンコードされるはずです。


### a2arg_nh
プログラム起動時にa2レジスタで渡されるコマンドライン引数の内容を表示します。  
HUPAIRに準拠してエンコードされた引数の場合はHUPAIRマークとARG0も表示します。

このプログラムにはHUPAIRマークは埋め込まれていません。


### adpcmotchk
`IOCS _ADPCMAOT`、`IOCS _ADPCMLOT`を実行してDMACの一部のレジスタの値を表示します。  
DMACのレジスタの値を確認するためのものですが、手抜きでDMAを動作させるのに
IOCSコールを使っているのでADPCMドライバなどは組み込んでいない状態で実行してください。


### beep_adpcmout
システムに登録されているビープ音を、`IOCS _ADPCMOUT`で再生します。


### beep_mpcm
システムに登録されているビープ音を、MPCM.Xで効果音として再生します(`$10xx M_EFCT_OUT`)。

> [!WARNING]
> リターンキーによる全チャンネル再生は大きな音が出るので注意してください。


### beep_zmsc3
システムに登録されているビープ音を、ZMSC3.Xで効果音として再生します(`$13 ZM_SE_ADPCM1`)。

> [!WARNING]
> リターンキーによる全チャンネル再生は大きな音が出るので注意してください。


### bitsns
`IOCS _BITSNS`を実行してキーの押し下げ状態を表示します。  
マウスのボタンを押すと終了します。

IOCSワークに保存されているキー状態をIOCSコール経由で取得しているだけなので、
実際にキーボードから送られたスキャンコードがそのまま表示されるわけではありません。  
キーボードから送信されるスキャンコードをそのまま得たい場合は、[keyscan](#keyscan)を使用してください。


### buserr_2w
ユーザーモードにおいて、メインメモリ末尾-2のアドレスからロングワードサイズで読み込みを行い
バスエラーを発生させます。  
M68000は16ビットバスなので、メインメモリの容量が`$00Y0_0000`のとき以下のような挙動になります。
1. メインメモリ末尾-2(`$00Xf_fffe`)から1ワード読み込む → 成功
2. メモリ未実装アドレスまたはGVRAM(`$00Y0_0000`)から1ワード読み込む → バスエラー発生

ただし拡張エリアセットやMMUによりメインメモリの末尾付近がスーパーバイザ保護されている場合は、
1.の時点でバスエラーが発生します。


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


### datetime
現在の日時をIOCSで取得し、BCD形式と文字列形式で表示します。  
文字列形式については`IOCS _DATEASC`にある4種類がそれぞれ表示されます。


### dbrams
IOCSワーク$cb8、$cbaの値を再計測します。  
MPU 68000、IOCS ROM version 1.1、1.2、1.3、1.6(XEiJ)専用です。


### defchr_7621
文字コード`$7621`(Shift_JIS:`$eb9f`)の16ドットフォントを`IOCS _FNTGET`で取得し、
先頭32ドットを`$deadbeef`に書き換えて`IOCS _DEFCHR`で同じ文字に設定します。

通常は外字のフォントが書き換えられるだけですが、外字領域が確保されていない状態で実行するとアドレス
`$0`の内容が書き換えられてしまいます。


### dos_create
コマンドライン引数で指定したファイルを`DOS _CREATE`で作成し、
戻り値(ファイルハンドルまたはエラーコード)を表示します。


### dos_create_sp
コマンドライン引数で指定したファイルを`DOS _CREATE`の通常モードと特殊モード
(ファイル属性のビット15を1にする)で連続して作成し、
戻り値(ファイルハンドルまたはエラーコード)を表示します。

特殊モードの動作により、同名のファイルが2個作成されます。


### dos_curdir
コマンドライン引数で指定したドライブ(省略時はカレントドライブ)のカレントディレクトリを
`DOS _CURDIR`で調べ、結果を表示します。  
ドライブ名(ドライブレター + コロン)、ルートディレクトリのパスデリミタは含まれないため、
ルートディレクトリの場合は空文字列が表示されます。


### dos_fatchk
コマンドライン引数で指定したファイルを`DOS _FATCHK`で調べ、結果を表示します。


### dos_fgetc
コマンドライン引数で指定したファイル(省略時は標準入力)を`DOS _FGETC`で
1バイトずつ読み込み、標準出力へ出力します。


### dos_fgets
コマンドライン引数で指定したファイル(省略時は標準入力)を`DOS _FGETS`で
一行ずつ読み込み、標準出力へ出力します。


### dos_filedate
コマンドライン引数で指定したファイルのタイムスタンプを`DOS _FILEDATE`で調べ、結果を表示します。  
また、オプション指定時はファイルにタイムスタンプを設定します。

- `-d<decimal>` ... 10進数で指定したタイムスタンプを設定します。
- `-x<hex>` ... 16進数で指定したタイムスタンプを設定します。


### dos_getenv
コマンドライン引数で指定した環境変数を`DOS _GETENV`で取得し、結果を表示します。


### dos_inpout
`DOS _INPOUT`による文字入力を行い文字コードを表示するか、または文字出力を行います。  
入力中はCTRL+Cキーで終了しますが、標準入力をリダイレクトしていると終了できない場合があります。

コマンドライン引数で動作を指定します。
- -ff ... `CODE=$ff`(キー入力)を行います。
- -fe ... `CODE=$fe`(キー先読み)を行います。
- その他 ... 文字列を1バイトずつ出力します。


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


### dos_maketmp
コマンドライン引数で指定したファイルを`DOS _MAKETMP`で作成し、
戻り値(ファイルハンドルまたはエラーコード)と生成されたファイル名を表示します。


### dos_nameck
コマンドライン引数で指定したファイル名(パス名)を`DOS _NAMECK`で展開し、
戻り値と展開結果を表示します。


### dos_namests
コマンドライン引数で指定したファイル名(パス名)を`DOS _NAMESTS`で展開し、
戻り値と展開結果を表示します。


### dos_newfile
コマンドライン引数で指定したファイルを`DOS _NEWFILE`で作成し、
戻り値(ファイルハンドルまたはエラーコード)を表示します。


### dos_open
コマンドライン引数で指定したファイルを`DOS _OPEN`で開き、
戻り値(ファイルハンドルまたはエラーコード)を表示します。


### dumpenv
環境変数を全て表示します。  
なにかコマンドライン引数を指定すると終了時にキー入力を待ち、
終了コード1を返します(CONFIG.SYSの`EXCONFIG =`行から実行する場合用)。


### dumpstdin
`DOS _READ`で標準入力からデータを読み込み(最大256バイト)、
戻り値(入力サイズまたはエラーコード)を表示します。
また、読み込んだデータを16進数で表示します。


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


### env_sbo
`DOS _GETENV`で環境変数名が長すぎる場合に、スタック上に確保されたバッファの範囲外に
書き込んでしまう挙動(Human68k v3.02)を検証します。  
なにかコマンドライン引数を指定すると、`DOS _SETENV`で環境変数名と設定する文字列が
長すぎる場合の同様の挙動を検証します。

DOSコール内部のサブルーチンにある`rts`命令で読み込まれるリターンアドレスの部分を、
用意した乗っ取りルーチンのアドレスで上書きさせることで、リターンする代わりに
そのルーチンを呼び出すように細工しています。

> [!WARNING]
> プログラムが終了しないためリセットする必要があります。  
> コピーバックのディスクキャッシュなどはあらかじめ解除してください。  
> 実験用に用意したシステムでのみ実行してください。  
> ※普段使っているシステムでは実行しないこと！

プログラムを起動すると確認プロンプトが表示されるので、
`yes`と入力してリターンキーで確定すると実行されます。


### esc_dsr
エスケープシーケンス `ESC [6n` (DSR = Device Status Report)
を表示した際にキーバッファに入力されたデータを読み取って表示します。  
Human68Kの標準では `ESC [{pl};{pc}R` (CPR = Cursor Position Report)
が入力されますが、FEPによっては対応していません。


### exchr_hex
拡張外字処理を有効にして常駐終了します。常駐解除はできません。  
フォントは文字コード(内部形式)を16進数で表記したものを動的に生成します。  
16ドットフォントのみ対応しています(12ドットフォント、24ドットはすべて〿になります)。

あらかじめ、IOCS.XまたはHIOCS PLUS version 1.10+16.20以降を組み込んでおく必要があります。
* ROM IOCSは拡張外字処理に対応していないので使用できません。
* HIOCS.X、HIOCS PLUSの上記バージョン未満は`IOCS _FNTADR`に不具合があり暴走します。
* HIOCS PLUSのスイッチは`-u0`を指定してください(既定値なので変更していなければそのままで構いません)。


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


### fe_fcvt_test
`FPACK __FCVT`の動作テストです。


### fe_stoh_test
`FPACK __STOH`の動作テストです。


### files
コマンドライン引数で指定したファイル名を`DOS _FILES`と`DOS _NFILES`で検索し、
見つかったファイル名を全て表示します。

ファイル名は`DOS _FILES`にそのまま渡されるもので、パス名やワイルドカードも指定できます。


### fntget
コマンドライン引数で指定した文字のフォントを拡大してテキストとして表示します。  
文字の代わりに、2桁または4桁の16進数による文字コードで指定することもできます。

コマンドライン引数でフォントの大きさを指定できます(無指定時は`-8`)。
- `-6` ... 半角6×12、全角12×12。
- `-8` ... 半角8×16、全角16×16。
- `-12` ... 半角12×24、全角24×24。


### fntsize
コマンドライン引数で指定した文字(省略時は半角スペース)について、
`IOCS _FNTADR`、`IOCS _FNTGET`の結果を一覧表示します。  
フォントサイズは未定義の値も含め各サイズを指定します。

`_FNTADR`でd2.b = 0～5、`_FNTGET`でd1.hw = 1～5のサイズを指定した場合、
IOCS環境(ROMまたはIOCS.Xのバージョン)によって結果が異なります。


### getassign
コマンドライン引数で指定したパス名について、仮想ドライブ・仮想ディレクトリの
割り当て状態を`DOS _ASSIGN (MD=0)`で調べ、結果を表示します。


### incdir_test
STUDIO KAMADAさんで解説されているHuman68kの
「[サブディレクトリ内のファイルが増えたときファイルなどが壊れることがある](https://stdkmd.net/bugsx68k/#human_subdir)」
不具合について、再現手順の(2)～(6)を実行します。  
あらかじめ再現手順(0)～(1)を実行後、カレントドライブをMOに変更にしてからこのプログラムを実行します。

なお手元の環境(Human68k v3.02、TwentyOne.x v1.36c)にて、このプログラムでは
「サブディレクトリ内の '.' と '..' のエントリが二重に記録される」
症状は再現できませんでした。

> [!WARNING]
> 実験用に用意したシステムでのみ実行してください。  
> ※普段使っているシステムでは実行しないこと！


### iocs_ontime
`IOCS _ONTIME`で取得した起動後の経過時間(1/100秒単位)を表示します。  
なにかコマンドライン引数を指定すると経過日数を表示します。


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
- `2` ... `DOS _SETBLOCK`の代わりに`DOS _SETBLOCK2`を使います(要060turbo.sys)。
- `3` ... `DOS _MALLOC`の代わりに`DOS _MALLOC3`を使います(要060turbo.sys)。


### malloc_ba_exec
`DOS _MALLOC`でメモリブロックを確保し結果(アドレス)を表示し解放、
コマンドライン引数で指定したコマンドを`DOS _EXEC`で実行し結果を表示、
再度メモリブロックを確保し結果を表示し解放、という操作を行います。


### midi_reg
MIDIボード(#1 = $00eafa00-$00eafa0f)のYM3802のレジスタの値を表示します(読み込みレジスタのみ)。  
YM3802はレジスタへのアクセス手順が分かりにくかったので、その確認用です。


### mpcm_echcnt
MPCM.Xの効果音発声数を設定します。  
コマンドライン引数で0から8までの数を指定します。


### nameck_bof
`DOS _NAMECK`でバッファの範囲外に書き込んでしまう不具合(Human68k v3.02)を検証します。

コマンドライン引数で指定したファイル名(パス名)を`DOS _NAMECK`で展開し、結果を表示します。
省略した場合は指定できる最大の長さ(89バイト)のダミーパス名を使用します。

バッファの直後のメモリが破壊された場合は16進数ダンプを表示します
(バイト値が`0xff`の場合は`__`となります)。


### namests_bof
`DOS _NAMESTS`でバッファの範囲外に書き込んでしまう不具合(Human68k v3.02)を検証します。

コマンドライン引数で指定したファイル名(パス名)を`DOS _NAMESTS`で展開し、結果を表示します。
省略した場合は指定できる最大の長さ(89バイト)のダミーパス名を使用します。

バッファの直後のメモリが破壊された場合は16進数ダンプを表示します
(バイト値が`0xff`の場合は`__`となります)。


### ns_sbo
ファイル入出力のDOSコールの一部に、システムスタック上にバッファを確保して
`DOS _NAMESTS`の内部ルーチンを呼び出すものがありますが、
そのルーチンがバッファの範囲外に書き込んでしまう不具合(Human68k v3.02)を検証します。  
スタック破壊の結果、アドレスエラーなどが発生します。

コマンドライン引数で検証するDOSコールの種類を指定します。  
引数を省略して実行すると使用できるDOSコールを表示します。

> [!WARNING]
> プログラムを正常に終了できないためリセットする必要があります。  
> コピーバックのディスクキャッシュなどはあらかじめ解除してください。  
> 実験用に用意したシステムでのみ実行してください。  
> ※普段使っているシステムでは実行しないこと！

プログラムを起動すると確認プロンプトが表示されるので、
`yes`と入力してリターンキーで確定すると実行されます。


### openedfiles
オープン中のファイルの一覧(ファイルハンドルとファイル名)を表示します。


### openkeep
コマンドライン引数で指定したファイルを読み込み専用でオープンし、常駐終了(`DOS _KEEPPR`)します。  
XCのプログラマーズマニュアルには「オープンしているファイルハンドルはクローズします」
と記載されていますが、実際にはクローズされません。

ファイルをクローズする方法は用意していないので、実行後は再起動してください。


### pathchk
コマンドライン引数で指定したファイルを`DOS _EXEC (MD=2;pathchk)`で調べ、結果を表示します。


### pathlenfix
Human68kにおけるパス名のディレクトリ名部分の長さは、
`DOS _NAMESTS`のバッファ構造などを見ると最大64バイトに見えますが、
実際の動作ではそれより小さい値となっています。

実行するとメモリ上のHuman68kにパッチをあて、最大64バイトに拡張します。  
Human68k version 3.02専用です。

> [!WARNING]
> 実験用に用意したシステムでのみ実行してください。  
> ※普段使っているシステムでは実行しないこと！


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


### rewind
コマンドライン引数で指定したファイルを`DOS _OPEN`で開き、ファイル末尾-1の位置に
`DOS _SEEK (mode=2, offset=-1)`で移動し、戻り値(移動先位置またはエラーコード)を表示します。

ファイルサイズが0バイトのファイルは移動できないのでエラー`$ffff_ffe7`になります。

CD-ROMなどのドライバ(リモートドライブ)によっては、`mode=2`の場合の`offset`
の扱いが逆方向になっているため移動できずエラーになることがあります。


### run68_dos_test
run68の`-f`オプションの動作確認用に作成した、
ほとんどのDOSコールを呼び出すだけの特に機能を持たないツールです。

途中でコンソールからの入力待ちがあるのでリターンキーを何度か押してください。

> [!WARNING]
> 実行しても害はないと思いますが、確実ではない(保証できない)ので、
> 普段使っているシステムでは実行しないこと！


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
なにかコマンドライン引数を指定するとビデオコントローラに半透明の設定を書き込みますが、
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


### sram_memsize
SRAMに保存されているメインメモリ容量($00ed0008)を1MB少ない値(メインメモリ1MBの場合は2MB)に書き換え、
書き換え前後の値を表示します。

エミュレータによってはメインメモリ容量を設定に合わせて動的に補正するものがあり、
その場合はSRAMの値が書き換わりません。  
(そのような環境ではSRAM用のメモリチェッカーでデータ異常が検出されるでしょう。)


### sysport
システムポート領域($00e8e000-$00e8e00f、ポート未割り当てのアドレスも含む)
を読み込んで値を表示します。


### tokikoe
テキスト画面にメッセージを表示します。  
なにかコマンドライン引数を指定すると描画が改善されます。


### uskfontadr
外字フォントデータのアドレスを表示します。

FORMAT.Xでフォーマットした空のフロッピーディスクに実行ファイルをコピーし、
ファイル名をHUMAN.SYSに変更すると、Human68kの代わりに起動することができます。


### vdispst_time
`IOCS _VDISPST`で設定した割り込みが発生するまでの時間を計測して表示します(100分の1秒単位)。  
コマンドライン引数で動作モードを指定できます。
- `0`～`255` ... カウンター値の指定(無指定時は`1`)。
- `a` ... IOCSコールの不具合を回避します。


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

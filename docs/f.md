# F

## fatchk_bof
`DOS _FATCHK`でバッファの範囲外に書き込んでしまう不具合(Human68k v3.02)を検証します。


## fe_fcvt_test
`FPACK __FCVT`の動作テストです。


## fe_power_test
`FPACK __POWER`の動作テストです。  
FLOAT4.X version 1.02ではバスエラーが発生します。


## fe_stoh_test
`FPACK __STOH`の動作テストです。


## fileopen
各種の方法でファイルを作成またはオープンし、戻り値(ファイルハンドルまたはエラーコード)を表示します。

一つ目のコマンドライン引数で作成またはオープンの方法を指定します。
複数の文字を連続して記述することができ、その場合は直前に開いたファイルをクローズせずに
そのまま次の文字の処理を行います。
* `c` ... `DOS _CREATE`
* `f` ... `DOS _CREATE` (高速モード; 常に新しいファイルを作成する)
* `n` ... `DOS _NEWFILE`
* `r` ... `DOS _OPEN` (読み込みモード)
* `w` ... `DOS _OPEN` (書き込みモード)
* `a` ... `DOS _OPEN` (読み書きモード)

二つ目のコマンドライン引数でファイル名を指定します。

使用例: `fileopen cnw foo`

辞書アクセスモード、シェアリングモードの指定には対応していません。


## files
コマンドライン引数で指定したファイル名を`DOS _FILES`と`DOS _NFILES`で検索し、
見つかったファイル名をすべて表示します。

ファイル名は`DOS _FILES`にそのまま渡されるもので、パス名やワイルドカードも指定できます。


## fntget
コマンドライン引数で指定した文字のフォントを拡大してテキストとして表示します。  
文字の代わりに、2桁または4桁の16進数による文字コードで指定することもできます。

コマンドライン引数でフォントの大きさを指定できます(無指定時は`-8`)。
* `-6` ... 半角6×12、全角12×12。
* `-8` ... 半角8×16、全角16×16。
* `-12` ... 半角12×24、全角24×24。


## fntsize
コマンドライン引数で指定した文字(省略時は半角スペース)について、
`IOCS _FNTADR`、`IOCS _FNTGET`の結果を一覧表示します。  
フォントサイズは未定義の値も含め各サイズを指定します。

`_FNTADR`でd2.b = 0～5、`_FNTGET`でd1.hw = 1～5のサイズを指定した場合、
IOCS環境(ROMまたはIOCS.Xのバージョン)によって結果が異なります。
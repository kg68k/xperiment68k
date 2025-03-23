# Xperiment68k
実験的なコードとかいろいろ。

無保証です。  
十分なテストを行っていないので、不具合があるかもしれません。

長いファイル名を使用しているため、TwentyOne +Tなどのファイル名を21文字認識する環境が必要です。


## Description

* [A](docs/a.md)
  * [a2arg](docs/a.mad#a2arg) ... 渡されたコマンドライン引数の内容を表示
  * [a2arg_nh](docs/a.md#a2arg_nh) ... 渡されたコマンドライン引数の内容を表示(HUPAIRマークなし)
  * [adpcmotchk](docs/a.md#adpcmotchk) ... IOCSによるADPCM再生後にDMACのレジスタ値を表示
  * [appendbytes](docs/a.md#appendbytes) ... ファイル末尾にデータを追記
* [B](docs/b.md)
  * [beep_adpcmout](docs/b.md#beep_adpcmout) ... システムビープ音を`IOCS _ADPCMOUT`で再生
  * [beep_mpcm](docs/b.md#beep_mpcm) ... システムビープ音をMPCMで効果音として再生
  * [beep_zmsc3](docs/b.md#beep_zmsc3) ... システムビープ音をZMSC3.Xで効果音として再生
  * [bg1pr2th](docs/b.md#bg1pr2th) ... 2個のスレッドを作成して常駐終了
  * [bgexec](docs/b.md#bgexec) ... 指定コマンドの実行指示をbgexecdスレッドに送信
  * [bgexecd](docs/b.md#bgexecd) ... 常駐終了し、指定されたコマンドをバックグラウンドで実行
  * [bgkill](docs/b.md#bgkill) ... スレッドに終了要求コマンドを送信
  * [bglivingdead](docs/b.md#bglivingdead) ... `DOS _KILL_PR`の動作検証
  * [bgsprocd](docs/b.md#bgsprocd) ... bgexecdとほぼ同じだがサブのメモリ管理を設定する
  * [bgsprocess](docs/b.md#bgsprocess) ... スレッドに対しサブのメモリ管理を設定
  * [bgthreadid](docs/b.md#bgthreadid) ... スレッドIDを表示
  * [bgwakeup](docs/b.md#bgwakeup) ... スレッドに強制スリープ解除コマンドを送信
  * [bgzombie](docs/b.md#bgzombie) ... `DOS _KILL_PR`の動作検証
  * [bindno](docs/b.md#bindno) ... `DOS _EXEC (MD=5;bindno)`でモジュール番号を取得
  * [bitsns](docs/b.md#bitsns) ... `IOCS _BITSNS`でキーの押し下げ状態を表示
  * [bkeyinpd3](docs/b.md#bkeyinpd3) ... `IOCS _B_EKYINP`の動作検証(`d3`レジスタ破壊)
  * [bputmes_cur](docs/b.md#bputmes_cur) ... `IOCS _B_PUTMES`のカーソル描画残留の動作検証
  * [buserr_2w](docs/b.md#buserr_2w) ... バスエラーを発生させる。エミュレータの検証用
* [C](docs/c.md)
  * [chxdummy](docs/c.md#chxdummy) ... ch30inst.x、chxinst.xの共存インストール機能の動作検証
  * [closerewindatr](docs/c.md#closerewindatr) ... `DOS _CLOSE`時のファイル属性巻き戻りの動作検証
  * [colorbar](docs/c.md#colorbar) ... カラーバーのような画像を描画
  * [conctrl_so](docs/c.md#conctrl_so) ... `DOS _CONCTRL`のスタックオーバーランの動作検証
  * [con_scroll](docs/c.md#con_scroll) ... コンソール画面のスクロールのテスト
  * [crampedexec](docs/c.md#crampedexec) ... 空きメモリ容量を指定してファイルを実行する
* [D](docs/d.md)
  * [datetime](docs/d.md#datetime) ... IOCSで日時を取得、表示
  * [dbrams](docs/d.md#dbrams) ... IOCSワーク`$cb8`、`$cba`の値を再計測
  * [defchr_7621](docs/d.md#defchr_7621) ... `IOCS _DEFCHR`の動作検証
  * [dos_conctrl](docs/d.md#dos_conctrl) ... `DOS _CONCTRL`でコンソール制御・直接出力
  * [dos_create_sp](docs/d.md#dos_create_sp) ... `DOS _CREATE`の特殊モードでファイルを作成
  * [dos_curdir](docs/d.md#dos_curdir) ... `DOS _CURDIR`でカレントディレクトリを取得
  * [dos_fatchk](docs/d.md#dos_fatchk) ... `DOS _FATCHK`でファイルのセクタを取得
  * [dos_fgetc](docs/d.md#dos_fgetc) ... `DOS _FGETC`でファイルから文字入力
  * [dos_fgets](docs/d.md#dos_fgets) ... `DOS _FGETS`でファイルから行入力
  * [dos_filedate](docs/d.md#dos_filedate) ... `DOS _FILEDATE`でファイルのタイムスタンプを取得または設定
  * [dos_getc](docs/d.md#dos_getc) ... `DOS _GETC`で標準入力から文字入力
  * [dos_getchar](docs/d.md#dos_getchar) ... `DOS _GETCHAR`で標準入力から文字入力
  * [dos_getdate](docs/d.md#dos_getdate) ... `DOS _GETDATE`で日付を取得
  * [dos_getenv](docs/d.md#dos_getenv) ... `DOS _GETENV`で環境変数を取得
  * [dos_gets](docs/d.md#dos_gets) ... `DOS _GETS`で標準入力から文字列入力
  * [dos_gettim2](docs/d.md#dos_gettim2) ... `DOS _GETTIM2`で時刻を取得(ロングワード)
  * [dos_gettime](docs/d.md#dos_gettime) ... `DOS _GETTIME`で時刻を取得
  * [dos_inkey](docs/d.md#dos_inkey) ... `DOS _INKEY`で標準入力から文字入力
  * [dos_inpout](docs/d.md#dos_inpout) ... `DOS _INPOUT`による文字入力または文字出力
  * [dos_keyctrl01](docs/d.md#dos_keyctrl01) ... `DOS _KEYCTRL`によるキー入力
  * [dos_maketmp](docs/d.md#dos_maketmp) ... `DOS _MAKETMP`でテンポラリファイルを作成
  * [dos_mkdir](docs/d.md#dos_mkdir) ... `DOS _MKDIR`でディレクトリを作成
  * [dos_nameck](docs/d.md#dos_nameck) ... `DOS _NAMECK`でパス名を展開
  * [dos_namests](docs/d.md#dos_namests) ... `DOS _NAMESTS`でパス名を展開
  * [dos_putchar](docs/d.md#dos_putchar) ... `DOS _PUTCHAR`で標準出力に文字出力
  * [dos_setdate](docs/d.md#dos_setdate) ... `DOS _SETDATE`で日付を設定
  * [dos_setenv](docs/d.md#dos_setenv) ... `DOS _SETENV`で環境変数を設定
  * [dos_setitm2](docs/d.md#dos_setitm2) ... `DOS _SETITM2`で時刻を設定(ロングワード)
  * [dos_settime](docs/d.md#dos_settime) ... `DOS _SETTIME`で時刻を設定
  * [dos_vernum](docs/d.md#dos_vernum) ... `DOS _VERNUM`でHuman68kのバージョンを取得
  * [dumpenv](docs/d.md#dumpenv) ... 環境変数をすべて表示
  * [dumpstdin](docs/d.md#dumpstdin) ... `DOS _READ`で標準入力から読み込み
  * [dumpstupreg](docs/d.md#dumpstupreg) ... 起動時のレジスタ内容を表示
* [E](docs/e.md)
  * [entryceil](docs/e.md#entryceil) ... 上位メモリから起動する。HUPAIR準拠表示の判別コードの検証用
  * [env_sbo](docs/e.md#env_sbo) ... `DOS _GETENV`、`DOS _SETENV`のバッファオーバーフローの動作検証
  * [esc_dsr](docs/e.md#esc_dsr) ... エスケープシーケンス`ESC [6n`で入力されたキーを表示
  * [exception](docs/e.md#exception) ... 例外を発生させて例外処理を呼び出す
  * [exchr_hex](docs/e.md#exchr_hex) ... 拡張外字処理を有効にして常駐終了
  * [execas](docs/e.md#execas) ... 「ファイルを別名で実行するR形式実行ファイル」を作成
  * [exfiles](docs/e.md#exfiles) ... `DOS _FILES`の拡張モードでエントリを検索
  * [existsdir](docs/e.md#existsdir) ... ディレクトリが存在するか調べる
* [F](docs/f.md)
  * [fatchk_bof](docs/f.md#fatchk_bof) ... `DOS _FATCHK`のバッファオーバーフローの動作検証
  * [fe_fcvt_test](docs/f.md#fe_fcvt_test) ... `FPACK __FCVT`の動作テスト
  * [fe_power_test](docs/f.md#fe_power_test) ... `FPACK __POWER`の動作テスト
  * [fe_stoh_test](docs/f.md#fe_stoh_test) ... `FPACK __STOH`の動作テスト
  * [fileopen](docs/f.md#fileopen) ... 各種の方法によるファイル作成、オープン
  * [files](docs/f.md#files) ... `DOS _FILES`と`DOS _NFILES`によるエントリの列挙
  * [fntget](docs/f.md#fntget) ... フォントを拡大してテキストとして表示
  * [fntsize](docs/f.md#fntsize) ... `IOCS _FNTADR`、`IOCS _FNTGET`の結果を一覧表示
* [G](docs/g.md)
  * [getassign](docs/g.md#getassign) ... `DOS _ASSIGN (MD=0)`でドライブの割り当て状態を取得
* [I](docs/i.md)
  * [incdir_test](docs/i.md#incdir_test) ... サブディレクトリ拡張時のディスク破壊の再現補助
  * [iocs_b_clr_st](docs/i.md#iocs_b_clr_st) ... `IOCS _B_CLR_ST`で画面の複数行を消去
  * [iocs_b_del](docs/i.md#iocs_b_del) ... `IOCS _B_DEL`で画面の複数行を削除
  * [iocs_b_ins](docs/i.md#iocs_b_ins) ... `IOCS _B_INS`で画面に複数行を挿入
  * [iocs_datebcd](docs/i.md#iocs_datebcd) ... `IOCS _DATEBCD`で日付データのバイナリ→BCD変換
  * [iocs_datebin](docs/i.md#iocs_datebin) ... `IOCS _DATEBIN`で日付データのBCD→バイナリ変換
  * [iocs_dateget](docs/i.md#iocs_dateget) ... `IOCS _DATEGET`で日付を取得
  * [iocs_dateset](docs/i.md#iocs_dateset) ... `IOCS _DATESET`で日付を設定
  * [iocs_ontime](docs/i.md#iocs_ontime) ... `IOCS _ONTIME`で起動後の経過時間を取得
  * [iocs_timebcd](docs/i.md#iocs_timebcd) ... `IOCS _TIMEBCD`で時刻データのバイナリ→BCD変換
  * [iocs_timebin](docs/i.md#iocs_timebin) ... `IOCS _TIMEBIN`で時刻データのBCD→バイナリ変換
  * [iocs_timeget](docs/i.md#iocs_timeget) ... `IOCS _TIMEGET`で時刻を取得
  * [iocs_timeset](docs/i.md#iocs_timeset) ... `IOCS _TIMESET`で時刻を設定
  * [iocs_txfill](docs/i.md#iocs_txfill) ... `IOCS _TXFILL`のサンプル
  * [iocs_txrascpy](docs/i.md#iocs_txrascpy) ... `IOCS _TXYLINE`のサンプル
  * [iocs_txyline](docs/i.md#iocs_txyline) ... `IOCS _TXRASCPY`でラスタコピーを行う
  * [ioctrl12](docs/i.md#ioctrl12) ... `DOS _IOCTRL (MD=12, F_CODE=0)`によるファイルの特殊コントロール
  * [ioctrl13](docs/i.md#ioctrl13) ... `DOS _IOCTRL (MD=13, F_CODE=0)`によるドライブの特殊コントロール
  * [isemu_rtc](docs/i.md#isemu_rtc) ... RTCの挙動の違いを利用したエミュレータ判別
* [J](docs/j.md)
  * [jfp_stat](docs/j.md#jfp_stat) ... 日本語FPの各状態を表示
  * [joyget](docs/j.md#joyget) ... `IOCS _JOYGET`によるジョイスティック入力
* [K](docs/k.md)
  * [kbdctrl](docs/k.md#kbdctrl) ... キーボード制御コマンドコードをキーボードに送信
  * [keepceil](docs/k.md#keepceil) ... 上位メモリに常駐する。常駐検査コードの検証用
  * [keepcmem](docs/k.md#keepcmem) ... 上位メモリからメモリを確保して常駐する。常駐検査コードの検証用
  * [keyflush](docs/k.md#keyflush) ... キー入力をフラッシュしてから終了する
  * [keyscan](docs/k.md#keyscan) ... キーボードから受信したスキャンコードを表示
* [L](docs/l.md)
  * [lineage](docs/l.md#lineage) ... 自分自身と祖先のメモリ管理ポインタを表示
  * [loadonly](docs/l.md#loadonly) ... `DOS _EXEC (MD=3;loadonly)`で実行ファイルをロード
* [M](docs/m.md)
  * [mallocall](docs/m.md#mallocall) ... メモリブロックを可能な限り確保
  * [malloc_ba_exec](docs/m.md#malloc_ba_exec) ... `DOS _EXEC`の前後でメモリを確保
  * [midi_reg](docs/m.md#midi_reg) ... MIDIボード(YM3802)のレジスタの値を表示
  * [movem_aipi](docs/m.md#movem_aipi) ... `movem.l (a0)+,a0`命令を実行する。エミュレータの検証用
  * [mpcm_echcnt](docs/m.md#mpcm_echcnt) ... MPCM.Xの効果音発声数を設定
* [N](docs/n.md)
  * [nameck_bof](docs/n.md#nameck_bof) ... `DOS _NAMECK`のバッファオーバーフローの動作検証
  * [namests_bof](docs/n.md#namests_bof) ... `DOS _NAMESTS`のバッファオーバーフローの動作検証
  * [newvol](docs/n.md#newvol) ... `DOS _NEWFILE`でボリュームラベルを作成
  * [ns_sbo](docs/n.md#ns_sbo) ... `DOS _NAMESTS`の内部ルーチンのバッファオーバーフローの動作検証
* [O](docs/o.md)
  * [openedfiles](docs/o.md#openedfiles) ... オープン中のファイルの一覧表示
  * [openkeep](docs/o.md#openkeep) ... ファイルを開いたまま常駐終了する。`DOS _KEEPPR`の動作検証
* [P](docs/p.md)
  * [pathchk](docs/p.md#pathchk) ... `DOS _EXEC (MD=2;pathchk)`で実行ファイルを検索
  * [pathlenfix](docs/p.md#pathlenfix) ... Human68kにパッチをあててディレクトリ名の最大長を拡張
  * [pt_7e](docs/p.md#pt_7e) ... 文字コード`0x7e`とX68000の機種依存文字を表示
  * [pt_dbhw](docs/p.md#pt_dbhw) ... X68000の機種依存文字の文字表を表示
  * [pt_usk](docs/p.md#pt_usk) ... ユーザー定義外字の文字表を表示
  * [putmes12](docs/p.md#putmes12) ... 文字列をテキスト画面に12ドットフォントで描画
  * [putmes24](docs/p.md#putmes24) ... 文字列をテキスト画面に24ドットフォントで描画
* [R](docs/r.md)
  * [reset68k](docs/r.md#reset68k) ... `trap #10`命令によるソフトウェアリセット
  * [rewind](docs/r.md#rewind) ... `DOS _SEEK (mode=2, offset=-1)`によるファイルシークの動作検証
  * [run68_dos_test](docs/r.md#run68_dos_test) ... run68の`-f`オプションの動作確認用
  * [runwaitchk](docs/r.md#runwaitchk) ... メモリを読み込むループの実行時間を計測
* [S](docs/s.md)
  * [si_acc](docs/s.md#si_acc) ... 装着されているアクセラレータの種類を表示
  * [si_emu](docs/s.md#si_emu) ... 実行中のエミュレータの種類を表示
  * [si_memory](docs/s.md#si_memory) ... メインメモリとハイメモリの情報を表示
  * [si_midi](docs/s.md#si_midi) ... MIDIボードの種類を表示
  * [si_model](docs/s.md#si_model) ... 本体の機種名を表示
  * [si_phantomx](docs/s.md#si_phantomx) ... PhantomXの情報を表示
  * [si_scsiex](docs/s.md#si_scsiex) ... SCSIボードの機種名を表示
  * [si_sram](docs/s.md#si_sram) ... SRAMの容量と使用状況を表示
  * [sjis_tbl](docs/s.md#sjis_tbl) ... Shift_JISの2バイト文字の文字表を表示
  * [skeyset](docs/s.md#skeyset) ... `IOCS _SKEYSET`によりキー入力を発生し、`IOCS _B_KEYINP`で取得
  * [sp3tx0gr2](docs/s.md#sp3tx0gr2) ... 画面間プライオリティを特殊な値に設定。エミュレータの検証用
  * [spchecker](docs/s.md#spchecker) ... スプライトを市松模様に表示
  * [splimchk](docs/s.md#splimchk) ... スプライトの表示限界の検証用
  * [sq64k](docs/s.md#sq64k) ... 画面モードを768×512、65536色に変更
  * [sram_memsize](docs/s.md#sram_memsize) ... SRAMのメインメモリ容量を書き換える。エミュレータの検証用
  * [super_time](docs/s.md#super_time) ... `IOCS _B_SUPER`、`DOS _SUPER`、`DOS _SUPER_JSR`のベンチマーク
  * [sysport](docs/s.md#sysport) ... システムポート領域の値の表示
* [T](docs/t.md)
  * [tokikoe](docs/t.md#tokikoe) ... テキスト画面に特定のメッセージを描画
  * [tpalreset](docs/t.md#tpalreset) ... テキストパレットをシステム設定値に戻す
  * [trap15trace](docs/t.md#trap15trace) ... トレース実行に対応した`trap #15`処理ルーチン
* [U](docs/u.md)
  * [uskcg24](docs/u.md#uskcg24) ... ユーザー定義外字の文字表をテキスト画面に描画
  * [uskfontadr](docs/u.md#uskfontadr) ... 外字フォントデータのアドレスを表示
  * [uskhw_hex](docs/u.md#uskhw_hex) ... 半角外字のフォントを文字コード表記に書き換え
* [V](docs/v.md)
  * [vdispst_time](docs/v.md#vdispst_time) ... `IOCS _VDISPST`による割り込みが発生するまでの時間を計測
* [Z](docs/z.md)
  * [zerounit.sys](docs/z.md#zerounitsys) ... ブロックデバイスのユニット数=0の動作検証
  * [zmsc2_gettrktbl](docs/z.md#zmsc2_gettrktbl)
    ... Z-MUSIC v2の絶対チャンネルテーブル、演奏トラックテーブルを表示
  * [zmsc2_mstat](docs/z.md#zmsc2_mstat) ... Z-MUSIC v2の演奏状態を表示
  * [zmsc2_oddopm](docs/z.md#zmsc2_oddopm) ... 奇数アドレスにあるZ-MUSIC v2のZMDデータをOPMデバイスに書き込む


## シビアなメモリ状況を構築するプログラムについて
一般に、常駐検査を行うプログラムやプログラム本体の後にバッファを確保するプログラムでは
メモリを読み書きする前にメモリブロックの大きさを確認しなければなりません。
それを怠ると、メモリブロックが期待より小さな場合にメモリブロックの範囲外を読み書きしてしまい、
他のメモリブロックの内容の破壊、バスエラーによる停止、プログラムの暴走などの問題が生じます。

[crampedexec](docs/c.md#crampedexec)、[keepceil](docs/k.md#keepceil)、[keepcmem](docs/k.md#keepcmem)
などのコードはそのようなプログラムの動作を検証するための補助として、意図的に「小さなメモリブロック」
を作り出します。

より確実に検証するためには、メインメモリ容量を11MB以下にしてください。
メインメモリが12MBだとメモリブロックの範囲外がGVRAMになるため、
スーパーバイザモードになっているとバスエラーが発生せず読み書きできてしまうためです。


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
* [HLKX](https://github.com/kg68k/hlkx) 1.1.0 以降
  * 環境変数`LD=hlkx`を設定するか、make 実行時のコマンドラインオプションで指定してください。
  * 指定しない場合はHLKが使用されますが、一部のファイルがビルドされません。
* gcc2


## License
GNU General Public License version 3 or later.


## Author
TcbnErik / 立花@桑島技研  
https://github.com/kg68k/xperiment68k

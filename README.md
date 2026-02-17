# Xperiment68k

実験的なコードとかいろいろ。

無保証です。  
十分なテストを行っていないので、不具合があるかもしれません。


## Description

* [ADPCM](docs/adpcm.md)
  * [beep_adpcmout](docs/adpcm.md#beep_adpcmout) ... システムビープ音を`IOCS _ADPCMOUT`で再生
  * [beep_mpcm](docs/adpcm.md#beep_mpcm) ... システムビープ音をMPCMで効果音として再生
  * [beep_zmsc3](docs/adpcm.md#beep_zmsc3) ... システムビープ音をZMSC3.Xで効果音として再生
  * [mpcm_echcnt](docs/adpcm.md#mpcm_echcnt) ... MPCM.Xの効果音発声数を設定
* [BackGround Process](docs/bg.md)
  * [bg1pr2th](docs/bg.md#bg1pr2th) ... 2個のスレッドを作成して常駐終了
  * [bgchangeprc](docs/bg.md#bgchangeprc) ... 常駐してスレッド切り替え回数を表示
  * [bgexec](docs/bg.md#bgexec) ... 指定コマンドの実行指示をbgexecdスレッドに送信
  * [bgexecd](docs/bg.md#bgexecd) ... 常駐終了し、指定されたコマンドをバックグラウンドで実行
  * [bggetpr](docs/bg.md#bggetpr) ... `DOS _GET_PR`でスレッド情報を取得
  * [bgkill](docs/bg.md#bgkill) ... スレッドに終了要求コマンドを送信
  * [bgontime](docs/bg.md#bgontime) ... `IOCS _ONTIME`の結果をバックグラウンドで表示
  * [bgsleeppr](docs/bg.md#bgsleeppr) ... `DOS _SLEEP_PR`でスレッドをスリープする
  * [bgsprocd](docs/bg.md#bgsprocd) ... bgexecdとほぼ同じだがサブのメモリ管理を設定する
  * [bgsprocess](docs/bg.md#bgsprocess) ... スレッドに対しサブのメモリ管理を設定
  * [bgsuspendpr](docs/bg.md#bgsuspendpr) ... `DOS _SUSPEND_PR`でスレッドを強制スリープさせる
  * [bgthreadid](docs/bg.md#bgthreadid) ... スレッドIDを表示
  * [bgwakeup](docs/bg.md#bgwakeup) ... スレッドに強制スリープ解除コマンドを送信
* [Charset](docs/charset.md)
  * [pt_7e](docs/charset.md#pt_7e) ... 文字コード`0x7e`とX68000の機種依存文字を表示
  * [pt_dbhw](docs/charset.md#pt_dbhw) ... X68000の機種依存文字の文字表を表示
  * [pt_usk](docs/charset.md#pt_usk) ... ユーザー定義外字の文字表を表示
  * [sjis_tbl](docs/charset.md#sjis_tbl) ... Shift_JISの2バイト文字の文字表を表示
* [Console](docs/console.md)
  * [bputmes_cur](docs/console.md#bputmes_cur) ... `IOCS _B_PUTMES`のカーソル描画残留の動作検証
  * [con_scroll](docs/console.md#con_scroll) ... コンソール画面のスクロールのテスト
  * [dumpstdin](docs/console.md#dumpstdin) ... `DOS _READ`で標準入力から読み込み
  * [esc_dsr](docs/console.md#esc_dsr) ... エスケープシーケンス`ESC [6n`で入力されたキーを表示
  * [gaiji_ttl](docs/console.md#gaiji_ttl) ... 外字でタイトルを表示するデモンストレーション
  * [putmes12](docs/console.md#putmes12) ... 文字列をテキスト画面に12ドットフォントで描画
  * [putmes24](docs/console.md#putmes24) ... 文字列をテキスト画面に24ドットフォントで描画
  * [tpalreset](docs/console.md#tpalreset) ... テキストパレットをシステム設定値に戻す
* [DOS CALL](docs/dos.md)
  * [dos_chdir](docs/dos.md#dos_chdir) ... `DOS _CHDIR`でカレントディレクトリを変更
  * [dos_chgdrv](docs/dos.md#dos_chgdrv) ... `DOS _CHGDRV`でカレントドライブを変更
  * [dos_chmod](docs/dos.md#dos_chmod) ... `DOS _CHMOD`でファイルの属性を取得・変更
  * [dos_conctrl](docs/dos.md#dos_conctrl) ... `DOS _CONCTRL`でコンソール制御・直接出力
  * [dos_create_sp](docs/dos.md#dos_create_sp) ... `DOS _CREATE`の特殊モードでファイルを作成
  * [dos_curdir](docs/dos.md#dos_curdir) ... `DOS _CURDIR`でカレントディレクトリを取得
  * [dos_curdrv](docs/dos.md#dos_curdrv) ... `DOS _CURDRV`でカレントドライブを取得
  * [dos_diskred](docs/dos.md#dos_diskred) ... `DOS _DISKRED`でブロックデバイスから直接読み込み
  * [dos_exit2](docs/dos.md#dos_exit2) ... `DOS _EXIT2`で指定した終了コードで終了
  * [dos_fatchk](docs/dos.md#dos_fatchk) ... `DOS _FATCHK`でファイルのセクタを取得
  * [dos_fgetc](docs/dos.md#dos_fgetc) ... `DOS _FGETC`でファイルから文字入力
  * [dos_fgets](docs/dos.md#dos_fgets) ... `DOS _FGETS`でファイルから行入力
  * [dos_filedate](docs/dos.md#dos_filedate) ... `DOS _FILEDATE`でファイルのタイムスタンプを取得または設定
  * [dos_getc](docs/dos.md#dos_getc) ... `DOS _GETC`で標準入力から文字入力
  * [dos_getchar](docs/dos.md#dos_getchar) ... `DOS _GETCHAR`で標準入力から文字入力
  * [dos_getdate](docs/dos.md#dos_getdate) ... `DOS _GETDATE`で日付を取得
  * [dos_getenv](docs/dos.md#dos_getenv) ... `DOS _GETENV`で環境変数を取得
  * [dos_gets](docs/dos.md#dos_gets) ... `DOS _GETS`で標準入力から文字列入力
  * [dos_gettim2](docs/dos.md#dos_gettim2) ... `DOS _GETTIM2`で時刻を取得(ロングワード)
  * [dos_gettime](docs/dos.md#dos_gettime) ... `DOS _GETTIME`で時刻を取得
  * [dos_inkey](docs/dos.md#dos_inkey) ... `DOS _INKEY`で標準入力から文字入力
  * [dos_inpout](docs/dos.md#dos_inpout) ... `DOS _INPOUT`による文字入力または文字出力
  * [dos_keyctrl01](docs/dos.md#dos_keyctrl01) ... `DOS _KEYCTRL`によるキー入力
  * [dos_maketmp](docs/dos.md#dos_maketmp) ... `DOS _MAKETMP`でテンポラリファイルを作成
  * [dos_malloc2](docs/dos.md#dos_malloc2) ... `DOS _MALLOC2`または`_S_MALLOC`でメモリを確保
  * [dos_mkdir](docs/dos.md#dos_mkdir) ... `DOS _MKDIR`でディレクトリを作成
  * [dos_nameck](docs/dos.md#dos_nameck) ... `DOS _NAMECK`でパス名を展開
  * [dos_namests](docs/dos.md#dos_namests) ... `DOS _NAMESTS`でパス名を展開
  * [dos_putchar](docs/dos.md#dos_putchar) ... `DOS _PUTCHAR`で標準出力に文字出力
  * [dos_rmdir](docs/dos.md#dos_rmdir) ... `DOS _RMDIR`でディレクトリを削除
  * [dos_setdate](docs/dos.md#dos_setdate) ... `DOS _SETDATE`で日付を設定
  * [dos_setenv](docs/dos.md#dos_setenv) ... `DOS _SETENV`で環境変数を設定
  * [dos_settim2](docs/dos.md#dos_settim2) ... `DOS _SETTIM2`で時刻を設定(ロングワード)
  * [dos_settime](docs/dos.md#dos_settime) ... `DOS _SETTIME`で時刻を設定
  * [dos_verify](docs/dos.md#dos_verify) ... `DOS _VERIFY`でベリファイフラグを設定
  * [dos_verifyg](docs/dos.md#dos_verifyg) ... `DOS _VERIFYG`でベリファイフラグを取得
  * [dos_vernum](docs/dos.md#dos_vernum) ... `DOS _VERNUM`でHuman68kのバージョンを取得
  * [dos_wait](docs/dos.md#dos_wait) ... `DOS _WAIT`で終了したプロセスの終了コードを取得
* [Emulator](docs/emulator.md)
  * [adpcmotchk](docs/emulator.md#adpcmotchk) ... IOCSによるADPCM再生後にDMACのレジスタ値を表示
  * [buserr_2w](docs/emulator.md#buserr_2w) ... バスエラーを発生させる。エミュレータの検証用
  * [isemu_rtc](docs/emulator.md#isemu_rtc) ... RTCの挙動の違いを利用したエミュレータ判別
  * [movem_aipi](docs/emulator.md#movem_aipi) ... `movem.l (a0)+,a0`命令を実行する。エミュレータの検証用
  * [run68_dos_test](docs/emulator.md#run68_dos_test) ... run68の`-f`オプションの動作確認用
  * [sram_memsize](docs/emulator.md#sram_memsize) ... SRAMのメインメモリ容量を書き換える。エミュレータの検証用
* [FEFUNC](docs/fe.md)
  * [fe_fcvt_test](docs/fe.md#fe_fcvt_test) ... `FPACK __FCVT`の動作テスト
  * [fe_power_test](docs/fe.md#fe_power_test) ... `FPACK __POWER`の動作テスト
  * [fe_stoh_test](docs/fe.md#fe_stoh_test) ... `FPACK __STOH`の動作テスト
* [File](docs/file.md)
  * [appendbytes](docs/file.md#appendbytes) ... ファイル末尾にデータを追記
  * [closerewindatr](docs/file.md#closerewindatr) ... `DOS _CLOSE`時のファイル属性巻き戻りの動作検証
  * [exfiles](docs/file.md#exfiles) ... `DOS _FILES`の拡張モードでエントリを検索
  * [existsdir](docs/file.md#existsdir) ... ディレクトリが存在するか調べる
  * [fileop](docs/file.md#fileop) ... ファイルの作成、オープンと入出力
  * [files](docs/file.md#files) ... `DOS _FILES`と`DOS _NFILES`によるエントリの列挙
  * [getassign](docs/file.md#getassign) ... `DOS _ASSIGN (MD=0)`でドライブの割り当て状態を取得
  * [ioctrl12](docs/file.md#ioctrl12) ... `DOS _IOCTRL (MD=12, F_CODE=0)`によるファイルの特殊コントロール
  * [ioctrl13](docs/file.md#ioctrl13) ... `DOS _IOCTRL (MD=13, F_CODE=0)`によるドライブの特殊コントロール
  * [newvol](docs/file.md#newvol) ... `DOS _NEWFILE`でボリュームラベルを作成
  * [openedfiles](docs/file.md#openedfiles) ... オープン中のファイルの一覧表示
  * [pathlenfix](docs/file.md#pathlenfix) ... Human68kにパッチをあててディレクトリ名の最大長を拡張
  * [rewind](docs/file.md#rewind) ... `DOS _SEEK (mode=2, offset=-1)`によるファイルシークの動作検証
* [Font](docs/font.md)
  * [ankfont](docs/font.md#ankfont) ... ANKフォントをテキスト画面に描画
  * [defchr_7621](docs/font.md#defchr_7621) ... `IOCS _DEFCHR`の動作検証
  * [defchr_81f8](docs/font.md#defchr_81f8) ... SJIS:$81f8のフォントにナチュラル記号を定義
  * [exchr_hex](docs/font.md#exchr_hex) ... 拡張外字処理を有効にして常駐終了
  * [fntadr](docs/font.md#fntadr) ... `IOCS _FNTADR`でフォントアドレスを取得
  * [fntget](docs/font.md#fntget) ... フォントを拡大してテキストとして表示
  * [fntsize](docs/font.md#fntsize) ... `IOCS _FNTADR`、`IOCS _FNTGET`の結果を一覧表示
  * [uskcg24](docs/font.md#uskcg24) ... ユーザー定義外字の文字表をテキスト画面に描画
  * [uskcg_hex](docs/font.md#uskcg_hex) ... ユーザー定義外字のフォントを文字コード表記に書き換え
  * [uskcg_save](docs/font.md#uskcg_save) ... ユーザー定義外字のフォントをファイルに保存
  * [uskfontadr](docs/font.md#uskfontadr) ... 外字フォントデータのアドレスを表示
  * [uskhw_hex](docs/font.md#uskhw_hex) ... 半角外字のフォントを文字コード表記に書き換え
* [Grahic](docs/graphic.md)
  * [colorbar](docs/graphic.md#colorbar) ... カラーバーのような画像を描画
  * [colorgradient](docs/graphic.md#colorgradient) ... カラーグラデーションの画像を描画
  * [sq64k](docs/graphic.md#sq64k) ... 画面モードを768×512、65536色に変更
* [IOCS CALL](docs/iocs.md)
  * [iocs_akconv](docs/iocs.md#iocs_akconv) ... `IOCS _AKCONV`でANK文字コードをS-JISに変換
  * [iocs_b_clr_st](docs/iocs.md#iocs_b_clr_st) ... `IOCS _B_CLR_ST`でコンソールの複数行を消去
  * [iocs_b_conmod](docs/iocs.md#iocs_b_conmod) ... `IOCS _B_CONMOD`でカーソルとスクロールを設定
  * [iocs_b_del](docs/iocs.md#iocs_b_del) ... `IOCS _B_DEL`でコンソールの複数行を削除
  * [iocs_b_ins](docs/iocs.md#iocs_b_ins) ... `IOCS _B_INS`でコンソールに複数行を挿入
  * [iocs_b_putc](docs/iocs.md#iocs_b_putc) ... `IOCS _B_PUTC`でコンソールに文字を表示
  * [iocs_b_print](docs/iocs.md#iocs_b_print) ... `IOCS _B_PRINT`でコンソールに文字列を表示
  * [iocs_datebcd](docs/iocs.md#iocs_datebcd) ... `IOCS _DATEBCD`で日付データのバイナリ→BCD変換
  * [iocs_datebin](docs/iocs.md#iocs_datebin) ... `IOCS _DATEBIN`で日付データのBCD→バイナリ変換
  * [iocs_dateget](docs/iocs.md#iocs_dateget) ... `IOCS _DATEGET`で日付を取得
  * [iocs_dateset](docs/iocs.md#iocs_dateset) ... `IOCS _DATESET`で日付を設定
  * [iocs_b_drvchk](docs/iocs.md#iocs_b_drvchk) ... `IOCS _B_DRVCHK`で2HDドライブの状態設定
  * [iocs_jissft](docs/iocs.md#iocs_jissft) ... `IOCS _JISSFT`でJIS文字コードをS-JISに変換
  * [iocs_ms_offtm](docs/iocs.md#iocs_ms_offtm) ... `IOCS _MS_OFFTM`でマウスボタンを離すまでの時間を計測
  * [iocs_ms_ontm](docs/iocs.md#iocs_ms_ontm) ... `IOCS _MS_ONTM`でマウスボタンを押すまでの時間を計測
  * [iocs_ontime](docs/iocs.md#iocs_ontime) ... `IOCS _ONTIME`で起動後の経過時間を取得
  * [iocs_romver](docs/iocs.md#iocs_romver) ... `IOCS _ROMVER`でROMのバージョンを取得
  * [iocs_sftjis](docs/iocs.md#iocs_sftjis) ... `IOCS _SFTJIS`でS-JIS文字コードをJISに変換
  * [iocs_timebcd](docs/iocs.md#iocs_timebcd) ... `IOCS _TIMEBCD`で時刻データのバイナリ→BCD変換
  * [iocs_timebin](docs/iocs.md#iocs_timebin) ... `IOCS _TIMEBIN`で時刻データのBCD→バイナリ変換
  * [iocs_timeget](docs/iocs.md#iocs_timeget) ... `IOCS _TIMEGET`で時刻を取得
  * [iocs_timeset](docs/iocs.md#iocs_timeset) ... `IOCS _TIMESET`で時刻を設定
  * [iocs_txfill](docs/iocs.md#iocs_txfill) ... `IOCS _TXFILL`のサンプル
  * [iocs_txrascpy](docs/iocs.md#iocs_txrascpy) ... `IOCS _TXYLINE`のサンプル
  * [iocs_txyline](docs/iocs.md#iocs_txyline) ... `IOCS _TXRASCPY`でラスタコピーを行う
* [Keyboard](docs/keyboard.md)
  * [bitsns](docs/keyboard.md#bitsns) ... `IOCS _BITSNS`でキーの押し下げ状態を表示
  * [jfp_stat](docs/keyboard.md#jfp_stat) ... 日本語FPの各状態を表示
  * [kbdctrl](docs/keyboard.md#kbdctrl) ... キーボード制御コマンドコードをキーボードに送信
  * [keyflush](docs/keyboard.md#keyflush) ... キー入力をフラッシュしてから終了する
  * [keyscan](docs/keyboard.md#keyscan) ... キーボードから受信したスキャンコードを表示
  * [skeyset](docs/keyboard.md#skeyset) ... `IOCS _SKEYSET`によりキー入力を発生し、`IOCS _B_KEYINP`で取得
* [Miscellaneous](docs/misc.md)
  * [datetime](docs/misc.md#datetime) ... IOCSで日時を取得、表示
  * [dbrams](docs/misc.md#dbrams) ... IOCSワーク`$cb8`、`$cba`の値を再計測
  * [exception](docs/misc.md#exception) ... 例外を発生させて例外処理を呼び出す
  * [e_ver232c](docs/misc.md#e_ver232c) ... `ERS E_VER232C`でRSDRV.SYSのバージョンを取得
  * [hasophash](docs/misc.md#hasophash) ... HAS060X.Xの命令ハッシュ値を計算
  * [is31days](docs/misc.md#is31days) ... 月の日数が31日まであるか確認するコード(移植版)
  * [joyget](docs/misc.md#joyget) ... `IOCS _JOYGET`によるジョイスティック入力
  * [midi_reg](docs/misc.md#midi_reg) ... MIDIボード(YM3802)のレジスタの値を表示
  * [minish](docs/misc.md#minish) ... 最小限の機能(ファイルの実行だけ)しかない簡易シェル(minimal shell)
  * [nminoreset](docs/misc.md#nminoreset) ... NMIスイッチ処理でのNMIリセットの必要性の検証
  * [reset68k](docs/misc.md#reset68k) ... `trap #10`命令によるソフトウェアリセット
  * [rtc_reg](docs/misc.md#rtc_reg) ... RTC(RP5C15)のレジスタの値を表示
  * [runwaitchk](docs/misc.md#runwaitchk) ... メモリを読み込むループの実行時間を計測
  * [super_time](docs/misc.md#super_time) ... `IOCS _B_SUPER`、`DOS _SUPER`、`DOS _SUPER_JSR`のベンチマーク
  * [sysport](docs/misc.md#sysport) ... システムポート領域の値の表示
  * [s_level](docs/misc.md#s_level) ... `SCSI _S_LEVEL`でSCSI IOCSのバージョンを取得
  * [tokikoe](docs/misc.md#tokikoe) ... テキスト画面に特定のメッセージを描画
  * [trap15trace](docs/misc.md#trap15trace) ... トレース実行に対応した`trap #15`処理ルーチン
  * [vdispst_time](docs/misc.md#vdispst_time) ... `IOCS _VDISPST`による割り込みが発生するまでの時間を計測
* [OPMDRV\*.X](docs/opmdrv.md)
  * [md_on](docs/opmdrv.md#md_on) ... `OPM _MD_ON`でMIDIチャンネル出力許可
  * [md_off](docs/opmdrv.md#md_off) ... `OPM _MD_OFF`でMIDIチャンネル出力禁止
  * [md_stat](docs/opmdrv.md#md_stat) ... `OPM _MD_STAT`でMIDIチャンネル出力許可・禁止状態を得る
  * [m_alloc](docs/opmdrv.md#m_alloc) ... `OPM _M_ALLOC`でトラックバッファ確保
  * [m_antoff](docs/opmdrv.md#m_antoff) ... `OPM _M_ANTOFF`でチャンネルにオートノートオフ出力
  * [m_assign](docs/opmdrv.md#m_assign) ... `OPM _M_ASSIGN`でチャンネルにトラック番号を割り当て
  * [m_atoi](docs/opmdrv.md#m_atoi) ... `OPM _M_ATOI`でトラックバッファの先頭アドレス取得
  * [m_bend](docs/opmdrv.md#m_bend) ... `OPM _M_BEND`でチャンネルのピッチベンドを設定
  * [m_chan](docs/opmdrv.md#m_chan) ... `OPM _M_CHAN`で出力チャンネルを設定・取得
  * [m_chget](docs/opmdrv.md#m_chget) ... `OPM $2e`でチャンネル情報のアドレスを取得
  * [m_click](docs/opmdrv.md#m_click) ... `OPM _M_CLICK`でメトロノームのクリック音を設定
  * [m_cont](docs/opmdrv.md#m_cont) ... `OPM _M_CONT`で演奏を再開
  * [m_enable](docs/opmdrv.md#m_enable) .. `OPM _M_ENABLE`でチャンネルの発声許可・禁止
  * [m_end](docs/opmdrv.md#m_end) .. `OPM _M_END`で演奏停止小節を設定
  * [m_free](docs/opmdrv.md#m_free) ... `OPM _M_FREE`でトラックバッファの残りバイト数を取得
  * [m_freea](docs/opmdrv.md#m_freea) ... `OPM _M_FREEA`でトラックバッファの全バイト数を取得
  * [m_ifchk](docs/opmdrv.md#m_ifchk) ... `OPM _M_IFCHK`でMIDIインターフェイスの有無を検出
  * [m_init](docs/opmdrv.md#m_init) ... `OPM _M_INIT`でトラックバッファ初期化
  * [m_intcall](docs/opmdrv.md#m_intcall) ... `OPM $1f`でユーザーサブルーチンの登録・停止・アドレス取得
  * [m_intoff](docs/opmdrv.md#m_intoff) ... `OPM $0e`で割り込みを停止
  * [m_inton](docs/opmdrv.md#m_inton) ... `OPM $0d`で割り込みを開始
  * [m_mdreg](docs/opmdrv.md#m_mdreg) ... `OPM _M_MDREG`でMIDIコントローラー(YM3802)のレジスタに書き込み
  * [m_meas](docs/opmdrv.md#m_meas) ... `OPM _M_MEAS`で演奏中の小節番号を取得
  * [m_mstvol](docs/opmdrv.md#m_mstvol) ... `OPM _M_MSTVOL`でマスターボリュームを設定・取得
  * [m_mod](docs/opmdrv.md#m_mod) ... `OPM _M_MOD`でチャンネルのモジュレーションを設定
  * [m_modsns](docs/opmdrv.md#m_modsns) ... `OPM _M_MODSNS`でFM音源(YM2151)のモジュレーションの深さを設定・取得
  * [m_opmexc](docs/opmdrv.md#m_opmexc) ... `OPM _M_OPMEXC`でFM音源(YM2151)のパラメーターセットモードを設定・取得
  * [m_opmlfq](docs/opmdrv.md#m_opmlfq) ... `OPM _M_OPMLFQ`でFM音源(YM2151)の発振周波数を設定・取得
  * [m_opmreg](docs/opmdrv.md#m_opmreg) ... `OPM _M_OPMREG`でFM音源(YM2151)のレジスタを読み書き
  * [m_pan](docs/opmdrv.md#m_pan) ... `OPM _M_PAN`でチャンネルのパンポットを設定・取得
  * [m_panflt](docs/opmdrv.md#m_panflt) ... `OPM _M_PANFLT`でパンポット設定コマンドの出力フィルタを設定・取得
  * [m_pcmbsy](docs/opmdrv.md#m_pcmbsy) ... `OPM _M_PCMBSY`でPCMの実行状態を取得
  * [m_pcmget](docs/opmdrv.md#m_pcmget) ... `OPM _M_PCMGET`でPCMバッファに登録されたADPCMデータを取得
  * [m_pcmlen](docs/opmdrv.md#m_pcmlen) ... `OPM _M_PCMLEN`でPCMバッファに登録されたADPCMデータのサイズを取得
  * [m_pcmon](docs/opmdrv.md#m_pcmon) ... `OPM _M_PCMON`でPCMバッファに登録されたADPCMデータを再生
  * [m_pcmrec](docs/opmdrv.md#m_pcmrec) ... `OPM _M_PCMREC`でオーディオ入力端子からADPCMを録音
  * [m_pcmset](docs/opmdrv.md#m_pcmset) ... `OPM _M_PCMSET`でPCMバッファにADPCMデータを登録
  * [m_pgmflt](docs/opmdrv.md#m_pgmflt) ... `OPM _M_PGMFLT`でMML音色切り替えコマンドの出力フィルタを設定・取得
  * [m_play](docs/opmdrv.md#m_play) ... `OPM _M_PLAY`で演奏を開始
  * [m_tnmget](docs/opmdrv.md#m_pnmget) ... `OPM _M_PNMGET`でPCM音源の音色名を取得
  * [m_tnmset](docs/opmdrv.md#m_pnmset) ... `OPM _M_PNMSET`でPCM音源の音色名を登録
  * [m_prog](docs/opmdrv.md#m_prog) ... `OPM _M_PROG`でチャンネルの音色番号を設定・取得
  * [m_start](docs/opmdrv.md#m_start) .. `OPM _M_START`で演奏開始小節を設定
  * [m_stat](docs/opmdrv.md#m_stat) ... `OPM _M_STAT`で演奏状態を取得
  * [m_stop](docs/opmdrv.md#m_stop) ... `OPM _M_STOP`で演奏を停止
  * [m_sync](docs/opmdrv.md#m_sync) ... `OPM _M_SYNC`で同期モードを設定
  * [m_sysch](docs/opmdrv.md#m_sysch) ... `OPM _M_SYSCH`でチャンネル番号の割り当てモードを変更・取得
  * [m_tempo](docs/opmdrv.md#m_tempo) ... `OPM _M_TEMPO`で曲のテンポを指定
  * [m_tnmget](docs/opmdrv.md#m_tnmget) ... `OPM _M_TNMGET`でFM音源(YM2151)の音色名を取得
  * [m_tnmset](docs/opmdrv.md#m_tnmset) ... `OPM _M_TNMSET`でFM音源(YM2151)の音色名を登録
  * [m_trk](docs/opmdrv.md#m_trk) ... `OPM _M_TRK`でトラックへMMLを書き込む
  * [m_trkget](docs/opmdrv.md#m_trkget) ... `OPM $2d`でトラック情報のアドレスを取得
  * [m_trns](docs/opmdrv.md#m_trns) ... `OPM _M_TRNS`でチャンネルのトランスポーズを設定・取得
  * [m_use](docs/opmdrv.md#m_use) ... `OPM _M_USE`でトラックバッファの使用容量を取得
  * [m_vel](docs/opmdrv.md#m_vel) ... `OPM _M_VEL`でチャンネルのベロシティを設定・取得
  * [m_version](docs/opmdrv.md#m_version) ... `OPM _M_VERSION`でバージョンと作成年月日を取得
  * [m_vget](docs/opmdrv.md#m_vget) ... `OPM _M_VGET`でFM音源(YM2151)の音色データを取得
  * [m_vol](docs/opmdrv.md#m_vol) ... `OPM _M_VOL`でチャンネルのボリュームを設定・取得
  * [m_volflt](docs/opmdrv.md#m_volflt) ... `OPM _M_VOLFLT`でボリューム設定コマンドの出力フィルタを設定・取得
  * [m_vset](docs/opmdrv.md#m_vset) ... `OPM _M_VSET`でFM音源(YM2151)の音色データを設定
  * [m_ycom](docs/opmdrv.md#m_ycom) ... `OPM _M_YCOM`でYコマンドの使用モードを設定・取得
  * [opmcallvec](docs/opmdrv.md#opmcallvec) ... OPMコールの処理アドレスを表示
  * [opmdrvtype](docs/opmdrv.md#opmdrvtype) ... 組み込まれているOPMDRV\*.Xの種類を表示
* [Proof of Concept](docs/poc.md)
  * [bglivingdead](docs/poc.md#bglivingdead) ... `DOS _KILL_PR`の動作検証
  * [bgzombie](docs/poc.md#bgzombie) ... `DOS _KILL_PR`の動作検証
  * [bkeyinpd3](docs/poc.md#bkeyinpd3) ... `IOCS _B_EKYINP`の動作検証(`d3`レジスタ破壊)
  * [chxdummy](docs/poc.md#chxdummy) ... ch30inst.x、chxinst.xの共存インストール機能の動作検証
  * [conctrl_so](docs/poc.md#conctrl_so) ... `DOS _CONCTRL`のスタックオーバーランの動作検証
  * [env_sbo](docs/poc.md#env_sbo) ... `DOS _GETENV`、`DOS _SETENV`のバッファオーバーフローの動作検証
  * [fatchk_bof](docs/poc.md#fatchk_bof) ... `DOS _FATCHK`のバッファオーバーフローの動作検証
  * [incdir_test](docs/poc.md#incdir_test) ... サブディレクトリ拡張時のディスク破壊の再現補助
  * [nameck_bof](docs/poc.md#nameck_bof) ... `DOS _NAMECK`のバッファオーバーフローの動作検証
  * [namests_bof](docs/poc.md#namests_bof) ... `DOS _NAMESTS`のバッファオーバーフローの動作検証
  * [ns_sbo](docs/poc.md#ns_sbo) ... `DOS _NAMESTS`の内部ルーチンのバッファオーバーフローの動作検証
  * [pathchk_bof1](docs/poc.md#pathchk_bof1) ... `DOS _EXEC (md=2;pathchk)`のバッファオーバーフローの動作検証 その1
  * [pathchk_bof2](docs/poc.md#pathchk_bof2) ... `DOS _EXEC (md=2;pathchk)`のバッファオーバーフローの動作検証 その2
  * [zerounit.sys](docs/poc.md#zerounitsys) ... ブロックデバイスのユニット数=0の動作検証
* [Process](docs/process.md)
  * [a2arg](docs/process.mad#a2arg) ... 渡されたコマンドライン引数の内容を表示
  * [a2arg_nh](docs/process.md#a2arg_nh) ... 渡されたコマンドライン引数の内容を表示(HUPAIRマークなし)
  * [bindno](docs/process.md#bindno) ... `DOS _EXEC (MD=5;bindno)`でモジュール番号を取得
  * [crampedexec](docs/process.md#crampedexec) ... 空きメモリ容量を指定してファイルを実行する
  * [dumpenv](docs/process.md#dumpenv) ... 環境変数をすべて表示
  * [dumpstupreg](docs/process.md#dumpstupreg) ... 起動時のレジスタ内容を表示
  * [entryceil](docs/process.md#entryceil) ... 上位メモリから起動する。HUPAIR準拠表示の判別コードの検証用
  * [execas](docs/process.md#execas) ... 「ファイルを別名で実行するR形式実行ファイル」を作成
  * [keepceil](docs/process.md#keepceil) ... 上位メモリに常駐する。常駐検査コードの検証用
  * [keepcmem](docs/process.md#keepcmem) ... 上位メモリからメモリを確保して常駐する。常駐検査コードの検証用
  * [lineage](docs/process.md#lineage) ... 自分自身と祖先のメモリ管理ポインタを表示
  * [loadonly](docs/process.md#loadonly) ... `DOS _EXEC (MD=3;loadonly)`で実行ファイルをロード
  * [mallocall](docs/process.md#mallocall) ... メモリブロックを可能な限り確保
  * [malloc_ba_exec](docs/process.md#malloc_ba_exec) ... `DOS _EXEC`の前後でメモリを確保
  * [openkeep](docs/process.md#openkeep) ... ファイルを開いたまま常駐終了する。`DOS _KEEPPR`の動作検証
  * [pathchk](docs/process.md#pathchk) ... `DOS _EXEC (MD=2;pathchk)`で実行ファイルを検索
  * [sysstack_exec](docs/process.md#sysstack_exec) ... システムスタックを確保してファイルを実行
* [Show Information](docs/si.md)
  * [si_acc](docs/si.md#si_acc) ... 装着されているアクセラレータの種類を表示
  * [si_emu](docs/si.md#si_emu) ... 実行中のエミュレータの種類を表示
  * [si_memory](docs/si.md#si_memory) ... メインメモリとハイメモリの情報を表示
  * [si_midi](docs/si.md#si_midi) ... MIDIボードの種類を表示
  * [si_model](docs/si.md#si_model) ... 本体の機種名を表示
  * [si_mpuclk](docs/si.md#si_mpuclk) ... MPUクロック数を表示
  * [si_pcgexp](docs/si.md#si_pcgexp) ... PCGメモリ増設(改造)の有無を表示
  * [si_phantomx](docs/si.md#si_phantomx) ... PhantomXの情報を表示
  * [si_scsiex](docs/si.md#si_scsiex) ... SCSIボードの機種名を表示
  * [si_sram](docs/si.md#si_sram) ... SRAMの容量と使用状況を表示
* [Sprite](docs/sprite.md)
  * [sp3tx0gr2](docs/sprite.md#sp3tx0gr2) ... 画面間プライオリティを特殊な値に設定。エミュレータの検証用
  * [spchecker](docs/sprite.md#spchecker) ... スプライトを市松模様に表示
  * [splimchk](docs/sprite.md#splimchk) ... スプライトの表示限界の検証用
* [Test](docs/test.md)
  * [divu10bench](docs/test.md#divu10bench) ... Divu10サブルーチンのベンチマーク
  * [divu32](docs/test.md#divu32) ... Divu32サブルーチンの動作確認用
  * [parseint](docs/test.md#parseint) ... ParseIntサブルーチンの動作確認用
  * [todecstrbench](docs/test.md#todecstrbench) ... ToDecStringサブルーチンのベンチマーク
* [Z-MUSIC v2](docs/zmsc2.md)
  * [zm2_gettrktbl](docs/zmsc2.md#zm2_gettrktbl)
    ... Z-MUSIC v2の絶対チャンネルテーブル、演奏トラックテーブルを表示
  * [zm2_mstat](docs/zmsc2.md#zm2_mstat) ... Z-MUSIC v2の演奏状態を表示
  * [zm2_oddopm](docs/zmsc2.md#zm2_oddopm)
    ... 奇数アドレスにあるZ-MUSIC v2のZMDデータをOPMデバイスに書き込む
  * [zm2_t12poc](docs/zmsc2.md#zm2_t12poc) ... ZMSC.X v2の常駐解除時のメモリ破壊の動作検証
* [Z-MUSIC v3](docs/zmsc3.md)
  * [zm3_exg_memid](docs/zmsc3.md#zm3_exg_memid) ... `ZM_EXCHANGE_MEMID`でメモリブロックの用途IDを変更
  * [zm3_free_mem2](docs/zmsc3.md#zm3_free_mem2) ... `ZM_FREE_MEM2`でメモリブロックを解放
  * [zm3_init](docs/zmsc3.md#zm3_init) ... `ZM_INIT`でZ-MUSIC v3を初期化


## 数値の指定

引数に数値を指定する場合、`$`または`0x`から始まる16進数、`%`または`0b`から始まる2進数が使えます。
これらの接頭辞がない場合は10進数になります。

数値の解釈にはFEFUNCを使わず自前で処理しています。また数値の文字列化も同様です。
このため実行の際にFLOAT\*.Xは不要です(一部、FEFUNCの呼び出しを目的としたプログラムを除く)。


## 特殊なメモリ状況を構築するプログラムについて

一般に、常駐検査を行うプログラムやプログラム本体の後にバッファを確保するプログラムでは
メモリを読み書きする前にメモリブロックの大きさを確認しなければなりません。
それを怠ると、メモリブロックが期待より小さな場合にメモリブロックの範囲外を読み書きしてしまい、
他のメモリブロックの内容の破壊、バスエラーによる停止、プログラムの暴走などの問題が生じます。

[crampedexec](docs/process.md#crampedexec)、[keepceil](docs/process.md#keepceil)、
[keepcmem](docs/process.md#keepcmem)などのコードはそのようなプログラムの動作を検証するための補助として、
意図的に「小さなメモリブロック」を作り出します。

より確実に検証するためには、メインメモリ容量を11MB以下にしてください。
メインメモリが12MBだとメモリブロックの範囲外がGVRAMになるため、
スーパーバイザモードになっているとバスエラーが発生せず読み書きできてしまうためです。


## Build

PCやネット上での取り扱いを用意にするために、src/内のファイルはUTF-8で記述されています。  
X680x0上でビルドする際には、UTF-8からShift_JISへの変換が必要です。

### 必要環境

* Human68k version 3.02
* TwentyOne +T
  * 長いファイル名を使用しているため、ファイル名を21文字認識する環境が必要です。
* [GNU make](https://github.com/kg68k/gnu-make-human68k) 3.79 human68k-1.4 以降
* [HAS060.X](http://retropc.net/x68000/software/develop/as/has060/) version 3.09+91 以降
  * 作者は[HAS060X.X](https://github.com/kg68k/has060xx)をhas060.xにリネームして使っています。
* [HLKX](https://github.com/kg68k/hlkx) 1.1.0 以降 (必須)
* gcc2
  * 一部の実行ファイルを作成するのに必要ですが、[gcc1p](https://github.com/kg68k/gcc1p)
    でも構いません(src/common.mkを適宜書き換えてください)。
* 文字コード変換ツール(src2build推奨)

### src2buildを使用する場合

必要ツール: [src2build](https://github.com/kg68k/src2build)

srcディレクトリのある場所で以下のコマンドを実行します。
```
src2build src
make -C build
```

### その他の方法

src/内のファイルを適当なツールで適宜Shift_JISに変換して別のディレクトリに保存し、
ディレクトリ内で`make`を実行してください。  
UTF-8のままでは正しくビルドできません。


## License
GNU General Public License version 3 or later.


## Author
TcbnErik / https://github.com/kg68k/xperiment68k

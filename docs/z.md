# Z

## zerounit.sys
ディスクを破壊する可能性があるため、試す場合は独立したエミュレータ環境でのみ使用して下さい。

ブロックデバイスが初期化時にユニット数=0を返してはいけないことを検証します。  
これは本来あってはならない動作であり、Human68kがDPBを65536個作成してしまいます。

リモートドライブのデバイスドライバとして作られており、CONFIG.SYSの`DEVICE =`
行で組み込むことができますが、初期化するとユニット数=0を返す以外の機能はありません。

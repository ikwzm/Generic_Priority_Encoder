Generic Priority Encoder VHDL RTL
---------------------------------

###概要###
汎用の Priority Encoder です.

Priority Encode 用の各種関数を用意しています. 
詳細は src/priority_encoder_procedures.vhd を参照してください.

論理合成可能です.

####開発環境####
以下の開発環境で合成出来ることを確認しています.

* Xilinx ISE14.5
* Altera QuartusII 13.0sp1 Web Edition(32bit)

###シミュレーション###

####他に必要なファイル####
シミュレーションをするためには次のファイルが必要です。

* 文字列操作用の各種ユーティリティ         util.vhd       (<https://github.com/ikwzm/Dummy_Plug.git>)
* 擬似乱数生成パッケージ                   mt19937ar.vhd  (<https://github.com/ikwzm/Dummy_Plug.git>)

####GHDLによるシミュレーション####
シミュレーションには GHDL (http://ghdl.free.fr/) を使いました.

ディレクトリ sim/ghdl に移動して make コマンドでシミュレーションが走ります.

もしかしたら他のシミュレーションでは走らないかもしれません。その際はご一報ください.

###ライセンス###
二条項BSDライセンス (2-clause BSD license) で公開しています.


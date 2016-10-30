# TOSAddon
Tree of Savior Addon

treasuremap
--
![alt text](http://i.imgur.com/dAkRzhk.png "Map Screenshot")
[JP]
■なにこれ
　　全体マップ上に宝箱の場所を表示するアドオンです。
■使い方
　　「_treasuremap-⛄-v1.0.1.ipf」をTree of Saviorインストールフォルダの「data」フォルダ内にコピーしてください。
 　　Tree of Saviorのキャラログイン時に、チャット欄に「TREASUREMAP loaded!」が表示されていれば導入完了です。
■補足
　　宝箱の後ろの数字は、宝箱レベルを表しています。
　　例：宝箱4→LV4宝箱の鍵が必要
　　　　宝箱1→鍵はいらない
■出来てないし、今後も未対応かも
　　ミニマップには表示されません。
　　開けたかどうかもわかりません。
　　普段は開けられず、クエスト上で開ける宝箱なのかどうかもわかりません。
■開発者向け補足
　　FPS_UPDATE時に動作するようにしています。
  　MAP_OPEN_HOOKEDにしたいところでしたが、mapfogviewerとの兼ね合いもあり、FPS_UPDATEにしました。
　　MAP_OPEN_HOOKEDで、この処理後にmapfogviewerを呼び出すようにしても良かったのですが、単体で完結したかったのでこうしてます。
  　何かいい方法あれば教えてください。
　　あと、手探りで作成したのでAPIとかどこかにあれば教えてください。

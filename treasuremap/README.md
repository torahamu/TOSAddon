# TOSAddon
Tree of Savior Addon

treasuremap
--
![alt text](http://i.imgur.com/dAkRzhk.png "Map Screenshot")

### [JP]

	■なにこれ

全体マップ上に宝箱の場所を表示するアドオンです。

ミニマップには表示されないし、開けたかどうかもわかりません。また、普段は開けられず、クエスト上で開ける宝箱なのかどうかもわかりません。

	■使い方

「_treasuremap-⛄-v1.0.1.ipf」をTree of Saviorインストールフォルダの「data」フォルダ内にコピーしてください。Tree of Saviorのキャラログイン時に、チャット欄に「TREASUREMAP loaded!」が表示されていれば導入完了です。

	■補足

宝箱の後ろの数字は、宝箱レベルを表しています。

例：宝箱4→LV4宝箱の鍵が必要

　　宝箱1→鍵はいらない

	■開発者向け補足

FPS_UPDATE時に動作するようにしています。

MAP_OPEN_HOOKEDにしたいところでしたが、mapfogviewerとの兼ね合いもあり、FPS_UPDATEにしました。

MAP_OPEN_HOOKEDで、この処理後にmapfogviewerを呼び出すようにしても良かったのですが、単体で完結したかったのでこうしてます。

何かいい方法あれば教えてください。

あと、手探りで作成したのでAPIとかどこかにあれば教えてください。

### [EN]

I'm sorry. It is a Google translation

	■ What this

It is an add-on that displays the location of the treasure chest to the entire map on.

It does not appear on the mini-map, also do not know whether or not opened. In addition, usually it is not open, do not know even whether a treasure chest open on the quest.

	■ How to use

Please copy the "_treasuremap-⛄-v1.0.1.ipf" in the "data" folder of the Tree of Savior installation folder. During the character login of Tree of Savior, is the introduction completion if "TREASUREMAP loaded!" Is displayed in the chat field.

	■ supplement

The numbers behind the treasure box, represents the treasure chest level.

Example: Treasure Chest 4 → LV4 need is key to the treasure box

Treasure Chest 1 → key is not needed

	■ Developer Supplement

FPS_UPDATE you have to work at.

Was the place you want to MAP_OPEN_HOOKED, but there is also a balance with mapfogviewer, it was to FPS_UPDATE.

In MAP_OPEN_HOOKED, it was also good so as to invoke the mapfogviewer after this process, we are doing because I wanted to complete alone.

Please tell me if there is any good way.

Then, please tell me if the API somewhere.

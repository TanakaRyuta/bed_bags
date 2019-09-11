### Cuve World(仮称)
- 探索型RPG
- 言語 SBCL

### ./source内のファイル
- キューブワールード：CuveWorld.lisp
- 画像の読み込み：loader.lisp
- プレイヤー：player.lisp
- 状態：status.lisp
- キー(標準入力)：key.lisp     
- オブジェクト：objects.lisp  
- ステージ：stage.lisp
- 光源設定：light.lisp
- カメラオブジェクト関係：camera.lisp
- その他（Path,）：others.lisp
- テキストボックス：textbox.lisp
- SDLのfont描画：ttf.lisp

### ./ttf
フォントの格納場所

### プログラムの起動方法
- emacsの起動
- ミニバッファ内にAlt+x : slimeと入力し、REPLを起動
- コンパイルさせたい箇所を指定し、Ctrl + c を二回押下
- REPL内で(main)で実行
### 環境構築
#### step1
- install emacs & sbcl
#### step2
- install quicklisp
#### step3
- qucilload libs
#### step4
- git clone our_project
#### step5
- compile & runA

# session cookieの設定について
## Railsの設定
https://qiita.com/PenPe/items/ed80268207cdf2739cdf


## sessionとcookieの違い
https://zenn.dev/mambacom/articles/3dcb1384d147c2
- sessionはサーバーに保存。cookieはクライアントに保存される

## コミット規約
https://zenn.dev/wakamsha/articles/about-conventional-commits

## 社員番号のデータ型
https://chatgpt.com/s/t_686748ca5cb08191a2ca5c9385e87049

## APIモードでのCSRF対策（）
https://chatgpt.com/s/t_686b189098088191b54f8050a283b872
- APIモードでは`protect_from_forgery`の記述必須（Cookie認証を使用する場合）
- Cookie認証の方がJWTより実装が早い
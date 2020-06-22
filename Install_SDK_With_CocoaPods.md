# SDKをCocoaPodsでインストール

[CocoaPods](#https://guides.cocoapods.org/using/getting-started)を使って簡単にSDKをインストールすることができます。
詳しくは[公式のドキュメント](#https://guides.cocoapods.org/using/using-cocoapods)を参考にしてください。

## CocoaPodsのインストール
- CocoaPodsをインストール
```
$ sudo gem install cocoapods
```
- CocoaPodsのセットアップ
```
$ pod setup
```

## プロジェクトにライブラリをインストール
### Podfileの生成
プロジェクト([プロジェクト名.xcodeproj])のあるディレクトリで以下のコマンドを実行します。
```
$ pod init
```
このコマンドでPodfileが生成されます。  
### Podfileを編集
  - 最新のSDKをインストールする場合(VAMPのインストール)
  ```
  pod 'VAMP-SDK'
  ```

  - バージョンを指定してインストールする場合
  ```
  pod 'VAMP-SDK', "[VERSION]"
  ```
  
  v4.0.0の場合
  ```
  pod 'VAMP-SDK', "4.0.0"
  ```

### ライブラリのインストール
  - 初回のインストール
    ```
    $ pod install
    ```
  
  - Podsファイルの更新(ライブラリの追加、更新)
    ```
    $ pod update
    ```

### 動作確認
podのコマンドを実行したディレクトリ配下に[プロジェクト名].xcworkspaceというファイルが生成されます。  
[プロジェクト名].xcodeprojを開くのではなく、[プロジェクト名].xcworkspaceというファイルを開いて実行します。  

### 必要なライブラリをインストール
VAMPと必要なライブラリのアダプターをインストールする必要があります。(アダプターをインストールするとSDKもインストールされます)  
各アドネットワークSDKに対応するアダプターは以下のようになります。

- AdMob
  - VAMPAdMobAdapter
- AppLovin
  - VAMPAppLovinAdapter
- Facebook Audience Network
  - VAMPFANAdapter
- maio
  - VAMPMaioAdapter
- nend
  - VAMPNendAdapter
- Tapjoy
  - VAMPTapjoyAdapter
- UnityAds
  - VAMPUnityAdsAdapter
- Pangle(TikTok Audience Network)
  - VAMPPangleAdapter
- FIVE
  - VAMPFIVEAdapter

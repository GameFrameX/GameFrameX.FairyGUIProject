<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# GameFrameX FairyGUI Project

[![License](https://img.shields.io/github/license/GameFrameX/GameFrameX.FairyGUIProject)](LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/GameFrameX.FairyGUIProject)](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)
[![Documentation](https://img.shields.io/badge/Documentation-doc.alianblank.com-blue)](https://gameframex.doc.alianblank.com)

インディゲーム開発者向けオールインワンソリューション · インディ開発者の夢を支援

<br />

[ドキュメント](https://gameframex.doc.alianblank.com) · [クイックスタート](#クイックスタート) · QQグループ: 467608841 / 233840761

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | **日本語** | [한국어](README.ko.md)

</div>

## プロジェクト概要

GameFrameX FairyGUI Project は、GameFrameX Unity クライアントのすべての UI パッケージを管理する FairyGUI エディタ用ソースプロジェクトです。FairyGUI エディタで編集し、`.bytes` アセットバンドルと生成されたバインディングコードとして同級の Unity プロジェクトに出力します。

- デザイン解像度：1080 x 2160（縦長）、スケールモード `MatchWidthOrHeight`。
- プロジェクトファイル：`Game.fairy`（FairyGUI エディタ、Unity ターゲット、バージョン 5.0）。

### 機能概要

- ゲームフロー全体をカバーする 9 個の UI パッケージ：
  - `UILauncher` - スプラッシュ / 起動画面
  - `UILoading` - ローディングシーン
  - `UILogin` - ログイン画面
  - `UIMain` - メイン HUD
  - `UIBag` - インベントリ
  - `UIRoom` - ルーム / ロビー
  - `UIPlayer` - プレイヤーパネル
  - `UICommon` - 共通コンポーネント
  - `UICommonAvatar` - 共通アバター
- 公開用の 3 つのパッケージグループ：`UI`、`Res`、`Def`（`settings/PackageGroup.json` 参照）。
- ワンクリック公開：`.bytes` バンドルを `../Unity/Assets/Bundles/UI` へ、バインディングコードを `../Unity/Assets/Hotfix/UI/FairyGUI/` へ生成（メンバープレフィックス `m_`、名前で取得）。
- 共通デザイントークン：カラースキーム、フォントサイズ、デフォルトフォント、縦スクロールバー（`settings/Common.json`）。
- モバイル向けアトラス設定：2048 上限、ページング、2 のべき乗、回転許可、画像トリム（`settings/Publish.json`）。

## クイックスタート

前提条件：FairyGUI エディタ 5.0 以上（本プロジェクトの作成バージョン）。

1. FairyGUI エディタで `Game.fairy` を開く。
2. `assets/` 配下の UI パッケージを参照・編集する。
3. エディタの公開コマンドで、`.bytes` バンドルとバインディングコードを同級の Unity プロジェクトに出力する。

### インストール

本プロジェクトは FairyGUI エディタ用ソースプロジェクトであり、Unity UPM パッケージではないため、Unity Package Manager ではなくクローンで導入します。

1. リポジトリをクローン：
   ```bash
   git clone git@github.com:GameFrameX/GameFrameX.FairyGUIProject.git
   ```
2. 設定された公開パスが解決されるよう、Unity プロジェクトと同級に配置します：
   ```
   <workspace>/
   ├── GameFrameX.FairyGUIProject/   <- 本リポジトリ（Game.fairy を含む）
   └── Unity/                         <- Unity プロジェクト（Assets/Bundles/UI を受け取る）
   ```
   公開先：バンドルは `../Unity/Assets/Bundles/UI`、生成コードは `../Unity/Assets/Hotfix/UI/FairyGUI/`（`settings/Publish.json` 参照）。
3. FairyGUI エディタで `Game.fairy` を開いて公開する。

## 使用例

`assets/` 配下のパッケージ構成：

| パッケージ | 用途 |
|---------|---------|
| `UILauncher` | スプラッシュ / 起動画面 |
| `UILoading` | ローディングシーン |
| `UILogin` | ログイン画面 |
| `UIMain` | メイン HUD |
| `UIBag` | インベントリ |
| `UIRoom` | ルーム / ロビーパネル |
| `UIPlayer` | プレイヤーパネル |
| `UICommon` | 共通コンポーネント |
| `UICommonAvatar` | 共通アバター |

公開成果物（同級の Unity プロジェクトが消費）：

```
../Unity/Assets/Bundles/UI/*.bytes      # UI アセットバンドル
../Unity/Assets/Hotfix/UI/FairyGUI/     # 生成されたバインディングコード（m_ プレフィックス、名前で取得）
```

## コード生成プラグインのルール

公開ステップはバンドル済みのコード生成プラグイン `plugins/gencode/`（`package.json` → `main.lua` → `GenCode_CSharp.lua`）を実行します。各パッケージの「エクスポート」指定コンポーネントをスキャンし、C# バインディングコードを同級の Unity プロジェクトへ生成します。以下のルールは**公開時に強制検証**され、いずれかを満たさないと公開がエラーで中断します。

> プラグイン入口：`main.lua` の `onPublish`。エクスポートパス下に `{パッケージ名}` フォルダを作成し、「コード生成」が有効なときのみ実行して FairyGUI のデフォルト出力を抑制します。

### 命名（強制）

| 対象 | ルール | 例 |
|------|--------|------|
| パッケージ名 | `UI` 先頭、英字のみ（パスカルケース） | `UILogin` ✅ · `Login` / `UI_Login` / `UI1` ❌ |
| コンポーネント名 | `UI` 先頭、英字のみ | `UILoginPanel` ✅ |
| コンポーネントの接頭辞 | 自パッケージ名で始まること | `UILogin` 内：`UILoginPanel` ✅ · `UIMainPanel` ❌ |
| メンバー名 | 全小文字（小文字 + アンダースコア）。ただし Controller と予約名 `closeButton`、`dragArea`、`contentArea` は除外 | `btn_start` ✅ · `BtnStart` ❌ |

### サイズ（強制）

- コンポーネントの幅**と**高さはともに**偶数**であること。
- リソースを持つ各メンバー：幅**と**高さはともに**偶数**であること。

### コード生成の挙動

- エディタで「エクスポート」指定したコンポーネントのみ、静的ファクトリメソッド `CreateInstance()` と `CreateInstanceAsync(Entity)`（非同期は `UniTask` を返す）が生成されます。
- メンバーは group に応じてバインドされます：
  - オブジェクト → `com.GetChild("name")`。型がカスタムコンポーネントなら `Xxx.Create(...)` でラップ。
  - Controller → `com.GetController("name")`。
  - Transition → `com.GetTransition("name")`。
- 別パッケージ参照：メンバーが別パッケージのリソースを指し、かつ型がカスタムコンポーネントの場合、生成される型名はその別パッケージのリソース名に置き換えられます。
- 型名に `Scene` を含むメンバーは、`Dispose()` で自動的に `Dispose()` され null 代入されます。
- 名前空間：デフォルトは `Hotfix.UI`。エクスポートパスに `Unity/Assets/Scripts` が含まれる場合は `Unity.Startup` になります。

### 出力レイアウト

```
{エクスポートコードパス}/{パッケージ名}/Components/
├── {コンポーネント名}.cs   # エクスポートコンポーネントごとに1つ（partial sealed class : FUI）
└── Package{パッケージ名}.cs  # パッケージ名定数を持つ FUIPackage 静的クラス
```

### コンパイルガードと依存

- 生成コードはすべて `#if ENABLE_UI_FAIRYGUI` で囲まれます。
- 参照アセンブリ：FairyGUI、UniTask（`Cysharp.Threading.Tasks`）、GameFrameX（`Entity.Runtime`、`UI.Runtime`、`UI.FairyGUI.Runtime`、`Runtime`）。

## 依存関係

- FairyGUI エディタ 5.0 以上（作成ツール）。
- 公開された `.bytes` バンドルと生成されたバインディングコードを消費する同級の Unity プロジェクト。

## ドキュメントとリソース

- 公式ドキュメント：https://gameframex.doc.alianblank.com
- GitHub Releases：https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases
- FairyGUI 公式サイト：https://www.fairygui.com/

## コミュニティとサポート

- QQ グループ：467608841 / 233840761

## 変更履歴

変更履歴の詳細は [GitHub Releases](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases) を参照してください。

初回リリースには、FairyGUI プロジェクトのスケルトンと最初の UI アセットパッケージ群が含まれます。

## ライセンス

詳しくは [LICENSE.md](LICENSE.md) をご参照ください。

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

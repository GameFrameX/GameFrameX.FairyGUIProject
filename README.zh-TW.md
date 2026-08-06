<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# GameFrameX FairyGUI Project

[![License](https://img.shields.io/github/license/GameFrameX/GameFrameX.FairyGUIProject)](LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/GameFrameX.FairyGUIProject)](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)
[![Documentation](https://img.shields.io/badge/Documentation-doc.alianblank.com-blue)](https://gameframex.doc.alianblank.com)

獨立遊戲前後端一體化解決方案 · 獨立遊戲開發者的圓夢大使

<br />

[文檔](https://gameframex.doc.alianblank.com) · [快速開始](#快速開始) · QQ群: 467608841 / 233840761

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | **繁體中文** | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>

## 項目簡介

GameFrameX FairyGUI Project 是託管 GameFrameX Unity 客戶端全部 UI 包的 FairyGUI 編輯器源工程。在 FairyGUI 編輯器中編輯，發布為 `.bytes` 資產包並連同生成的綁定代碼一起輸出到同級 Unity 工程。

- 設計解析度：1080 x 2160（直屏），縮放模式 `MatchWidthOrHeight`。
- 工程檔案：`Game.fairy`（FairyGUI 編輯器，Unity 目標，版本 5.0）。

### 功能特性

- 九個 UI 包，覆蓋完整遊戲流程：
  - `UILauncher` - 啟動閃屏
  - `UILoading` - 載入場景
  - `UILogin` - 登入介面
  - `UIMain` - 主介面 HUD
  - `UIBag` - 背包
  - `UIRoom` - 房間 / 大廳
  - `UIPlayer` - 玩家面板
  - `UICommon` - 通用組件
  - `UICommonAvatar` - 通用頭像
- 三個發布分包分組：`UI`、`Res`、`Def`（見 `settings/PackageGroup.json`）。
- 一鍵發布：`.bytes` 資產包輸出到 `../Unity/Assets/Bundles/UI`，綁定代碼生成到 `../Unity/Assets/Hotfix/UI/FairyGUI/`（成員前綴 `m_`，按名稱取得）。
- 統一設計令牌：配色方案、字號、預設字體與縱向滾動條（`settings/Common.json`）。
- 面向行動端的圖集設定：2048 上限、分頁、2 的冪、允許旋轉、裁剪圖像（`settings/Publish.json`）。

## 快速開始

前置條件：FairyGUI 編輯器 5.0 及以上（與本工程的創作版本一致）。

1. 在 FairyGUI 編輯器中開啟 `Game.fairy`。
2. 瀏覽並編輯 `assets/` 下的 UI 包。
3. 使用編輯器的發布命令，將 `.bytes` 資產包與綁定代碼輸出到同級 Unity 工程。

### 安裝

本工程是 FairyGUI 編輯器源工程，不是 Unity UPM 包，因此透過克隆方式接入，而非透過 Unity Package Manager。

1. 克隆倉庫：
   ```bash
   git clone git@github.com:GameFrameX/GameFrameX.FairyGUIProject.git
   ```
2. 將其放置為 Unity 工程的同級目錄，使配置的發布路徑生效：
   ```
   <workspace>/
   ├── GameFrameX.FairyGUIProject/   <- 本倉庫（含 Game.fairy）
   └── Unity/                         <- Unity 工程（接收 Assets/Bundles/UI）
   ```
   發布目標：資產包到 `../Unity/Assets/Bundles/UI`，生成代碼到 `../Unity/Assets/Hotfix/UI/FairyGUI/`（見 `settings/Publish.json`）。
3. 在 FairyGUI 編輯器中開啟 `Game.fairy` 並發布。

## 使用範例

`assets/` 下的分包布局：

| 分包 | 用途 |
|---------|---------|
| `UILauncher` | 啟動閃屏 |
| `UILoading` | 載入場景 |
| `UILogin` | 登入介面 |
| `UIMain` | 主介面 HUD |
| `UIBag` | 背包 |
| `UIRoom` | 房間 / 大廳面板 |
| `UIPlayer` | 玩家面板 |
| `UICommon` | 通用組件 |
| `UICommonAvatar` | 通用頭像 |

發布產物（由同級 Unity 工程消費）：

```
../Unity/Assets/Bundles/UI/*.bytes      # UI 資產包
../Unity/Assets/Hotfix/UI/FairyGUI/     # 生成的綁定代碼（m_ 前綴，按名稱取得）
```

## 依賴

- FairyGUI 編輯器 >= 5.0（創作工具）。
- 同級 Unity 工程，用於消費發布的 `.bytes` 資產包與生成的綁定代碼。

## 文檔與資源

- 官方文檔：https://gameframex.doc.alianblank.com
- GitHub Releases：https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases
- FairyGUI 官網：https://www.fairygui.com/

## 社區與支援

- QQ 群：467608841 / 233840761

## 更新日誌

完整更新日誌見 [GitHub Releases](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)。

首發版本包含 FairyGUI 工程骨架與首批 UI 資產包。

## 開源協議

詳見 [LICENSE.md](LICENSE.md) 檔案。

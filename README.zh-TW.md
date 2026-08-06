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

## 代碼生成插件規則

發布步驟會執行內建的代碼生成插件 `plugins/gencode/`（`package.json` → `main.lua` → `GenCode_CSharp.lua`）。它會掃描每個包中標記為導出的組件，並將 C# 綁定代碼生成到同級 Unity 工程。以下規則**在發布時強制校驗**——違反任意一條都會中斷發布並報錯。

> 插件入口：`main.lua` 中的 `onPublish`。它會在導出路徑下建立 `{包名}` 子目錄，僅當勾選「生成代碼」時執行，並遮蔽 FairyGUI 的預設代碼輸出。

### 命名（強制）

| 對象 | 規則 | 範例 |
|------|------|------|
| 包名 | 以 `UI` 開頭，僅含字母（大寫駝峰） | `UILogin` ✅ · `Login` / `UI_Login` / `UI1` ❌ |
| 組件名 | 以 `UI` 開頭，僅含字母 | `UILoginPanel` ✅ |
| 組件名前綴 | 必須以其所屬包名開頭 | 在 `UILogin` 中：`UILoginPanel` ✅ · `UIMainPanel` ❌ |
| 成員名 | 全小寫（小寫字母 + 底線）。豁免：Controller，以及保留名 `closeButton`、`dragArea`、`contentArea` | `btn_start` ✅ · `BtnStart` ❌ |

### 尺寸（強制）

- 組件的寬**與**高都必須為**偶數**。
- 每個有資源的成員：寬**與**高都必須為**偶數**。

### 代碼生成行為

- 只有在編輯器中標記為「導出」的組件，才會生成靜態工廠方法 `CreateInstance()` 與 `CreateInstanceAsync(Entity)`（非同步回傳 `UniTask`）。
- 成員按 group 綁定：
  - 普通物件 → `com.GetChild("name")`；若類型為自訂組件，則以 `Xxx.Create(...)` 包裹。
  - Controller → `com.GetController("name")`。
  - Transition → `com.GetTransition("name")`。
- 跨包參考：若成員指向其他包的資源，且類型為自訂組件，生成的類型名會替換為該跨包資源名。
- 類型名包含 `Scene` 的成員，會在 `Dispose()` 中自動呼叫其 `Dispose()` 並置空。
- 命名空間：預設 `Hotfix.UI`；當導出路徑包含 `Unity/Assets/Scripts` 時改為 `Unity.Startup`。

### 輸出布局

```
{導出代碼路徑}/{包名}/Components/
├── {組件名}.cs       # 每個導出組件一個（partial sealed class : FUI）
└── Package{包名}.cs  # FUIPackage 靜態類，含包名常數
```

### 編譯巨集與依賴

- 所有生成代碼都以 `#if ENABLE_UI_FAIRYGUI` 包裹。
- 參考組件：FairyGUI、UniTask（`Cysharp.Threading.Tasks`）、GameFrameX（`Entity.Runtime`、`UI.Runtime`、`UI.FairyGUI.Runtime`、`Runtime`）。

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

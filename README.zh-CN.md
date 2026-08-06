<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# GameFrameX FairyGUI Project

[![License](https://img.shields.io/github/license/GameFrameX/GameFrameX.FairyGUIProject)](LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/GameFrameX.FairyGUIProject)](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)
[![Documentation](https://img.shields.io/badge/Documentation-doc.alianblank.com-blue)](https://gameframex.doc.alianblank.com)

独立游戏前后端一体化解决方案 · 独立游戏开发者的圆梦大使

<br />

[文档](https://gameframex.doc.alianblank.com) · [快速开始](#快速开始) · QQ群: 467608841 / 233840761

<br />

[English](README.md) | **简体中文** | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>

## 项目简介

GameFrameX FairyGUI Project 是托管 GameFrameX Unity 客户端全部 UI 包的 FairyGUI 编辑器源工程。在 FairyGUI 编辑器中编辑，发布为 `.bytes` 资产包并连同生成的绑定代码一起输出到同级 Unity 工程。

- 设计分辨率：1080 x 2160（竖屏），缩放模式 `MatchWidthOrHeight`。
- 工程文件：`Game.fairy`（FairyGUI 编辑器，Unity 目标，版本 5.0）。

### 功能特性

- 九个 UI 包，覆盖完整游戏流程：
  - `UILauncher` - 启动闪屏
  - `UILoading` - 加载场景
  - `UILogin` - 登录界面
  - `UIMain` - 主界面 HUD
  - `UIBag` - 背包
  - `UIRoom` - 房间 / 大厅
  - `UIPlayer` - 玩家面板
  - `UICommon` - 通用组件
  - `UICommonAvatar` - 通用头像
- 三个发布分包分组：`UI`、`Res`、`Def`（见 `settings/PackageGroup.json`）。
- 一键发布：`.bytes` 资产包输出到 `../Unity/Assets/Bundles/UI`，绑定代码生成到 `../Unity/Assets/Hotfix/UI/FairyGUI/`（成员前缀 `m_`，按名称获取）。
- 统一设计令牌：配色方案、字号、默认字体与竖向滚动条（`settings/Common.json`）。
- 面向移动端的图集设置：2048 上限、分页、2 的幂、允许旋转、裁剪图像（`settings/Publish.json`）。

## 快速开始

前置条件：FairyGUI 编辑器 5.0 及以上（与本工程的创作版本一致）。

1. 在 FairyGUI 编辑器中打开 `Game.fairy`。
2. 浏览并编辑 `assets/` 下的 UI 包。
3. 使用编辑器的发布命令，将 `.bytes` 资产包与绑定代码输出到同级 Unity 工程。

### 安装

本工程是 FairyGUI 编辑器源工程，不是 Unity UPM 包，因此通过克隆方式接入，而非通过 Unity Package Manager。

1. 克隆仓库：
   ```bash
   git clone git@github.com:GameFrameX/GameFrameX.FairyGUIProject.git
   ```
2. 将其放置为 Unity 工程的同级目录，使配置的发布路径生效：
   ```
   <workspace>/
   ├── GameFrameX.FairyGUIProject/   <- 本仓库（含 Game.fairy）
   └── Unity/                         <- Unity 工程（接收 Assets/Bundles/UI）
   ```
   发布目标：资产包到 `../Unity/Assets/Bundles/UI`，生成代码到 `../Unity/Assets/Hotfix/UI/FairyGUI/`（见 `settings/Publish.json`）。
3. 在 FairyGUI 编辑器中打开 `Game.fairy` 并发布。

## 使用示例

`assets/` 下的分包布局：

| 分包 | 用途 |
|---------|---------|
| `UILauncher` | 启动闪屏 |
| `UILoading` | 加载场景 |
| `UILogin` | 登录界面 |
| `UIMain` | 主界面 HUD |
| `UIBag` | 背包 |
| `UIRoom` | 房间 / 大厅面板 |
| `UIPlayer` | 玩家面板 |
| `UICommon` | 通用组件 |
| `UICommonAvatar` | 通用头像 |

发布产物（由同级 Unity 工程消费）：

```
../Unity/Assets/Bundles/UI/*.bytes      # UI 资产包
../Unity/Assets/Hotfix/UI/FairyGUI/     # 生成的绑定代码（m_ 前缀，按名称获取）
```

## 依赖

- FairyGUI 编辑器 >= 5.0（创作工具）。
- 同级 Unity 工程，用于消费发布的 `.bytes` 资产包与生成的绑定代码。

## 文档与资源

- 官方文档：https://gameframex.doc.alianblank.com
- GitHub Releases：https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases
- FairyGUI 官网：https://www.fairygui.com/

## 社区与支持

- QQ 群：467608841 / 233840761

## 更新日志

完整更新日志见 [GitHub Releases](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)。

首发版本包含 FairyGUI 工程骨架与首批 UI 资产包。

## 开源协议

详见 [LICENSE.md](LICENSE.md) 文件。

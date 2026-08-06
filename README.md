<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# GameFrameX FairyGUI Project

[![License](https://img.shields.io/github/license/GameFrameX/GameFrameX.FairyGUIProject)](LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/GameFrameX.FairyGUIProject)](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)
[![Documentation](https://img.shields.io/badge/Documentation-doc.alianblank.com-blue)](https://gameframex.doc.alianblank.com)

All-in-One Solution for Indie Game Development · Empowering Indie Developers' Dreams

<br />

[Documentation](https://gameframex.doc.alianblank.com) · [Quick Start](#quick-start) · QQ Group: 467608841 / 233840761

<br />

**English** | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

</div>

## Project Overview

GameFrameX FairyGUI Project is the FairyGUI editor source project that owns every UI package for the GameFrameX Unity client. It is authored in the FairyGUI editor and published as `.bytes` asset bundles together with generated binding code into the sibling Unity project.

- Design resolution: 1080 x 2160 (portrait), `MatchWidthOrHeight` scaling.
- Project file: `Game.fairy` (FairyGUI editor, Unity target, version 5.0).

### Features

- Nine UI packages covering the full game flow:
  - `UILauncher` - splash / launch screen
  - `UILoading` - loading scene
  - `UILogin` - login screen
  - `UIMain` - main HUD
  - `UIBag` - inventory
  - `UIRoom` - room / lobby
  - `UIPlayer` - player panel
  - `UICommon` - shared components
  - `UICommonAvatar` - shared avatars
- Three package groups for publishing: `UI`, `Res`, `Def` (see `settings/PackageGroup.json`).
- One-click publish: `.bytes` bundles to `../Unity/Assets/Bundles/UI`, generated binding code to `../Unity/Assets/Hotfix/UI/FairyGUI/` (member prefix `m_`, get-by-name).
- Shared design tokens: color scheme, font sizes, default font and vertical scrollbar (`settings/Common.json`).
- Atlas settings tuned for mobile: 2048 max, paging, power-of-two, allow rotation, trim images (`settings/Publish.json`).

## Quick Start

Prerequisites: FairyGUI editor 5.0 or newer (the version this project was authored with).

1. Open `Game.fairy` in the FairyGUI editor.
2. Browse and edit the UI packages under `assets/`.
3. Use the editor's publish command to emit `.bytes` bundles and binding code into the sibling Unity project.

### Installation

This is a FairyGUI editor source project, not a Unity UPM package, so it is set up by cloning rather than through the Unity Package Manager.

1. Clone the repository:
   ```bash
   git clone git@github.com:GameFrameX/GameFrameX.FairyGUIProject.git
   ```
2. Place it as a sibling of your Unity project so that the configured publish paths resolve:
   ```
   <workspace>/
   ├── GameFrameX.FairyGUIProject/   <- this repo (contains Game.fairy)
   └── Unity/                         <- Unity project (receives Assets/Bundles/UI)
   ```
   The publish targets are `../Unity/Assets/Bundles/UI` for bundles and `../Unity/Assets/Hotfix/UI/FairyGUI/` for generated code (see `settings/Publish.json`).
3. Open `Game.fairy` in the FairyGUI editor and publish.

## Usage Examples

Package layout under `assets/`:

| Package | Purpose |
|---------|---------|
| `UILauncher` | Splash / launch screen |
| `UILoading` | Loading scene |
| `UILogin` | Login screen |
| `UIMain` | Main HUD |
| `UIBag` | Inventory |
| `UIRoom` | Room / lobby panel |
| `UIPlayer` | Player panel |
| `UICommon` | Shared components |
| `UICommonAvatar` | Shared avatars |

Publish output (consumed by the sibling Unity project):

```
../Unity/Assets/Bundles/UI/*.bytes      # UI asset bundles
../Unity/Assets/Hotfix/UI/FairyGUI/     # generated binding code (m_ prefix, get-by-name)
```

## Dependencies

- FairyGUI editor >= 5.0 (authoring tool).
- A sibling Unity project that consumes the published `.bytes` bundles and generated binding code.

## Documentation & Resources

- Official Documentation: https://gameframex.doc.alianblank.com
- GitHub Releases: https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases
- FairyGUI Official Site: https://www.fairygui.com/

## Community & Support

- QQ Groups: 467608841 / 233840761

## Changelog

See [GitHub Releases](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases) for the full changelog.

The initial release ships the FairyGUI project skeleton together with the first batch of UI asset packages.

## License

See [LICENSE.md](LICENSE.md) for license information.

<div align="center">

<img src="https://download.alianblank.com/gameframex/gameframex_logo_320.png" alt="Game Frame X Logo" width="160" />

# GameFrameX FairyGUI Project

[![License](https://img.shields.io/github/license/GameFrameX/GameFrameX.FairyGUIProject)](LICENSE.md)
[![Version](https://img.shields.io/github/v/release/GameFrameX/GameFrameX.FairyGUIProject)](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)
[![Documentation](https://img.shields.io/badge/Documentation-doc.alianblank.com-blue)](https://gameframex.doc.alianblank.com)

인디 게임 개발자를 위한 올인원 솔루션 · 인디 개발자의 꿈을 실현

<br />

[문서](https://gameframex.doc.alianblank.com) · [빠른 시작](#빠른-시작) · QQ 그룹: 467608841 / 233840761

<br />

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | **한국어**

</div>

## 프로젝트 개요

GameFrameX FairyGUI Project는 GameFrameX Unity 클라이언트의 모든 UI 패키지를 관리하는 FairyGUI 에디터 소스 프로젝트입니다. FairyGUI 에디터에서 편집하며, `.bytes` 에셋 번들과 생성된 바인딩 코드로 변환하여 형제 Unity 프로젝트로 출력합니다.

- 디자인 해상도: 1080 x 2160(세로형), 스케일 모드 `MatchWidthOrHeight`.
- 프로젝트 파일: `Game.fairy`(FairyGUI 에디터, Unity 타깃, 버전 5.0).

### 기능

- 게임 플로우 전체를 아우르는 9개의 UI 패키지:
  - `UILauncher` - 스플래시 / 실행 화면
  - `UILoading` - 로딩 씬
  - `UILogin` - 로그인 화면
  - `UIMain` - 메인 HUD
  - `UIBag` - 인벤토리
  - `UIRoom` - 룸 / 로비
  - `UIPlayer` - 플레이어 패널
  - `UICommon` - 공통 컴포넌트
  - `UICommonAvatar` - 공통 아바타
- 퍼블리시용 패키지 그룹 3개: `UI`, `Res`, `Def`(`settings/PackageGroup.json` 참조).
- 원클릭 퍼블리시: `.bytes` 번들은 `../Unity/Assets/Bundles/UI`로, 바인딩 코드는 `../Unity/Assets/Hotfix/UI/FairyGUI/`로 생성(멤버 접두어 `m_`, 이름으로 가져오기).
- 공통 디자인 토큰: 컬러 스킴, 글꼴 크기, 기본 글꼴, 세로 스크롤바(`settings/Common.json`).
- 모바일 최적화 아틀라스 설정: 2048 상한, 페이징, 2의 거듭제곱, 회전 허용, 이미지 트림(`settings/Publish.json`).

## 빠른 시작

전제 조건: FairyGUI 에디터 5.0 이상(본 프로젝트의 제작 버전).

1. FairyGUI 에디터에서 `Game.fairy`를 엽니다.
2. `assets/` 하위의 UI 패키지를 탐색하고 편집합니다.
3. 에디터의 퍼블리시 명령으로 `.bytes` 번들과 바인딩 코드를 형제 Unity 프로젝트로 출력합니다.

### 설치

본 프로젝트는 FairyGUI 에디터 소스 프로젝트이며 Unity UPM 패키지가 아니므로, Unity Package Manager가 아닌 클론으로 도입합니다.

1. 저장소를 클론합니다:
   ```bash
   git clone git@github.com:GameFrameX/GameFrameX.FairyGUIProject.git
   ```
2. 설정된 퍼블리시 경로가 해석되도록 Unity 프로젝트와 형제로 배치합니다:
   ```
   <workspace>/
   ├── GameFrameX.FairyGUIProject/   <- 본 저장소(Game.fairy 포함)
   └── Unity/                         <- Unity 프로젝트(Assets/Bundles/UI 수신)
   ```
   퍼블리시 대상: 번들은 `../Unity/Assets/Bundles/UI`, 생성 코드는 `../Unity/Assets/Hotfix/UI/FairyGUI/`(`settings/Publish.json` 참조).
3. FairyGUI 에디터에서 `Game.fairy`를 열고 퍼블리시합니다.

## 사용 예시

`assets/` 하위 패키지 구성:

| 패키지 | 용도 |
|---------|---------|
| `UILauncher` | 스플래시 / 실행 화면 |
| `UILoading` | 로딩 씬 |
| `UILogin` | 로그인 화면 |
| `UIMain` | 메인 HUD |
| `UIBag` | 인벤토리 |
| `UIRoom` | 룸 / 로비 패널 |
| `UIPlayer` | 플레이어 패널 |
| `UICommon` | 공통 컴포넌트 |
| `UICommonAvatar` | 공통 아바타 |

퍼블리시 결과물(형제 Unity 프로젝트가 소비):

```
../Unity/Assets/Bundles/UI/*.bytes      # UI 에셋 번들
../Unity/Assets/Hotfix/UI/FairyGUI/     # 생성된 바인딩 코드(m_ 접두어, 이름으로 가져오기)
```

## 의존성

- FairyGUI 에디터 5.0 이상(제작 도구).
- 퍼블리시된 `.bytes` 번들과 생성된 바인딩 코드를 소비하는 형제 Unity 프로젝트.

## 문서 및 자료

- 공식 문서: https://gameframex.doc.alianblank.com
- GitHub Releases: https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases
- FairyGUI 공식 사이트: https://www.fairygui.com/

## 커뮤니티 및 지원

- QQ 그룹: 467608841 / 233840761

## 변경 로그

전체 변경 로그는 [GitHub Releases](https://github.com/GameFrameX/GameFrameX.FairyGUIProject/releases)를 참조하세요.

최초 릴리스에는 FairyGUI 프로젝트 스켈레톤과 첫 UI 에셋 패키지 묶음이 포함되어 있습니다.

## 라이선스

자세한 내용은 [LICENSE.md](LICENSE.md) 파일을 참조하세요.

# Bloom_iOS
# 🌸 Bloom

> **키링 투두 앱** — 매일 하나씩, 꽃잎이 피어납니다.

물리적인 키링에 달린 7개의 버튼을 각각의 루틴에 연결하고, 버튼을 누르면 앱에서 자동으로 완료 체크가 됩니다. 모든 루틴을 마치면 화면 속 꽃이 활짝 피어나요.

---

## 📱 스크린샷 구조

| 홈 | 매핑 | 기록 | 통계 |
|:---:|:---:|:---:|:---:|
| 꽃 인터랙션 | 버튼 설정 | 스트릭 & 달력 | 주간/월간 차트 |

---

## ✨ 주요 기능

### 🌺 홈 탭 — 오늘의 꽃
- 7개의 꽃잎이 각각 하나의 루틴을 나타냄
- 꽃잎을 탭하면 완료/미완료 토글 (물리 키링 버튼과 연동)
- 완료된 꽃잎은 골드 색상으로 빛나며 중앙 센터가 점등
- 진행률 바와 연속 달성 스트릭을 화면 하단에 표시

### 🔗 매핑 탭 — 버튼 설정
- 7개의 슬롯에 각각 이름·아이콘·색상 자유 설정
- SF Symbols 기반 아이콘 15종 팔레트 제공
- 8가지 브랜드 컬러 중 선택
- 인라인 편집 패널로 즉각 저장

### 📋 기록 탭 — 나의 히스토리
- **연속 기록 카드** — 며칠 연속 모두 달성했는지 스트릭 수치 표시
- **최근 30일 도트 그리드** — 달성률에 따라 셀 색상이 진해지는 히트맵
- **오늘 완료 카드** — 각 루틴별 완료/미완료 상태 한눈에 확인
- **이번 주 리뷰 버튼** — 주간 성과를 요약한 바텀 시트 열기
- **하루 마무리** — 오늘 기록을 저장하고 내일을 위해 초기화

### 📊 통계 탭 — 성과 분석
- **이번 주 달성률** — 요일별 바 차트
- **이번 달 달성률** — 최근 30일 기준 퍼센트 표시
- **루틴 순위** — 전체 기간 동안 가장 많이 완료한 루틴 금/은/동 메달 표시

### 📅 주간 리뷰 시트 (WeeklyReviewSheet)
- 다크 테마 바텀 시트로 등장
- 꽃잎 7개가 이번 주 요일별 달성률을 시각화
- 달성률 · 완벽한 날 수 · 총 완료 수 3종 스탯 카드
- 이번 주 베스트 루틴 하이라이트
- 달성률에 따른 맞춤 응원 메시지

---

## 🗂️ 프로젝트 구조

```
Bloom/
├── BloomApp.swift              # 앱 진입점, 라이트 모드 고정
├── Models/
│   ├── AppData.swift           # 핵심 데이터 모델 (ObservableObject)
│   └── Mapping.swift           # 버튼-루틴 매핑 구조체
├── Theme/
│   └── BloomTheme.swift        # 컬러 팔레트, 폰트, 카드 스타일
└── Views/
    ├── ContentView.swift        # 탭 네비게이션, 온보딩/리뷰 오버레이
    ├── HomeView.swift           # 홈 탭 — 꽃 인터랙션 화면
    ├── MapView.swift            # 매핑 탭 — 버튼 설정 화면
    ├── LogView.swift            # 기록 탭 — 히스토리 화면
    ├── StatView.swift           # 통계 탭 — 차트 화면
    ├── OnboardingView.swift     # 최초 실행 온보딩 (4슬라이드)
    ├── WeeklyReviewSheet.swift  # 주간 리뷰 바텀 시트
    └── Components/
        └── StoryFlowerView.swift # 홈 탭 꽃 SVG 컴포넌트
```

---

## 🧱 데이터 모델

### `Mapping` — 버튼-루틴 매핑
```swift
struct Mapping: Codable, Identifiable, Equatable {
    var id: Int           // 버튼 번호 (0~6)
    var name: String      // 루틴 이름
    var icon: String      // SF Symbol 이름
    var colorHex: String  // 헥스 컬러 코드
}
```

### `AppData` — 전역 상태 (ObservableObject)
| 프로퍼티 | 타입 | 설명 |
|----------|------|------|
| `mappings` | `[Mapping]` | 7개 버튼 설정 |
| `logs` | `[String: [Int]]` | 날짜별 완료 루틴 ID 목록 |
| `onboarded` | `Bool` | 온보딩 완료 여부 |

주요 메서드:
- `toggle(_ id:)` — 오늘 특정 루틴 완료/취소
- `streakCount()` — 연속 달성일 수 계산
- `weekData()` — 이번 주 요일별 달성 데이터
- `routineCounts()` — 전체 기간 루틴별 완료 횟수

> 모든 데이터는 **UserDefaults**에 JSON으로 영속 저장됩니다.

---

## 🎨 디자인 시스템

### 컬러 (`BloomColor`)
| 토큰 | 용도 |
|------|------|
| `warmWhite` (`#FAF8F4`) | 배경 기본 |
| `cream` / `cream2` / `cream3` | 카드 배경 계층 |
| `ink` / `ink2` / `ink3` | 텍스트 계층 |
| `gold` (`#E8A020`) | 주요 액센트, 완료 상태 |
| `sage` / `rose` / `brown` | 루틴 보조 색상 |

### 폰트 (`BloomFont`)
- **Display** — `DM Serif Display` (제목, 숫자)
- **Body** — `Noto Sans KR` (본문, UI 텍스트)

### 컴포넌트
- `bloomCard()` — 흰 배경 + 0.5pt 테두리 + 라운드 코너 + 소프트 그림자
- `FlowLayout` — 아이콘 피커용 커스텀 플로우 레이아웃

---

## 🛠️ 개발 환경

| 항목 | 버전 |
|------|------|
| Xcode | 15+ 권장 |
| Swift | 5.9+ |
| iOS Deployment Target | iOS 17+ |
| 프레임워크 | SwiftUI |
| 외부 의존성 | 없음 (Pure SwiftUI) |

---

## 🚀 빌드 및 실행

```bash
# 1. 저장소 클론
git clone <repo-url>
cd Bloom

# 2. Xcode에서 열기
open Bloom.xcodeproj

# 3. 시뮬레이터 또는 실기기에서 실행 (Cmd + R)
```

> **외부 라이브러리 없음** — SPM/CocoaPods 설치 단계 불필요

---

## 📋 온보딩 플로우

앱 최초 실행 시 4단계 온보딩이 표시됩니다.

1. **Welcome** — Bloom 로고 꽃 + 브랜드 소개
2. **키링 소개** — 물리적 키링의 7개 버튼 설명
3. **매핑 설명** — 버튼에 루틴을 연결하는 방법
4. **시작** — "오늘부터, 매일 피워봐요" + 시작하기 버튼

온보딩 완료 여부는 `AppData.onboarded`에 저장되며, 재실행 시 스킵됩니다.

---

## 🎥 시연영상
https://drive.google.com/file/d/1SaqtIvnykvxTJLZkYBROIdk39rbOK3lr/view?usp=sharing

## 🌱 향후 개선 아이디어

- [ ] 물리 키링 BLE 연동 (CoreBluetooth)
- [ ] 위젯 지원 (WidgetKit)
- [ ] 푸시 알림 — 루틴 리마인더
- [ ] iCloud 동기화 (CloudKit)
- [ ] 다크 모드 지원
- [ ] 루틴 7개 초과 설정 옵션

---

## 📄 라이선스

© 2026 Bloom. All rights reserved.

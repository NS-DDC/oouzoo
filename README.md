# 🌌 OOUZOO (우주) — Our Little Universe

커플을 위한 로컬 퍼스트 우주 앱.
우리의 추억은 내 손 안에, 서버 없이.

---

## 핵심 철학

| 원칙 | 내용 |
|------|------|
| **Zero Server Cost** | Firebase는 중계(Relay)만 수행, 데이터 저장 없음 |
| **Local-First** | 모든 데이터는 기기 SQLite에 저장 |
| **CC0 에셋** | Kenney.nl 등 상업적 이용 가능한 도트 에셋 사용 |

---

## 주요 기능

### 🌱 행성 & 펫 성장
- 앱 접속, 대화, 일기 작성 시 **별 조각** 획득
- 별 조각을 모아 행성 레벨업 (Lv.1 ~ Lv.5)
- 도트 에셋 레이어 방식으로 행성 커스터마이징

### 💌 웜홀 메시지
- Firebase Realtime DB 중계 → 수신 즉시 노드 삭제
- FCM 푸시 알림으로 기분 변화 실시간 전송

### 📖 우주 일기
- 기분 이모지(😢~😍) + 자유 텍스트
- 작성 완료 후 확률적 전면 광고 노출 (30%)

### 🎰 별자리 뽑기 (가챠)
- 매일 1회 무료
- 광고 시청 또는 별 조각으로 추가 뽑기

### 💾 데이터 백업/복구
- SQLite → JSON 내보내기 (공유하기)
- JSON 가져오기로 새 기기 이전

### 🗓️ 기념일 D-Day
- 커플 시작일 기준 D+N 카운트
- 맞춤 기념일 D-Day 카운트다운

---

## 기술 스택

```
Flutter 3.x (Dart)
├── 상태관리    : Riverpod 2.x
├── 로컬 DB     : sqflite (SQLite)
├── 클라우드    : Firebase Realtime DB (relay-only) + FCM
├── 광고        : Google Mobile Ads (AdMob)
├── 결제        : in_app_purchase
├── 백업        : share_plus + file_picker
└── 폰트        : DotGothic16 (Google Fonts)
```

---

## 프로젝트 구조

```
lib/
├── core/
│   ├── database/         # SQLite 헬퍼 + 마이그레이션
│   ├── models/           # 데이터 모델
│   ├── services/         # Firebase, FCM, AdMob, 백업
│   └── utils/            # 상수, 확장 함수
├── features/
│   ├── home/             # 메인 화면 (NavBar + 오버레이)
│   ├── planet/           # 행성 뷰, 기분 선택, 레벨업
│   ├── messages/         # 웜홀 메시지
│   ├── diary/            # 우주 일기 목록 + 작성
│   ├── gacha/            # 별자리 뽑기
│   ├── anniversary/      # 기념일 D-Day
│   ├── backup/           # 백업/복구 UI
│   └── settings/         # 설정 (배너 광고 포함)
└── shared/
    ├── theme/            # 다크 우주 테마 (도트 팔레트)
    └── widgets/          # 공통 위젯
assets/
├── images/
│   ├── planets/          # 행성 도트 스프라이트 (CC0)
│   ├── pets/             # 펫 스프라이트 (CC0)
│   ├── items/            # 꾸미기 아이템 (CC0)
│   └── backgrounds/      # 우주 배경 (CC0)
├── animations/           # 스프라이트 애니메이션
├── fonts/                # DotGothic16
└── sounds/               # 효과음 (CC0)
```

---

## 광고 / 수익화

| 타입 | 위치 | 시점 |
|------|------|------|
| **보상형** | 가챠 추가 뽑기, 별 조각 2배 | 사용자 선택 |
| **배너** | 설정 하단, 일기 목록 하단 | 상시 |
| **전면** | 일기/별자리 생성 완료 후 | 30% 확률 |
| **유료 결제** | 광고 제거 ₩3,000, 별 조각 패키지, 프리미엄 테마 | 직접 결제 |

---

## 시작하기

```bash
# 1. Flutter 설치 확인
flutter doctor

# 2. 의존성 설치
flutter pub get

# 3. Firebase 설정
#    - Firebase Console에서 프로젝트 생성
#    - google-services.json (Android) / GoogleService-Info.plist (iOS) 추가
#    - lib/firebase_options.dart 생성 (flutterfire configure)

# 4. AdMob 설정
#    - lib/core/services/admob_service.dart 에서 실제 Ad Unit ID로 교체

# 5. 실행
flutter run
```

---

## 에셋 출처

- 도트 에셋: [Kenney.nl](https://kenney.nl) (CC0 1.0 Universal)
- 폰트: DotGothic16 (Google Fonts, OFL)

---

*우주는 넓지만, 우리만의 별은 여기에 있어요.* 🌟

# 해내따 — I did it

> 
### Index

- [소개](#소개)
- [기술](#기술)
- [기능](#기능)
- [설계 및 구현](#설계-및-구현)
- [Trouble Shooting](#Trouble-Shooting)
- [학습한 내용](#학습한-내용)
---
## 소개 
- 확장 가능한 구조와 상태 관리를 기반으로, 하루의 작은 성공 경험을 시각적으로 기록하는 달력 앱입니다.
- 기획, 설계, 디자인, 개발을 담당했습니다.
- 한국어/영어와 라이트/다크모드를 모두 지원합니다. 


## 기술 
`Flutter` `Provider` `SharedPreferences` `intl` 

## 기능

- [목표 달력 뷰](#목표-달력-뷰)
- [목표 생성 및 수정 흐름](#목표-생성-및-수정-흐름)
- [초기화/삭제 다이얼로그](#초기화삭제-다이얼로그)
- [기능 시연 영상](#기능-시연-영상)

### 목표 달력 뷰 (SingleGoalCalendarView)
현재 목표의 달력 UI에서 날짜별 수행 여부를 체크하고, 설정 메뉴를 통해 목표별 제어가 가능합니다.

| 달력 뷰 | 설정 메뉴 |
| --- | --- | 
| <img src="https://github.com/user-attachments/assets/f0da5d97-8947-40af-a6d0-0e7cb0a1537b"> | ![스크린샷 2025-06-21 14 25 13](https://github.com/user-attachments/assets/86b2448d-76bd-45a6-bde5-652a43d1426c) |

### 목표 생성 및 수정 흐름
사용자가 목표를 입력하다가 이탈하려 할 경우, 작성 중이던 내용이 저장되지 않음을 안내합니다.

| 목표 생성 중 이탈 알림 | 목표 수정 |
| --- | --- | 
| ![스크린샷 2025-06-21 14 25 21](https://github.com/user-attachments/assets/5590866b-8e5c-44a1-a63a-9b98ce4c916b)| ![스크린샷 2025-06-21 14 25 18](https://github.com/user-attachments/assets/563c38f9-a7e8-4b3d-ab04-a3c52f9d095f) |


### 초기화/삭제 다이얼로그 
기록 또는 목표를 초기화할 때, 삭제 여부를 한 번 더 확인하는 다이얼로그를 표시합니다.

| 한국어 | 영어 |
| --- | --- | 
| ![스크린샷 2025-06-21 14 25 23](https://github.com/user-attachments/assets/0f9b5806-1545-41da-b5f8-ae4de13488ed) | ![스크린샷 2025-06-21 14 25 28](https://github.com/user-attachments/assets/3834c316-7d99-4bcc-8123-74fb75400f3d) |



### 기능 시연 영상
- 새로 생성한 목표로 자동 이동 → [영상 보기](docs/features/auto_scroll_to_newly_created_goal.mp4)
- 목표명 수정 → [영상 보기](docs/features/edit_goal_name.mp4)
- 기록 초기화 → [영상 보기](docs/features/reset_records_only.mp4)
- 목표 삭제 → [영상 보기](docs/features/reset_goal.mp4)
- 전체 삭제 → [영상 보기](docs/features/reset_all_goals.mp4)


---

## 설계 및 구현


### 데이터 구조 설계

- 목표 ID와 날짜 기록은 `Map<String, DateRecordSet>`으로 관리됩니다.
- 정렬에는 Sparse Ordering을 적용해 유연한 순서 변경이 가능합니다.
- 자세한 내용은 [데이터 구조 상세 보기](docs/data_structure.md)에서 확인할 수 있습니다.

---

## Trouble Shooting

### 목표 추가 직후 해당 목표로 자동 스크롤되지 않음 

- 문제상황 
  - `PageController(initialPage:)`는 생성 시점에만 동작해서 목표 추가 이후 index가 반영되지 않음 
  - PageView.builder는 index 기준으로 위젯을 재사용해 index가 같으면 목표가 바뀌어도 위젯이 갱신되지 않음
  - `jumpToPage()`를 호출했지만  PageController가 연결되지 않아 (hasClients == false) 스크롤이 미동작 

- 해결 방법
  - initState에서 index 계산하고, 렌더링 완료(addPostFrameCallback) 후 `jumpToPage()`를 호출
  - goal.id를 기준으로 `ValueKey(goal.id)`지정해 위젯 재사용 방지
  - Provider에 focusedGoalForScroll 값을 일회성으로 저장하고, 사용 이후 초기화
 
- 실패한 시도
  - `jumpToPage()`를 `initState()`에서 즉시 호출 -> PageController와 PageView 연결 전이라 무시됨
  - 목표 추가 직후 `Navigator.pop()`으로 돌아오면서 호출 -> 렌더링 중이라 PageController 연결 여부 불안정
  - goal index를 파라미터로 직접 넘겨 처리 -> 상태 반영보다 UI가 먼저 그려져 실패

# 해내따 — I did it

> 
### Index

- [소개](#소개)
- [기술](#기술)
- [기능](#기능)
  - [목표 달력 뷰](#목표-달력-뷰)
  - [목표 생성 및 수정 흐름](#목표-생성-및-수정-흐름)
  - [초기화/삭제 다이얼로그](#초기화삭제-다이얼로그)
  - [기능 시연 영상](#기능-시연-영상)
- [설계 및 구현](#설계-및-구현)
- [Trouble Shooting](#Trouble-Shooting)
  - [자동 스크롤 실패 - PageController 초기화 시점](#목표-추가-직후-해당-목표로-자동-스크롤되지-않음)
  - [프레임 드랍 - 셀 리빌드 최적화 실패](#ui-쓰레드에서-무거운-연산이-실행되어-프레임-드랍이-발생함)
  - [contains 실패 - SetDateTime-불일치](#setdatetime의-contains가-제대로-동작하지-않음)
  - [목표 삭제 후 크래시 - fallback 누락](#목표-삭제-후-보여줄-목표가-없어서-크래시-발생)
  - [목표 없음 진입 오류 - push 중복 실행](#앱-진입-시-목표가-없을-경우-빈-화면이-노출되거나-목표명-입력-화면이-두-번-뜸)

---
## 소개 
- 확장 가능한 구조와 상태 관리를 기반으로, 하루의 작은 성공 경험을 시각적으로 기록하는 달력 앱입니다.
- 기획, 설계, 디자인, 개발을 담당했습니다.
- 한국어/영어와 라이트/다크모드를 모두 지원합니다. 


## 기술 
`Flutter` `Provider` `SharedPreferences` `intl` 

## 기능

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
  - initState에서 index 계산하고, 렌더링 완료(`addPostFrameCallback()`) 후 `jumpToPage()`를 호출
  - goal.id를 기준으로 `ValueKey(goal.id)`지정해 위젯 재사용 방지
  - focusedGoalForScroll, shouldScrollToFocusedPage 플래그를 사용해 최초 1회만 스크롤 실행 보장 및 중복 스크롤 방지
 
- 실패한 시도
  - `jumpToPage()`를 `initState()`에서 즉시 호출 -> PageController와 PageView 연결 전이라 무시됨
  - 목표 추가 직후 `Navigator.pop()`으로 돌아오면서 호출 -> 렌더링 중이라 PageController 연결 여부 불안정
  - goal index를 파라미터로 직접 넘겨 처리 -> 상태 반영보다 UI가 먼저 그려져 실패

### UI 쓰레드에서 무거운 연산이 실행되어 프레임 드랍이 발생함

- 문제상황 
  - 앱 실행 중 경고 발생 
    > Skipped 277 frames!
    > The application may be doing too much work on its main thread.
  - 달력의 DayCell이 너무 자주 리빌드되면서 렌더링 성능 저하 발생

- 해결 방법
  - Selector<RecordProvider, Set\<String>>를 사용하여 리빌드 범위 최소화
  - dateKey 기반 contains 연산으로 비교 정확도 및 성능 개선  
  - 셀 위젯에 `ValueKey(cellDate)`를 부여해 캐싱 유지 및 불필요한 rebuild 방지

- 실패한 시도
  - context.watch() -> Selector로 변경 시도
    - 셀마다 Selector<RecordProvider, bool>을 사용해 기록 여부를 판단 -> 모든 셀이 동일한 set을 기반으로 하고 있어 notify시 모든 셀이 다시 그려지며 성능 저하 발생 

### Set\<DateTime>의 contains()가 제대로 동작하지 않음 
- 문제상황
  - DateTime을 `.contains(date)`로 조회할 때, 같은 날이라도 시간 정보가 다르면 false를 반환

- 해결 방법
  - "yyyy-MM-dd" String 포맷 기반 Set 구조로 변경 

- 실패한 시도 
  - DateTime에서 시간 정보를 삭제하고 날짜만 남겨서 사용  
    ``` dart
      DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day)
    ``` 
  - 직렬화 시 시간 정보가 포함되어 의도와 다른 비교 결과가 나옴 
    ``` dart
      DateTime(2025, 6, 29).toIso8601String();
      // "2025-06-29T00:00:00.000"
    ```

### 목표 삭제 후 보여줄 목표가 없어서 크래시 발생
- 문제상황
  - 목표 및 기록을 전부 삭제한 뒤 목표 리스트가 비어서 크래시 발생

- 해결 방법
  - 리스트가 비어 있는지 상태를 확인한 후 fallback 흐름 설계
    - 목표명 입력 화면을 띄워 새 목표 생성 유도하고, 새 목표가 생성되면 해당 페이지로 이동시킴

- 실패한 시도 
  - 목표가 없을 시 자동으로 비어있는 목표를 생성해 앱이 정상 동작하도록 처리함 -> 사용자 의도와 다르게 새 목표 생성되어 사용자 경험이 어색함 

### 앱 진입 시 목표가 없을 경우 빈 화면이 노출되거나 목표명 입력 화면이 두 번 뜸 
- 문제상황 
  - push가 너무 이른 시점(`initState()` 등)에서 조건 판단 없이 실행되었거나, Navigator가 준비되지 않아 push 무시됨
  - 렌더링이 완료되기 전 `build()`나 `initState()`에서 `Navigator.push()`를 호출하면
위젯 재빌드나 상태 변화로 인해 push가 중복 실행될 수 있음

- 해결 방법 
  - 렌더링이 완료된 이후(`addPostFrameCallback()`)에 리스트를 재확인해 안전하게 push하도록 수정
  - `_isAddGoalFlowActive` 플래그로 중복 진입 방지. 사용 후 초기화 

- 실패한 시도 
  - 플래그 없이 렌더링이 완료된 이후에 조건을 확인하는 방법만 사용함 -> 상태가 유지된 채 build가 반복되면 goals.isEmpty는 계속 true라 push가 여러 번 발생

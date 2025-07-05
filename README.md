# 해냈다 — I did it

> 
### Index

- [소개](#소개)
- [설계 및 구현](#설계-및-구현)
  - [역할 분배](#역할-분배)
  - [데이터 구조 설계 및 모델링](#데이터-구조-설계-및-모델링)
- [상태 관리 및 최적화](#상태-관리-및-최적화)
  - [상태 관리 구조: Provider 기반 단방향 흐름](#상태-관리-구조-provider-기반-단방향-흐름)
  - [퍼포먼스 최적화를 위한 상태 접근 전략](#퍼포먼스-최적화를-위한-상태-접근-전략)
- [Trouble Shooting](#Trouble-Shooting)
  - [자동 스크롤 실패 - PageController 초기화 시점](#목표-추가-직후-해당-목표로-자동-스크롤되지-않음)
  - [프레임 드랍 - 셀 리빌드 최적화 실패](#ui-쓰레드에서-무거운-연산이-실행되어-프레임-드랍이-발생함)
  - [contains 실패 - SetDateTime-불일치](#setdatetime의-contains가-제대로-동작하지-않음)
  - [목표 삭제 후 크래시 - fallback 누락](#목표-삭제-후-보여줄-목표가-없어서-크래시-발생)
  - [목표 없음 진입 오류 - push 중복 실행](#앱-진입-시-목표가-없을-경우-빈-화면이-노출되거나-목표명-입력-화면이-두-번-뜸)
- [학습한 내용](#학습한-내용)

<br/>

---

<br/>

# 소개
- 작은 성공 경험을 시각적으로 기록하는 달력 앱입니다.
- 한국어/영어 다국어 및 라이트/다크 모드 지원합니다.
- 기획, 설계, 디자인, 개발까지 모든 과정을 담당했습니다.
- 기능 단위 브랜치 전략과 PR 작성 등 협업을 가정한 개발 방식을 적용했습니다. ([PR 이력](https://github.com/hayeonhee/haenaedda/pulls?q=is%3Apr+is%3Aclosed))

<br/>

## 기술 
`Flutter` `Dart` `MVVM` `Provider` `SharedPreferences` `Intl (i18n)` `DevTools`

<br/>

## 기능

### 목표 생성 및 수정
날짜 셀을 눌러 기록을 토글하고, 설정 버튼을 통해 목표 수정 및 삭제 등의 동작을 수행할 수 있습니다. <br/>
목표 입력 화면에서 이탈 시, 입력한 내용이 저장되지 않는다는 점을 알리는 안내 다이얼로그가 표시됩니다. 저장 후에는 자동으로 캘린더 뷰로 돌아갑니다.

<br/>

| 목표 수정 중 이탈 알림 | 목표 생성 | 목표 수정 |
| --- | --- | --- | 
| <img src="https://github.com/user-attachments/assets/8e1729e3-d1a5-496c-9a9c-5261433f9558" width="260"/> | <img src="https://github.com/user-attachments/assets/d10dd2c1-4099-4e1b-a3c8-1ea8f50dc57c" width="260"/> | <img src="https://github.com/user-attachments/assets/174c3f30-a383-4580-a765-ef3fad6c2ad1" width="260"/> |

<br/>

### 목표 및 기록 삭제/초기화
목표별로 기록 초기화, 목표 삭제, 전체 초기화 등의 정리 작업을 수행할 수 있습니다.<br/>
각 동작은 사용자 확인을 거친 후 실행되어, 실수로 인한 데이터 손실을 방지합니다. 

<br/>

| 기록 초기화 | 목표 삭제 | 전체 초기화 |
| --- | --- | --- | 
| <img src="https://github.com/user-attachments/assets/40f02c55-108b-4e89-bbaa-73ee7b6a3673" width="260"/> | <img src="https://github.com/user-attachments/assets/d45714ff-1019-449f-aa55-f3aa2ceee46a" width="260"/> | <img src="https://github.com/user-attachments/assets/65a98321-f062-4eee-8589-c083fefc9d15" width="260"/> | 

<br/>
<br/>

---

<br/>

# 설계 및 구현

> UI와 상태, 유틸리티 계층 간의 명확한 책임 분리와, 단방향 데이터 흐름의 유지를 목표로 설계했습니다.

<br/>

## 역할 분배 
### View

| class | 역할 | 
| --- | --- |
| GoalCalendarPage | 기록된 목표를 월별로 보여주는 메인 화면. GoalPager와 설정 버튼 등을 포함하여 전체 UI를 구성한다 |
| GoalPager | 세로 스크롤 PageView. 각 목표별 캘린더를 렌더링한다 | 
| GoalCalendarContent | 단일 목표의 월간 캘린더 UI. Header·요일·Grid 등으로 분리된다 | 
| GoalCalendarGrid | 월간 달력을 구성하며, 날짜 셀과 빈 셀을 구분해 각각 렌더링한다. 날짜 셀의 렌더링은 cellBuilder에 위임된다 | 
| CalendarDayCell | 실제 날짜 셀 UI. 기록 여부에 따라 스타일이 다르며, 클릭 시 `onTap(goalId, date)` 콜백을 상위로 전달한다 | 

<br/>

### ViewModel

| class | 역할 | 
| --- | --- |
| GoalViewModel | 목표(Goal)의 생성, 수정, 삭제, 정렬 순서, 저장 및 불러오기 등 목표 관련 전반적인 상태와 비즈니스 로직을 관리한다 | 
| RecordViewModel | 각 목표에 해당하는 날짜별 기록 정보와 기록 토글, 저장/불러오기, 기록 삭제, 저장 지연 처리(debounce) 등 동작을 관리한다 |
| CalendarDateViewModel | 보여줄 월 상태 관리. 월 이동 기능 및 canGoToPrevious 등의 파생 상태 계산을 포함한다 | 

<br/>

### Interaction Handler 

| class | 역할 | 
| --- | --- |
| EditGoalHandler | 목표 추가·수정 과정에서 사용자 입력 처리, 저장 흐름, 유효성 검사 등을 담당한다 |
| ResetGoalHandler | 목표 초기화 흐름(확인 다이얼로그, 삭제, 에러 처리 등)을 캡슐화하여 제공한다 |

<br/>

### Utilities

| class | 역할 | 
| --- | --- |
| CalendarGridLayout | 월 시작 요일, 셀 인덱스, 공백 셀 계산 등 달력 레이아웃 계산을 전담한다 | 
| DateCompareExtension | 날짜 간 연/월 비교, 기간 계산 등의 기능을 DateTime extension으로 제공한다 |

<br/>
<br/>

## 데이터 구조 설계 및 모델링

- 목표 및 기록은 `Map<String, DateRecordSet>` 형태로 관리되며, 날짜 기반의 빠른 조회가 가능합니다.
- 정렬에는 Sparse Ordering을 적용해 유연한 순서 변경이 가능합니다.
- 자세한 내용은 [데이터 구조 상세 보기](docs/data_structure.md)에서 확인할 수 있습니다.

<br/>
<br/>

---

<br/>

# 상태 관리 및 최적화 

## 상태 관리 구조: Provider 기반 단방향 흐름

- 사용자 인터랙션과 상태 로직의 관심사를 분리하고, Provider 기반 단방향 흐름으로 상태를 관리했습니다.
    - e.g. `CalendarDayCell`에서 발생한 `onTap(goalId, date)` 이벤트는 콜백을 통해 상위 계층으로 전달되며, 최종 처리는 `GoalCalendarPage`에서 이루어집니다. 
    - e.g. `canGoToPrevious(DateTime)`는 단순한 플래그가 아니라, 최초 기록일과의 비교를 기반으로 계산되는 파생 상태(computed state)로, 이전 달로 이동 가능한지를 동적으로 판단해 UI 렌더링 조건에 반영합니다.

<br/>

## 퍼포먼스 최적화를 위한 상태 접근 전략

- Provider를 사용할때, 상태 접근 방식을 목적과 시점에 따라 구분하여 사용하며, 불필요한 리렌더링을 방지하도록 구성했습니다.

    [Provider 상태 접근 방식 학습한 내용](#Provider-상태-접근-방식의-목적별-활용)

  - e.g. `RecordViewModel.getRecords(goalId)`는 `_recordsByGoalId`에 저장된 동일 참조 데이터를 반환하며, 셀에서는 이 데이터를 바탕으로 `.contains(date)` 연산만 수행합니다. 
  - 달력 특성상 셀의 개수가 많기 때문에 자주 호출되는 메서드에서 계산을 반복하지 않도록 상태를 캐싱하고, 참조 기반 비교를 활용해 상태 변경이 없는 셀은 리렌더링되지 않도록 했습니다. 

<br/>

### 상태 구독 범위 조절을 통한 렌더링 효율 확보

- 각 `CalendarDayCell`은 `Selector<RecordViewModel, bool>`을 사용하여, 자신의 날짜에 해당하는 기록 여부만 구독하도록 구성했습니다.
- Selector 내부에서는 getRecords(goalId)?.contains(date)를 호출하며, 이는 내부적으로 캐싱된 DateRecordSet을 참조하므로 매번 새로운 데이터를 생성하지 않습니다.

<br/>
<br/>

---

<br/>


# Trouble Shooting
## 목표 추가 직후 해당 목표로 자동 스크롤되지 않음 

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

<br/>
<br/>

## UI 쓰레드에서 무거운 연산이 실행되어 프레임 드랍이 발생함

- 문제상황 
  - 앱 실행 중 경고 발생 
    > Skipped 277 frames!
    > The application may be doing too much work on its main thread.
  - 달력의 DayCell이 너무 자주 리빌드되면서 렌더링 성능 저하 발생

- 해결 방법
  - Selector<RecordViewModel, Set\<String>>를 사용하여 리빌드 범위 최소화
  - dateKey 기반 contains 연산으로 비교 정확도 및 성능 개선  
  - 셀 위젯에 `ValueKey(cellDate)`를 부여해 캐싱 유지 및 불필요한 rebuild 방지

- 실패한 시도
  - context.watch() -> Selector로 변경 시도
    - 셀마다 Selector<RecordViewModel, bool>을 사용해 기록 여부를 판단 -> 모든 셀이 동일한 set을 기반으로 하고 있어 notify시 모든 셀이 다시 그려지며 성능 저하 발생 

<br/>
<br/>

## Set\<DateTime>의 contains()가 제대로 동작하지 않음 
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

<br/>
<br/>

## 목표 삭제 후 보여줄 목표가 없어서 크래시 발생
- 문제상황
  - 목표 및 기록을 전부 삭제한 뒤 목표 리스트가 비어서 크래시 발생

- 해결 방법
  - 리스트가 비어 있는지 상태를 확인한 후 fallback 흐름 설계
    - 목표명 입력 화면을 띄워 새 목표 생성 유도하고, 새 목표가 생성되면 해당 페이지로 이동시킴

- 실패한 시도 
  - 목표가 없을 시 자동으로 비어있는 목표를 생성해 앱이 정상 동작하도록 처리함 -> 사용자 의도와 다르게 새 목표 생성되어 사용자 경험이 어색함 

<br/>
<br/>

## 앱 진입 시 목표가 없을 경우 빈 화면이 노출되거나 목표명 입력 화면이 두 번 뜸 
- 문제상황 
  - push가 너무 이른 시점(`initState()` 등)에서 조건 판단 없이 실행되었거나, Navigator가 준비되지 않아 push 무시됨
  - 렌더링이 완료되기 전 `build()`나 `initState()`에서 `Navigator.push()`를 호출하면
위젯 재빌드나 상태 변화로 인해 push가 중복 실행될 수 있음

- 해결 방법 
  - 렌더링이 완료된 이후(`addPostFrameCallback()`)에 리스트를 재확인해 안전하게 push하도록 수정
  - `_isAddGoalFlowActive` 플래그로 중복 진입 방지. 사용 후 초기화 

- 실패한 시도 
  - 플래그 없이 렌더링이 완료된 이후에 조건을 확인하는 방법만 사용함 -> 상태가 유지된 채 build가 반복되면 goals.isEmpty는 계속 true라 push가 여러 번 발생

<br/>
<br/>

---

<br/>

# 학습한 내용 
## Provider 상태 접근 방식의 목적별 활용 

| 사용 방법 | 목적 및 사용 시점 | 사용 예시 | 
| --- | --- | --- |
| `read<T>()` | 콜백 내부에서 상태만 읽고 UI는 반응할 필요 없을 때 | `toggleRecord(goalId, date)` | 
| `watch<T>()` | 전체 위젯이 상태 변경에 반응해야 할 때 | `watch\<CalendarDateViewModel>();` |
| `select<T, R>()` | 상태의 특정 필드만 구독하고 싶을 때 | `select<RecordViewModel, Goal?>((vm) => vm.getGoalById(id));` |
| `Selector<T, R>()` | 특정 하위 위젯 단위에서만 리빌드가 필요할 때 | `Selector<RecordViewModel, bool>(..)1 |

<br/>
<br/>
<br/>

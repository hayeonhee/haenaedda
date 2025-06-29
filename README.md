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

### Dialog의 "취소"버튼을 눌렀을 때 Dialog가 닫히지 않는 문제  

- 문제상황  
  - Navigator.pop() 이후 BuildContext가 이미 disposed된 상태였을 가능성 
  - 또는 showDialog 위에 또 다른 showDialog가 중첩되었거나, Dialog를 닫는 로직이 명확하게 연결되지 않았을 가능성이 있었다
- 해결 방법
  - Dialog 내부에서 명확하게 값을 반환
    - Future<bool?>을 반환하는 구조로, 사용자의 선택 결과(확인/취소)를 상위에서 받음 
    - Navigator.pop(true)로 확인 의사를 전달
 
      ``` dart
       Future<bool?> showResetConfirmDialog(...) async {
               return await showDialog<bool?>(
               context: context,
               builder: (context) => AlertDialog(
                   actions: [
                       TextButton(
                       onPressed: () => Navigator.of(context).pop(), // 취소
                       child: Text(l10n.cancel),
                       ),
                       TextButton(
                       onPressed: () => Navigator.of(context).pop(true), // 확인 
                       child: Text(l10n.confirm),
                       )
                   ],
               ),
           ),
       }
      ```
  - 호출부에서 await로 흐름 제어 + mounted 체크
    - 상태 변경이 일어날 수 있으므로 context.mounted를 반드시 확인

      ``` dart
       final confirmed = await showResetConfirmDialog(context, goal, type);
  
       if (!context.mounted || confirmed != true) return;
      ```

### 사용자에게 초기화 결과에 대한 정확한 피드백을 주지 못하는 문제  

- 문제상황
  - 기록은 삭제됐으나 목표는 삭제되지 않는 한 경우가 존재함에도 실패 메시지가 동일하게 출력됨
- 해결 방법
  - ResetEntireGoalResult enum을 도입하여 결과를 세분화 (success, recordFailed, goalFailed), 이에 맞는 다국어 메시지를 intl에 추가하여 정확한 피드백 제공

### 초기화 이후 보여줄 목표가 없어서 크래시가 나는 문제
- 문제상황
  - 목표 및 기록을 전부 초기화한 뒤 목표 리스트가 비는 문제 발생
- 해결 방법
  - createTemporaryGoalIfAbsent() 메서드를 도입해 목표가 없을 시 자동으로 비어있는 목표를 생성해 앱이 정상 동작하도록 처리함
  - 추후 목표를 입력받는 초기 화면을 추가하여 빈 객체를 임의 생성하는 대신 사용자가 의도를 가지고 생성한 객체를 사용하도록 수정할 예정

### 목표 추가 직후, 해당 목표로 자동 스크롤되지 않는 문제

- 문제상황 
  - `PageController(initialPage: ...)`는 생성 시점에만 동작하는데, build 이후에 계산된 index나 Provider 상태가 늦게 반영되면 제대로 스크롤되지 않음
  - goal 데이터는 바뀌었지만 index는 같게 유지돼서(PageView.builder는 index로 위젯을 재사용) SingleGoalCalendarView가 새로 빌드되지 않아 내부 UI가 이전 상태에 머묾

- 해결 방법
  - index 계산을 initState에서 수행하고, 그 결과로 `PageController(initialPage: index)`를 생성
  - goal.id를 기준으로 `ValueKey(goal.id)`를 지정하여 위젯 재사용 방지
  - 파라미터 전달 방식 대신 Provider에 일회성 상태를 저장하고, 사용 후 바로 초기화하는 방식으로 전환
 

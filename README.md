# 해내따 — I did it

> 확장 가능한 구조와 상태 관리를 기반으로, 하루의 작은 성공 경험을 시각적으로 기록하는 달력 앱 설계·구현하기

### Index

- [기능](#기능)
- [설계 및 구현](#설계-및-구현)
- [Trouble Shooting](#Trouble-Shooting)

---

## 기능

- [성공 경험 기록](#성공-경험-기록)
- [목표 설정 및 수정](#목표-설정-및-수정)
- [기록 초기화](#기록-초기화)
- [목표 및 기록 초기화](#목표-및-기록-초기화)


### 성공 경험 기록

<img src="https://github.com/user-attachments/assets/79c7e5db-2064-449b-bd4c-27a36811c6d5" width="300"/>


### 목표 설정 및 수정

 <img src="https://github.com/user-attachments/assets/6eeabad9-9587-4fc6-9209-65936f881d6d" width="300"/>


### 기록 초기화

 <img src="https://github.com/user-attachments/assets/a12f8610-33a9-4820-afd7-ac15e963857f" width="300"/>


### 목표 및 기록 초기화

 <img src="https://github.com/user-attachments/assets/1d021682-8eea-4e41-96bc-6bdbc8005427" width="300"/>

 
---

## 설계 및 구현

### 데이터 구조 설계

### 기록 저장 구조: `Map<String, DateRecordSet>` 

- `String`: Goal의 고유 ID
- `DateRecordSet`: 사용자가 해당 목표를 완료한 날짜들의 집합

예시:
```dart
{
  "1": {2025-06-01, 2025-06-03}, // 목표 ID 1번이 6/1, 6/3에 체크됨
  "2": {2025-06-02}              // 목표 ID 2번은 6/2에 한 번만 체크됨
}
```

### 사용자 정의 타입: Goal

| 필드명 | 타입 | 설명 |
|--------|------|------|
| `id` | `String` | 목표의 고유 식별자 |
| `order` | `int` | 사용자 정의 정렬 순서 |
| `title` | `String` | 목표 제목 |


### 사용자 정의 타입: DateRecordSet
- 날짜 비교 시 시간 정보로 인해 오류가 발생할 수 있어 시간 정보를 제거하고, 날짜만 남김 (정규화)
- Set<DateTime>은 SharedPreferences에 직접 저장할 수 없어 별도의 변환 로직 필요
- 날짜 정규화 및 직렬화/역직렬화 로직을 캡슐화해 코드 중복을 줄이고 안정성 향상


### 해시 기반 Map-Set 단일 구조 → List 추가한 이유
- 장기 운영을 전제로 목표가 많아지거나 다양한 커스텀 설정 지원할 수 있도록 구조를 확장
- Goal ID를 키로 사용해 title이 변경되어도 기록과의 연결이 유지됨

- Goal ID를 String으로 선언한 이유:
  - 현재 id가 자주 사용되는 작업이 SharedPreferences에 저장/불러오기이기 때문에, 불필요한 변환을 줄이고 데이터 일관성을 유지하기 위해 String 타입으로 선언
- 목표 노출 순서를 제어하기 위해 order 필드를 도입하고, sparse ordering 방식을 적용하여 유연한 순서 변경 및 중간 삽입이 가능하도록 설계

### Goal 정렬 방식: Sparse Ordering
> 이 설계는 Notion, Trello 등에서 사용하는 방식에서 착안했습니다.

- 각 Goal은 `order` int 필드를 갖고, 숫자가 작을수록 먼저 노출됨
- 간격은 10단위로 부여되어 중간 삽입이 가능
- 순서가 꼬일 경우 `rebalanceOrders()`를 통해 정렬 값을 일괄 재조정

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



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
    - SharedPreferences에 저장/불러오기 시 불필요한 변환을 줄이고, 데이터 일관성을 유지하기 위해 String 타입으로 선언
- 목표 노출 순서를 제어하기 위한 order 필드
    - sparse ordering 방식을 적용하여 유연한 순서 변경 및 중간 삽입이 가능하도록 설계

### Goal 정렬 방식: Sparse Ordering
> 이 설계는 Notion, Trello 등에서 사용하는 방식에서 착안했습니다.

- 각 Goal은 `order` int 필드를 갖고, 숫자가 작을수록 먼저 노출됨
- 간격은 10단위로 부여되어 중간 삽입이 가능
- 순서가 꼬일 경우 `rebalanceOrders()`를 통해 정렬 값을 일괄 재조정

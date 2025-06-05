# 해내따 — I did it

> 확장 가능한 구조와 상태 관리를 기반으로, 하루의 작은 성공 경험을 시각적으로 기록하는 달력 앱 설계·구현하기

### Index

- [기능](#기능)
- [설계 및 구현](#설계-및-구현)
- [Trouble Shooting](#Trouble-Shooting)
- [학습한 내용](#관련-학습-내용)

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
#### 해시 기반 Map-Set 

#### List<Goal> 추가 
- Map<String, Set<DateTime>> 단일 구조 -> List<Goal> + Map<String, Set<DateTime>> 변경 이유
    - 장기 운영을 전제로, 목표가 많아지거나 다양한 커스텀 설정 지원하는 확장성 고려 
    - Map의 Key를 ID로 사용해 목표 이름이 변경되어도 무관하고, 화면 노출 순서를 조절할 수 있음
    - 목표 ID를 가장 자주 사용하는 작업이 SharedPreferences에 저장/불러오기이기 때문에, 불필요한 변환을 줄이고 데이터 일관성을 유지하기 위해 String 타입 사용


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
                    )다
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

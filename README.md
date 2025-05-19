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


### 성공 경험 기록

<img src="https://github.com/user-attachments/assets/2eb38664-5edf-492c-890d-1669eeeeeea8" width="500"/>


### 목표 설정 및 수정

 <img src="https://github.com/user-attachments/assets/b954fe69-0b75-4ed9-b66d-803d63395435" width="500"/>

---

## 설계 및 구현

### 데이터 구조 설계 - List + Map 
-  Map<String, Set> 단일 구조 -> List + Map 변경 이유
    - 장기 운영을 전제로, 목표가 많아지거나 다양한 커스텀 설정 지원하는 확장성 고려 
    - Map의 Key를 ID로 사용해 목표 이름이 변경되어도 무관하고, 화면 노출 순서를 조절할 수 있음
    - 목표 ID를 가장 자주 사용하는 작업이 SharedPreferences에 저장/불러오기이기 때문에, 불필요한 변환을 줄이고 데이터 일관성을 유지하기 위해 String 타입 사용

 
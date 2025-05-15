# 해내따 — I did it

### Index

- [기능](#기능)
- [설계 및 구현](#설계-및-구현)
- [Trouble Shooting](#Trouble-Shooting)
- [학습한 내용](#관련-학습-내용)

---

## 설계 및 구현

### 데이터 구조 설계 - List + Map 
-  Map<String, Set> 단일 구조 -> List + Map 변경 이유
    - 장기 운영을 전제로, 목표가 많아지거나 다양한 커스텀 설정 지원하는 확장성 고려 
    - Map의 Key를 ID로 사용해 목표 이름이 변경되어도 무관하고, 화면 노출 순서를 조절할 수 있음
    - 목표 ID를 가장 자주 사용하는 작업이 SharedPreferences에 저장/불러오기이기 때문에, 불필요한 변환을 줄이고 데이터 일관성을 유지하기 위해 String 타입 사용

 
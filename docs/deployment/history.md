## history about hyperregistry helm chart

### v2.4.1
* metrics 및 tracing 지원을 위한 harbor v2.4.1 통합
    * [superregistry 5.0 브랜치]와 [harbor release-2.4.0 브랜치] 통합
    * helm chart git repo를 git fork 기반의 tmaxcloud/harbor-helm으로 변경 및 업데이트
    * prometheus와 jaeger를 이용한 metrics 및 tracing 테스트

### v2.4.1a
* 2.4.1 customzie 이미지
    * test 전용
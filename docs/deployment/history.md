# Hyperregistry 버전 비고
* Hyperregistry의 오픈소스인 "Harbor"는 이미지와 헬름차트의 버전차이가 존재
    - Harbor 2.4.x | Harbor-Helm 1.8.x
* Hyperregistry는 "Harbor와 다르게" helm chart 버전을 동일하게 설정.
    - Hyperregistry 2.4.x | Hyperregistry-Helm 2.4.x

# Hyperregistry 히스토리

### v2.4.1 [현재 사용 중]
* metrics 및 tracing 지원을 위한 harbor v2.4.1 통합
    * [superregistry 5.0 브랜치]와 [harbor release-2.4.0 브랜치] 통합
    * helm chart git repo를 git fork 기반의 tmaxcloud/harbor-helm으로 변경 및 업데이트
    * prometheus와 jaeger를 이용한 metrics 및 tracing 테스트
   
* redis, portal, database에 대한 log level 지원
* 모든 서브 모듈 내 timezone 설정

### v2.2.2
* Kubespray 지원 시작

# HyperRegistry-Chart
The HyperRegistry is an image registry based on an open source [harbor](https://github.com/goharbor/harbor).
This is helm repository for HyperReigstry.

## 개요
* 목적: 이미지를 저장하고 관리(서명, 스캔)하기 위함
* 역할: Hypercloud 내 모든 이미지를 저장하고 관리하는 용도

## Installation
- [폐쇄망 환경 준비](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/install.md#폐쇄망에서-설치를-위한-환경-준비하기)
- [설치](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/install.md#설치)
- [HyperAuth OIDC 연동](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/oidc.md)
- [P2P Preheat 연동](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/kraken.md)
- [외부 Registry Replication 연동](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/replication.md)
- [외부 HA DB 구성](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/postgres.md)
- [외부 HA REDIS 구성](https://github.com/tmax-cloud/harbor-helm/blob/5.0/docs/redis.md)
- [이미지 서명 가이드 (Download pptx)](https://tmaxcloud-ck1-2.s3.ap-northeast-2.amazonaws.com/%EC%9D%B4%EB%AF%B8%EC%A7%80+%EC%84%9C%EB%AA%85.pptx)

## Usage
### 레지스트리 생성 및 설정하기
1. 포털 로그인 (https://core.harbor.domain)
2. 프로젝트 생성하기
    1. Projects > New Project 클릭
    2. 이름 입력 후 OK
3. 프로젝트 환경설정
    1. Proejcts > [생성한 레지스트리] > Configuration
    2. (필요 여부에 따라) 다음 항목 체크
        - Public
        - Enable content trust
        - Prevent vulnerable images from running
        - Automatically scan image on push
    3. Save
4. (Optional) 레지스트리 사용자 생성 및 등록
    1. Administration > Users > New User
    2. 유저 생성
    3. Project > [생성한 유저가 사용할 프로젝트] > Members > + User
    4. [생성한 유저 이름] 입력 및 권한 설정 후 OK

### 신뢰하는 서버로 등록하기
**[NOTE] Harbor로부터 이미지를 pull받을 모든 노드에 적용**
1. 인증서(ca.crt) 다운로드
    1. Proejcts > [임의의 레지스트리] > Registry Certificate 클릭
2. (모든 노드에) 인증서 등록
    1. 다운로드한 인증서(ca.crt)를 신뢰하는 인증서 경로에 복사 및 등록
        - CentOS
          ```bash
          cp ca.crt /etc/pki/ca-trust/source/anchors
          update-ca-trust
          ```
        - Ubuntu
          ```bash
          cp ca.crt /usr/local/share/ca-certificates
          update-ca-certificates
          ```
3. 컨테이너 런타임 재기동
    - Docker
      ```bash
      systemctl restart docker
      ```
    - CRI-O
      ```bash
      systemctl restart crio
      ```

### 이미지 푸시하기
```bash
podman login [harbor_domain]/[project] # podman login core.hr.172.10.0.2.nip.io/library
podman tag [to_push_image] [harbor_domain]/[project]/[repository]:[tag]
podman push [harbor_domain]/[project]/[repository]:[tag]
```

### 이미지 풀하기
```bash
podman pull [harbor_domain]/[project]/[repository]:[tag]
```

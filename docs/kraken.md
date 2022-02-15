# Kraken 설치 가이드

## Prerequsite

- git (checked version: 2.25.1)
- podman (checked version: v3.1.2)
- [helm](https://helm.sh/docs/intro/install/) (v2.8.0+)
- [kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/) (checked version: v1.19.4)
- ingress controller

## How-to

### 폐쇄망에서 설치를 위한 환경 준비하기

1. (외부망 환경에서) Kraken 이미지 및 바이너리 다운로드

   1. Kraken 이미지 다운로드
      ```bash
      cd ${REPO_HOME}/contrib/kraken # REPO_HOME is HyperRegistry-Chart's home path
      chmod +x ./kraken-download.sh
      ./kraken-download.sh <download_dir> # ./kraken-download.sh ./kraken-downloads
      ```
   2. Helm 클라이언트 다운로드 (Prerequsite - helm 참조)

2. git repo 전체(다운로드한 이미지 포함)를 내부망으로 복사

3. 폐쇄망 환경의 레지스트리에 이미지 업로드
   ```bash
   chmod +x ./kraken-upload.sh
   ./kraken-upload.sh <download_dir> <registry> # ./kraken-upload.sh ./kraken-downloads 172.22.11.2:5000
   ```

### 설치

1. values.yaml 수정

   - repository & tag
     - 레지스트리에 업로드한 이미지에 맞게 변경 ex) repository: 172.22.11.2:5000, tag: v0.1.4
   - build_index.extarBackends & origin.extraBackends 추가
     - address: HyperRegistry의 도메인
     - username & password: 해당 repository username과 password
   - ingress.ingressHostPrefix
     - kraken.<인그레스컨트롤러\_EXTERNAL_SERVICE_IP>.nip.io 로 변경

2. 스토리지클래스 설정

   ```bash
   kubectl get storageclass
   NAME                    PROVISIONER                       RECLAIMPOLICY      VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE              AGE
   rook-cephfs (default)   rook-ceph.cephfs.csi.ceph.com     DELETE             Immediate           true                   1d
   ```

   cf. 기본 스토리지클래스가 없을 경우 새로 지정하기

   ```bash
   kubectl patch storageclass rook-cephfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
   ```

3. 배포
   ```bash
   helm install <name> ./kraken
   ```

### 사용

1. 포털 로그인 ex) https://core.hr.domain
2. Instance 생성
   1. Administration > Distributions > + NEW INSTANCE 클릭
   2. 파라미터 설정
      - Provider: Kraken
      - Name: 원하는 이름 설정
      - EndPoint: http://<인그레스 kraken-proxy-ingress endpoint>
      - Auth Mod: None
      - Options: Skip certificate verification 체크
   3. Test connection 후 OK 클릭
3. 프로젝트 환경 설정
   1. Projects > [생성한 레지스트리] > P2P Preheat > NEW POLICY 클릭
   2. 파라미터 설정
      - Provider: 2에서 생성한 인스턴스 선택
      - Name: 원하는 이름 설정
      - Filter: Preheat 대상에 맞게 Repository & tag 설정
      - Trigger: Preheat policy에 맞게 선택
   3. ADD 클릭
4. Image Preheat
   1. Trigger: manual => 생성한 policy 선택 > Action > Execute
5. Image pull
   - Kraken agent는 default로 30081 포트 사용
   - ex) crictl pull core.hr.domain.nip.io/library/busybox:latest => crictl pull 127.0.0.1:30081/library/busybox

### 참고

https://goharbor.io/docs/2.3.0/administration/p2p-preheat/manage-preheat-providers/

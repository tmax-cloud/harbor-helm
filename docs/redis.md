# Redis HA(High Availability)
## Prerequisite
- git (checked version: 2.25.1)
- podman (checked version: v3.1.2)
- [helm](https://helm.sh/docs/intro/install/) (v2.8.0+)
- [kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/) (checked version: v1.19.4)

## Installation
1. (외부망 환경에서) Redis + Sentinel 이미지 다운로드
   ```bash
   cd ${REPO_HOME}/contrib/redis # REPO_HOME is HyperRegistry-Chart's home path
   chmod +x ./redis-download.sh
   ./redis-download.sh <download_dir> # ./redis-download.sh ./redis-downloads
   ```
2. 다운로드한 이미지를 내부망으로 복사
3. 폐쇄망 환경의 레지스트리에 이미지 업로드
   ```bash
   chmod +x ./redis-upload.sh
   ./redis-upload.sh <download_dir> <registry> # ./redis-upload.sh ./redis-downloads 172.22.11.2:5000
   ```
4. 필요에 따라 values.yaml 수정
   - 폐쇄망 registry에 맞게 image 수정
   - 파라미터 수정 ([참조](https://github.com/bitnami/charts/tree/309c7c6e5eaab649a1f878c2f59198510086ef37/bitnami/redis#parameters))
5. 설치
   ```bash
   helm install <release_name> .
   ```

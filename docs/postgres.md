# Postgresql HA

## Prerequsite
- git (checked version: 2.25.1)
- podman (checked version: v3.1.2)
- [helm](https://helm.sh/docs/intro/install/) (v2.8.0+)
- [kubectl](https://kubernetes.io/ko/docs/tasks/tools/install-kubectl-linux/) (checked version: v1.19.4)
- pgAdmin4

## Installation
1. (외부망 환경에서) Postgresql 이미지 다운로드
   ```bash
   cd ${REPO_HOME}/contrib/postgresql # REPO_HOME is HyperRegistry-Chart's home path
   chmod +x ./postgres-download.sh
   ./postgres-download.sh <download_dir> # ./postgres-download.sh ./postgres-downloads
   ```
2. 다운로드한 이미지를 내부망으로 복사
3. 폐쇄망 환경의 레지스트리에 이미지 업로드
   ```bash
   chmod +x ./postgres-upload.sh
   ./postgres-upload.sh <download_dir> <registry> # ./postgres-upload.sh ./postgres-downloads 172.22.11.2:5000
   ```
4. values.yaml 수정
   - postgresqlImage
   - pgpoolImage 
   - metricsImage 
   - volumePermissionsImage.registry
   - volumePermissionsImage.repository
   - volumePermissionsImage.tag
5. 설치
   ```bash
   helm install <release_name> .
   ```

### DB 생성
1. PgAdmin4 접속 후 DB 생성
   1. Servers > Create > Server
   2. General탭 Name 설정
   3. Connection 탭 Host name/address 설정=> pgpool pod의 IP (kubectl get pod -o wide < podname > -n < namespace >)
   4. Password
      ```bash
      kubectl get secret --namespace default postgres-postgresql-ha-postgresql -o jsonpath="{.data.repmgr-password}" | base64 --decode)
      ```
      확인 및 입력
   5. Save
   6. 생성한 서버 우클릭
   7. Create > Database > 'registry', 'notary_signer', 'notary_server' 이름의 DB 세개 생성

2. PgAdmin 사용 불가할 시
   ```bash
   export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgres-postgresql-ha-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
   kubectl run postgres-postgresql-ha-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql-repmgr:13.3.0-debian-10-r53 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
   --command -- psql -h postgres-postgresql-ha-pgpool -p 5432 -U postgres -d postgres
   ```

   위 커맨드로 postgres 접속 후 sql 명령 이용하여 생성
   ```bash
   postgres-# CREATE DATABASE name OWNER rolename;
   ```

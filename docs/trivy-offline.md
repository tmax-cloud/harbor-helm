# 폐쇄망 이미지 스캐닝 가이드 (trivy-db v2, hyperregistry-2.7.0)
* trivy 0.22.0 -> 0.35.0 버전으로 업그레이드로 인해 0.22.0 버전에서 사용하던 trivy.offline.db 파일을 더 이상 지원하지 않아 v2 버전의 db 파일을 사용해야 한다.
* v2 버전의 offline db 다운로드
   * https://aquasecurity.github.io/trivy/v0.48/docs/advanced/air-gap/

1. 외부망 환경에서 trivy 레포 등록
```
vim /etc/yum.repos.d/trivy.repo  
```
```
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$releasever/$basearch/
gpgcheck=0
enabled=1
```

2. trivy 설치
```
yum install trivy
```

3. trivy 명령어를 통해 최신 db 다운로드
```
trivy --cache-dir . image --download-db-only         // db, fanal 폴더 최신버전으로 다운 받아짐
tar -cf ./db.tar.gz -C ./db metadata.json trivy.db   // db 폴더 압축
```

4. 내부망 hyperregistry trivy 파드 /home/scanner/.cache/trivy/db 위치로 이동
```
내부망으로 압축 파일 이동 후 db 압축파일 trivy 파드 내부로 이동
k cp -n hyperregistry db.tar.gz hyperregistry-harbor-trivy-0:/home/scanner/db.tar.gz 한 후 .cache/trivy/db 폴더내로 이동
```

5. 파드 내부에서 db.tar.gz 압축 해제 
```
tar xvf db.tar.gz
rm -rf db.tar.gz
```
6. hyperregistry에서 scan 


# 폐쇄망 이미지 스캐닝 가이드 (trivy-db v1, hyperregistry-2.4.1)

1. hyperregistry helm chart의 values.yaml에 다음 아래의 value가 없을 경우 추가, 있을 경우 false를 true로 변경
  - kubespray로 설치한 경우 /etc/kubernetes/addons/hyperregistry/hr-nginx-values.yml 이용
```yaml
# values.yaml
...
trivy
  ...
  skipUpdate: true
  offlineScan: true
  ...
```
 - hyperregistry 기동(helm upgrade 혹은 내렸다 다시 기동)

2. trivy-db 깃허브에서 최신 버전의 취약점 분석 db 파일(trivy-offline.db.tgz) 다운로드
  - [https://github.com/aquasecurity/trivy-db/releases](https://github.com/aquasecurity/trivy-db/releases)

3. 받아 hyperregistry trivy pod 내에 복사 
  - 파일을 넣을 Pod는 hyperregistry-harbor-trivy-0
```bash
kubectl cp -n hyperregistry {download_db_file_path}/trivy-offline.db.tgz hyperregistry-harbor-trivy-0:/trivy-offline.db.tgz
```

4. '/home/scanner/.cache/'에 다음 아래의 디렉토리를 생성
```bash
mkdir -p /home/scanner/.cache/trivy/db
```

5. 생성한 디렉토리로 이동
```bash
cd /home/scanner/.cache/trivy/db
```

6. hyperregistry trivy pod로 옮긴 trivy-offline.db.tgz를 생성한 디렉토리로 이동
```bash
mv /path/to/trivy-offline.db.tgz .
```

7. 압축 해제
```bash
tar xvf trivy-offline.db.tgz
```

8. 압축 파일 삭제
```bash
rm -rf trivy-offline.db.tgz
```

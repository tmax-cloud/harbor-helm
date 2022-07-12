# 페쇄망 이미지 스캐닝 가이드

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

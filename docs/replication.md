# 이미지 복제
### 1. 외부 레지스트리 등록
1. Administration > Registries > NEW ENDPOINT 클릭
2. 다음의 내용으로 생성
   1. Provider: 레지스트리 프로바이더 (ex. DockerHub 등)
   2. Name: 이름
   3. Endpoint URL: 외부 레지스트리 URL (ex. docker.io)
   4. Access ID & Access Secret: 외부 레지스트리의 크레덴셜
   5. Verify Remote Cert: 인증서를 검증할지 여부
3. Test Connection 후 OK 클릭
### 2. Replication Rule 생성
1. Administration > Replications > NEW REPLICATION RULE 클릭
2. 다음의 내용으로 생성
   1. Name: 이름
   2. Replication mode: Push-based
   3. Source resource filter:
      - Name: replication 대상이 될 repository 이름 (ex. library/\*\*)
      - Tag: replication 대상이 될 regpository의 tag (ex. dev)
   4. Destination 레지스트리: 1.2에서 생성한 외부 레지스트리 선택
   5. Destination namespace: push될 이미지의 레지스트리의 네임스페이스
   6. Trigger Mode: Event Based
### 3. 수행여부 확인 (Event based push)
1. 프로젝트에 테스트용 이미지 푸시
2. Administration > Replication > 2에서 생성한 replication rule 선택
3. Executions에서 status succeeded 확인
4. 외부 레지스트리에 테스트 이미지 복사된 것 확인

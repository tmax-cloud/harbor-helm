# Hyperregistry(Harbor) 내/외부 TLS 통신 설정

## 내부 TLS 통신 설정  
### 진단 방법
- 로그를 활용하여 각 파드에 대해 내부 CA가 설정되었는지 확인한다.
    ```
    kubectl logs -n <harbor_namespace> <each_pod>
    ```
- harbor namespace 내 internal TLS에 대한 secret리소스가 있는지 확인한다.
    ```
    kubectl get secret -n <harbor_namespace>
    ```
- 파드 내부에 접속해 `/etc/harbor/ssl/<harbor_component_name>` 위치로 들어가 tls key와 crt가 있는지 확인하고, openssl로 verify한다.
    ```
    kubectl exec -n <harbor_namespace> <harbor_component_pod_name> -it – bash (or sh)
    cd /etc/harbor/ssl/<harbor_component_name>
    openssl x509 -noout -modulus -in tls.crt| openssl md5
    openssl x509 -noout -modulus -in tls.key| openssl md5
    ```
- curl로 파드간 https 통신이 되는지 확인한다.
    ```
    curl -v -k (or --cacert={통신할 파드 내 ca.crt가져오고 그 path입력}) https://<pod_service_ip>
    ```

### 설정방법
- harbor helm chart의 values.yaml에 옵션을 수정하여 내부 TLS 설정

1. internal TLS 활성화
    - internalTLS.enabled: `true`

2. self-signed 인증서를 사용할 경우
    - internalTLS.certSource: `auto`

3. 미리 만들어둔 TLS 시크릿을 사용할 경우
    - internalTLS.certSource: `secret`
    - internalTLS.core.secretName : `<core_secret_name>`
    - internalTLS.jobservice.secretName : `<jobservice_secret_name>`
    - internalTLS.registry.secretName : `<registry_secret_name>`
    - internalTLS.portal.secretName: `<portal_secret_name>`
    - internalTLS.chartmuseum.secretName: `<chartmuseum_secret_name>`
    - internalTLS.trivy.secretName: `<trivy_secret_name>`

4. 미리 만들어둔 tls.crt와 tls.key를 이용할 경우 (권장하지 않음)
* contents: crt, key 내부 내용 자체를 의미 (ex. —begin rsa key— CD153c=...)
    - internalTLS.certSource: `manual`
    - internalTLS.trustCa : `<ca.crt_contents>` 
    (모든 내부 인증서는 해당 ca에서 발급해야 한다.)
    - internalTLS.core.crt : `<core_crt_contents>` 
    - internalTLS.core.key: `<core_key_contents>` 
    - internalTLS.jobservice.crt: `<jobservice_crt_contents>` 
    - internalTLS.jobservice.key: `<jobservice_key_contents>` 
    - internalTLS.registry.crt: `<registry_crt_contents>` 
    - internalTLS.registry.key: `<registry_key_contents>` 
    - internalTLS.portal.crt: `<portal_crt_contents>` 
    - internalTLS.portal.key: `<portal_key_contents>` 
    - internalTLS.chartmuseum.crt: `<chartmuseum_crt_contents>` 
    - internalTLS.chartmuseum.key: `<chartmuseum_key_contents>` 
    - internalTLS.trivy.crt: `<trivy_crt_contents>` 
    - internalTLS.trivy.key: `<trivy_key_contents>` 

### 비고
* Traefik에서 외부 TLS를 처리하고 내부 TLS를 구성했을 경우, 파드 간 통신을 위해 생성한 내부 인증서에 대해 신뢰할 수 있도록 [1] 각 파드의 서비스 리소스 및 [2] 인그레스 리소스에 다음과 같은 어노테이션을 적용해야 한다.
   - self-signed 인증서를 사용한 경우
     traefik.ingress.kubernetes.io/service.serverstransport: insecure@file
   - 인증서를 tmax-cloud 공통 인증서를 사용한 경우
     traefik.ingress.kubernetes.io/service.serverstransport: tmaxcloud@file

* Redis는 `redis://` 프로토콜만으로 통신하고, security(TLS)를 적용한 `rediss://`는 지원하지 않기 때문에 TLS를 적용한 External Redis를 사용하더라도 불가능합니다.

* Database(Postgres)는 Harbor에서 기본적으로 제공하는 Postgres를 사용할 경우 SSL/TLS를 제공하지 않습니다. 따라서 외부에서 SSL/TLS를 적용한 Postgres를 생성하고 Harbor에 연동해야 합니다. 연동할 때에는 [1] 'registry', 'notary_signer', 'notary_server' 이름의 DB를 3개 생성하고, [2] 다음 아래의 옵션을 values.yaml파일에 적용합니다. Harbor v2.0부터 제공하는 Postgres는 v9.6+ 이므로 external postgres 설치 시 버전에 유의하여야 합니다. (최신 Hyperregistry의 postgres 버전은 13.5입니다.)
   - database.type: `external`
   - database.external.host: `<external_postgresql_host>`
   - database.external.port: `<external_postgresql_port>`
   - database.external.username: `postgres`
   - database.external.password: `<external_postgresql_postgres(user)`s password>`
   - database.external.sslmode: `verify-full` or `verify-ca`

## 외부 TLS 통신 구성
### 진단방법
1. ca를 다운받는다.
- self-signed 인증서 혹은 미리 만들어준 TLS 시크릿을 사용할 경우 Harbor api로 인증서를 다운받는다.
   - curl -k -X 'GET' \
  'https://{hyperregistry_domain_name}/api/v2.0/systeminfo/getcert' \
  -H 'accept: application/octet-stream' > ca.crt

- proxy에서 제공하는 인증서를 사용할 경우 해당 인증서를 다운받는다.
  (cert-manager로 생성한 tmaxcloud-ca는 cert-manager namespace내 secret에서 확인할 수 있다.)
    - kubectl get secret -n cert-manager tmaxcloud-ca -o jsonpath="{.data.ca\.crt}" | base64 -d > ca.crt

2. ca를 활용해 curl로 진단한다.
    - curl -v “https://hyperregistry_domain” --cacert {path_to_ca.crt}

### 설정방법
* harbor helm chart의 values.yaml에 옵션을 수정하여 외부 TLS 설정
1. self-signed 인증서를 사용할 경우
  - expose.tls.certSource: `auto`
  - expose.tls.secret.secretName: ""
  - expose.tls.secret.notarySecretName: ""

2. 미리 만들어 둔 TLS 시크릿을 사용할 경우
   - expose.tls.certSource: `secret`
   - expose.tls.secret.secretName: `<secret_name>`
   - expose.tls.secret.notarySecretName: `<secret_name>`
   - caSecretName: `<secret_name>`

3. API Gateway와 같은 프록시에서 제공하는 인증서를 사용할 경우
   - expose.tls.certSource: `none`
   - expose.tls.secret.secretName: ""
   - expose.tls.secret.notarySecretName: ""

### 비고
- Harbor를 구동한 뒤, 신뢰할 수 있는 레지스트리로 등록합니다.
- centos
cp ca.crt /etc/pki/ca-trust/source/anchors
update-ca-trust
- ubuntu
cp ca.crt /usr/local/share/ca-certificates
update-ca-certificates

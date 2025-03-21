# Babpat Cloud - Terraform

이 프로젝트는 **Terraform을 사용하여 Google Cloud Platform(GCP)의 인프라를 코드로 관리**합니다.  
개발(dev), 운영(prod), 공유(shared) 환경을 **워크스페이스 기반으로 분리**하며, **모듈화를 통해 코드 중복을 제거**했습니다.

---

## 1. 초기 설정

### GCP 인증 설정
Terraform이 GCP에 접근하려면 인증이 필요합니다.

#### 방법 1: `gcloud` CLI 사용
```bash
gcloud auth application-default login
```

#### 방법 2: 서비스 계정 키(JSON) 사용
1. GCP 콘솔에서 서비스 계정 키(JSON) 생성
2. `terraform.tfvars`에 경로를 지정

```hcl
# terraform.tfvars 예시
credential_file_path = "your/path/to/service-account.json"
```

---

## 2. 워크스페이스 기반 환경 구성

이 프로젝트는 `terraform workspace`를 활용하여 **dev**, **prod**, **shared** 환경을 분리합니다.

### 2.1 워크스페이스 생성 및 선택

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace new shared

terraform workspace select dev      # 사용하고 싶은 환경 선택
```

---

## 3. Terraform 명령어

### 3.1 초기화
```bash
terraform init
```

### 3.2 현재 변경사항 확인
```bash
terraform plan
```

### 3.3 인프라 적용
```bash
terraform apply
```

### 3.4 리소스 삭제 (현재 워크스페이스에 한함, 주의!)
```bash
terraform destroy
```

---

## 4. 기존 리소스 import

이미 수동으로 생성된 GCP 리소스를 Terraform 상태에 등록하려면 아래 명령어를 사용합니다.

```bash
terraform import "module.compute_dev[0].google_compute_instance.this" "projects/PROJECT/zones/ZONE/instances/INSTANCE_NAME"
```

> **zsh 사용자라면 `[]`가 포함된 주소는 반드시 큰따옴표로 감싸야 합니다!**

---

## 5. 협업 규칙

- `terraform.tfstate`, `.terraform/`, `terraform.tfvars`는 Git에 절대 커밋하지 마세요!
- `.terraform.lock.hcl`은 커밋해서 provider 버전을 고정하세요.
- `terraform plan` → 팀원과 공유 → `terraform apply` 순서를 반드시 지켜주세요.

---

## 6. 문제 해결 가이드

### 예상치 못한 변경 감지 시
```bash
terraform refresh
```
상태 파일과 실제 인프라를 동기화합니다.

### 계속 변경사항이 발생하는 경우
이미 존재하는 리소스를 Terraform 상태에 등록하세요:
```bash
terraform import "..." "..."
```

### 리소스를 삭제하지 못하게 보호
```hcl
lifecycle {
  prevent_destroy = true
}
```

### description 변경으로 리소스가 destroy되는 경우 방지
```hcl
lifecycle {
  ignore_changes = ["description"]
}
```
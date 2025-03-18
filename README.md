# Babpat Cloud - Terraform

이 프로젝트는 **Terraform을 사용하여 Google Cloud Platform(GCP)의 인프라를 관리**합니다.

## 1. 초기 설정 (최초 실행 시 필요)
이 프로젝트를 처음 Git에서 Clone한 후, 다음 단계를 수행하세요.

### **GCP 인증 설정**
Terraform을 실행하기 위해 GCP 인증이 필요합니다. 다음 명령어로 인증 파일을 설정하세요.

```sh
gcloud auth application-default login
```

또는, 개인 GCP 서비스 계정 키(JSON)를 생성하고 `terraform.tfvars`에 추가하세요.
```sh
echo '{ "type": "service_account", "project_id": "your-project-id", ... }' > terraform.tfvars
```

## 2. Terraform 실행 방법

### 2.1 Terraform 초기화
최초 실행 시 Terraform을 초기화해야 합니다.
```sh
terraform init
```

### 2.2 현재 상태 확인
Terraform이 현재 GCP 리소스와 상태를 비교하여 어떤 변경이 필요한지 확인합니다.
```sh
terraform plan
```

### 2.3 변경 사항 적용 미리보기
GCP에 Terraform이 정의한 인프라를 반영의 결과를 미리봅니다.
```sh
terraform plan
```

### 2.4 변경 사항 적용하기
```sh
terraform apply
```
내용을 확인하고 yes를 입력하여 적용 가능합니다.  
실제 인프라 구조가 바뀔 수 있으므로 주의!

### 2.5 리소스 삭제 (주의! 전체 삭제됨)
```sh
terraform destroy
```
이 명령어는 모든 리소스를 삭제하므로 주의!!!!!!

## 3. 팀원 협업 규칙
- `terraform.tfstate` 및 `terraform.tfvars` 파일은 **Git에 추가하지 마세요!**
- `.terraform.lock.hcl` 파일을 Git에 포함하여 **모든 팀원이 같은 Provider 버전을 사용하도록 유지**하세요.
- 새로운 인프라를 추가할 경우 `terraform plan`을 먼저 실행하여 변경 사항을 확인하세요.
- 변경 적용 전, 팀원들과 공유하고 협의 후 실행하세요.

## 4. Troubleshooting (문제 해결)
### Terraform이 예상치 못한 변경을 감지함
```sh
terraform plan
```
출력된 변경 사항을 확인하고, `terraform refresh`를 실행하여 최신 상태를 반영하세요.

### `terraform apply` 후에도 변경 사항이 계속 발생함
- `terraform state list`로 현재 상태를 확인하세요.
- 필요하면 `terraform import`를 실행하여 기존 리소스를 Terraform 상태에 추가하세요.
```sh
terraform import google_compute_firewall.babpat_mysql projects/YOUR_PROJECT/global/firewalls/babpat-mysql
```

### Terraform이 특정 리소스를 삭제하려고 함
`lifecycle { prevent_destroy = true }` 옵션을 추가하여 보호할 수 있습니다.
```hcl
resource "google_compute_instance" "example" {
  ...
  lifecycle {
    prevent_destroy = true
  }
}
```

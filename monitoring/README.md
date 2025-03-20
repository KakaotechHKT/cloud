# 📊 Babpat Cloud Monitoring  

Babpat Cloud의 모니터링 시스템을 자동으로 배포하는 Ansible 플레이북입니다.  
이 프로젝트는 **Prometheus, Alertmanager, Grafana(데이터 소스 연결만 포함)**를 구성합니다.  

---

> ⚠️ **주의:**  
> - `*.example` 파일들은 예제이며, 실제 배포를 위해서는 원본 파일을 수정하여 `.example` 확장자를 제거해야 합니다.  
> - 원본 설정 파일(`prometheus.yml`, `alertmanager.yml`, `inventory.ini` 등)은 Git에서 관리되지 않도록 `.gitignore`에 추가되어 있습니다.  

---

## 🚀 **배포 방법**  

### 1️⃣ **필수 도구 설치**  

모니터링 시스템을 배포하기 위해 다음 패키지가 필요합니다.  

```sh
sudo apt update && sudo apt install -y ansible docker.io
```


2️⃣ 설정 파일 준비

예제 파일을 복사하여 실제 환경에 맞게 수정해야 합니다.

```sh
cp prometheus.yml.example prometheus.yml
cp alertmanager.yml.example alertmanager.yml
cp ansible.cfg.example ansible.cfg
cp inventory.ini.example inventory.ini
```

필요에 따라 alert-rules.yml 및 grafana/provisioning/datasources/datasources.yml도 수정 후 사용하세요.

3️⃣ Ansible을 이용한 모니터링 배포

배포 전에 inventory.ini 파일에서 대상 서버 정보를 확인하세요.
그 후 다음 명령어를 실행하면 **Prometheus, Alertmanager, Grafana(데이터 소스만 연결됨)** 가 자동으로 배포됩니다.

```sh
ansible-playbook -i inventory.ini deploy_monitoring.yml
```

✅ 정상적으로 배포되면 다음 서비스들이 실행됩니다.
	•	Prometheus: http://<server-ip>:9090
	•	Alertmanager: http://<server-ip>:9093
	•	Grafana: http://<server-ip>:3000

💡 Grafana 기본 로그인 정보
	•	ID: admin
	•	PW: admin (최초 로그인 후 변경 필수)

🛠 모니터링 서비스 관리

서비스 상태를 확인하려면 다음 명령어를 사용할 수 있습니다.

```sh
# Prometheus 상태 확인
docker logs prometheus --tail 50

# Alertmanager 상태 확인
docker logs alertmanager --tail 50

# Grafana 상태 확인
docker logs grafana --tail 50
```

📌 FAQ (자주 묻는 질문)

❓ 1. 배포 후에도 Prometheus/Grafana 페이지가 열리지 않아요.

✅ 방화벽 설정을 확인하세요. 포트가 열려 있는지 체크합니다.
```sh
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw allow 9093/tcp  # Alertmanager
sudo ufw allow 3000/tcp  # Grafana
```
❓ 2. Alertmanager가 알람을 보내지 않아요.

✅ alertmanager.yml 설정을 확인하고, 올바른 웹훅 URL이 설정되었는지 체크하세요.
✅ 설정 변경 후에는 Alertmanager를 다시 로드합니다.
```sh
docker restart alertmanager
```


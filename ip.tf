# --------------------------------------------------
# 고정 IP
# --------------------------------------------------
resource "google_compute_address" "eip_dev" {
  name   = "babpat-eip-dev"
  region = "asia-northeast3"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_address" "eip_mysql" {
  name   = "babpat-eip-mysql"
  region = "asia-northeast3"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_address" "eip_prod" {
  name   = "babpat-eip-prod"
  region = "asia-northeast3"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_address" "eip_monitoring" {
  name   = "monitoring-eip"
  region = "asia-northeast3"
  lifecycle {
    ignore_changes = [description]
  }
}
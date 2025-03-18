# --------------------------------------------------
# 고정 IP
# --------------------------------------------------
resource "google_compute_address" "eip_dev" {
  name   = "babpat-eip-dev"
  region = "asia-northeast3"
  address = "35.216.100.31"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_address" "eip_mysql" {
  name   = "babpat-eip-mysql"
  region = "asia-northeast3"
  address = "35.216.12.233"
  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_address" "eip_prod" {
  name   = "babpat-eip-prod"
  region = "asia-northeast3"
  address = "35.216.75.157"
  lifecycle {
    ignore_changes = [description]
  }
}

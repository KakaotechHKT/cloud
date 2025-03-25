resource "google_service_account" "this" {
  account_id   = var.name
  display_name = var.display_name
}

resource "google_project_iam_member" "this" {
  for_each = { for role in var.roles : role => role }

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}
output "instance_id" {
  description = "ID of the compute instance"
  value       = google_compute_instance.this.id
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.this.name
}

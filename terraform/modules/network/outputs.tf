output "network_id" {
  description = "The network ID"
  value       = data.google_compute_network.default.id
}

output "subnetwork_id" {
  description = "The subnetwork ID"
  value       = data.google_compute_subnetwork.default.id
}

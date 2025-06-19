output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.dev.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster API"
  value       = google_container_cluster.dev.endpoint
}

output "cluster_ca_certificate" {
  description = "CA certificate for the GKE cluster"
  value       = google_container_cluster.dev.master_auth[0].cluster_ca_certificate
}

output "yb_snapshots_bucket" {
  description = "GCS bucket for YugabyteDB snapshots"
  value       = google_storage_bucket.yb_snapshots.name
}

output "dr_cluster_name" {
  description = "Name of the DR GKE cluster"
  value       = google_container_cluster.dr.name
}

output "dr_cluster_endpoint" {
  description = "Endpoint for the DR GKE cluster API"
  value       = google_container_cluster.dr.endpoint
}

output "dr_cluster_ca_certificate" {
  description = "CA certificate for the DR GKE cluster"
  value       = google_container_cluster.dr.master_auth[0].cluster_ca_certificate
}

output "stage_cluster_name" {
  description = "Name of the Stage GKE cluster"
  value       = google_container_cluster.stage.name
}

output "stage_cluster_endpoint" {
  description = "Endpoint for the Stage GKE cluster API"
  value       = google_container_cluster.stage.endpoint
}

output "stage_cluster_ca_certificate" {
  description = "CA certificate for the Stage GKE cluster"
  value       = google_container_cluster.stage.master_auth[0].cluster_ca_certificate
} 
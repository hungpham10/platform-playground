output "network" {
  description = "The VPC network object which has been defined"
  value       = var.is_mocking? data.google_compute_network.vpc.*.name: google_compute_network.vpc.*.name
}

output "subnetwork" {
  description = "The list of sub-networks which are created"
  value       = var.is_mocking? tolist("${data.google_compute_subnetwork.subnetwork}"): concat(tolist("${google_compute_subnetwork.public.*.name}"), tolist("${google_compute_subnetwork.private.*.self_link}"))
}

output "count" {
  description = "The counter which is used to show number of public and private subnetwork"
  value       = {
    public  = length(google_compute_subnetwork.public)
    private = length(google_compute_subnetwork.private)
  }
}

terraform {
  backend "gcs" {
    bucket  = "k8s-the-hard-way-2022"
    prefix  = "terraform/state"
  }
}
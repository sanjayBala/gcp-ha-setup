provider "google" {
  credentials = file("service-account.json")
  project     = "alation-task"
  region      = "us-west1"
}

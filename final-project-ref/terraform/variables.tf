locals {
  data_lake_bucket = "datalake"
}

variable "credentials" {
  description = "My Credentials"
  default     = "gcp_creds.json"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}


variable "project" {
  description = "Project"
  default     = "kestra-sandbox-486219"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default     = "us-south1"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default     = "us-south1"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "preproject_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "preproject-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

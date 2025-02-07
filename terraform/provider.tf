terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.8"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net" 
    region     = "ru-central1"

    bucket     = "tf-state"
    key        = "terraform-momo-cluster.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true

    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gg6kegpjk3v90bl84u/etnq0sdeg5bcons0645a"
    dynamodb_table = "tf-state"
  }
}

provider "yandex" {
  cloud_id                 = ""
  folder_id                = ""
}
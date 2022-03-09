variable "buildkite_token" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type    = string
  default = "elastic"
}

terraform {
  required_providers {
    buildkite = {
      source  = "buildkite/buildkite"
      version = "0.6.0"
    }

    github = {
      source  = "integrations/github"
      version = "4.8.0"
    }

  }

  backend "gcs" {
    bucket = "elastic-kibana-ci-kibana-pipelines-tfstate"
    prefix = "terraform/state"
  }
}

provider "buildkite" {
  api_token    = var.buildkite_token
  organization = "elastic"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

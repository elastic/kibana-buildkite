locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  image_id = "kb-ubuntu-${local.timestamp}"
}

source "googlecompute" "bk_dev" {
  disk_size           = 75
  disk_type           = "pd-ssd"
  image_description   = "${local.image_id}"
  image_family        = "kb-ubuntu"
  image_name          = "${local.image_id}"
  machine_type        = "n1-standard-8"
  project_id          = "elastic-kibana-ci"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "packer"
  zone                = "us-central1-a"
}

build {
  sources = ["source.googlecompute.bk_dev"]

  provisioner "file" {
    destination = "/tmp/bk-startup.sh"
    source      = "startup.sh"
  }

  provisioner "file" {
    destination = "/tmp/bk-hooks"
    source      = "hooks"
  }

  provisioner "file" {
    destination = "/tmp/ecctl.json"
    source      = "ecctl.json"
  }

  provisioner "file" {
    destination = "/tmp/elastic-agent.yml"
    source      = "elastic-agent.yml"
  }

  provisioner "shell" {
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "setup.sh"
  }

}

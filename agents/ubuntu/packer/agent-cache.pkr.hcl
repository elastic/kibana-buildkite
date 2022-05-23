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
  machine_type        = "n2-standard-8"
  project_id          = "elastic-kibana-ci"
  source_image_family = "kb-ubuntu-base"
  ssh_username        = "packer"
  zone                = "us-central1-a"
}

build {
  sources = ["source.googlecompute.bk_dev"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "shell" {
    execute_command  = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    script           = "cache.sh"
  }

}

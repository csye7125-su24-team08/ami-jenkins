packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name                = "ubuntu-ami-${replace(timestamp(), ":", "-")}"
  source_ami              = var.source_ami
  ssh_username            = "ubuntu"
  instance_type           = var.instance_type
  region                  = var.region
  ami_virtualization_type = "hvm"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "file" {
    source      = "./Caddyfile"
    destination = "~/Caddyfile"
  }
  provisioner "file" {
    source      = "./scripts/test_job.groovy"
    destination = "~/test_job.groovy"
  }
  provisioner "file" {
    source      = "./scripts/new_user.groovy"
    destination = "~/new_user.groovy"
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins.sh",
      "scripts/caddy.sh",
      "scripts/create_test_job.sh",
      "scripts/create_users.sh"
    ]
  }
}

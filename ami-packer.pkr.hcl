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

  provisioner "shell" {
    inline = [
      "sudo mkdir -p ~/jenkins-scripts"
    ]
  }

  provisioner "file" {
    source      = "./Caddyfile"
    destination = "~/Caddyfile"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/new_user.groovy"
    destination = "~/jenkins-scripts/new_user.groovy"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/gh-creds.groovy"
    destination = "~/jenkins-scripts/gh-creds.groovy"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/docker-creds.groovy"
    destination = "~/jenkins-scripts/docker-creds.groovy"
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins.sh",
      "scripts/caddy.sh",
      "scripts/create_users.sh"
    ]
  }
}

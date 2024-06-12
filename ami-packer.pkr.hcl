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
    source      = "./tokens.txt"
    destination = "~/tokens.txt"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-jcasc-setup.sh"
    destination = "~/jenkins-jcasc-setup.sh"
  }
  provisioner "file" {
    source      = "./jenkins-config/casc.yaml"
    destination = "~/casc.yaml"
  }
  provisioner "file" {
    source      = "./scripts/static-site-seedjob.groovy"
    destination = "~/static-site-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/helm-webapp-seedjob.groovy"
    destination = "~/helm-webapp-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/webapp-seedjob.groovy"
    destination = "~/webapp-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/terraform-seedjob.groovy"
    destination = "~/terraform-seedjob.groovy"
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins-jcasc-setup.sh",
      "scripts/caddy.sh"
    ]
  }
}

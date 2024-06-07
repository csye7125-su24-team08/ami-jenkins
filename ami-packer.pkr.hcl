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
    source      = "./scripts/casc.yaml"
    destination = "~/casc.yaml"
  }
  provisioner "file" {
    source      = "./scripts/plugins.txt"
    destination = "~/plugins.txt"
  }
  provisioner "shell" {
    inline = [
      "sudo mkdir -p ~/jenkins-scripts",
      "export GH_ACCESS_TOKEN=$(head -n 1 tokens.txt)",
      "export DOCKERHUB_ACCESS_TOKEN=$(tail -n 1 tokens.txt)",
      "cp ~/plugins.txt ~/jenkins-scripts/plugins.txt",
    ]
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins-jcasc-setup.sh",
      "scripts/caddy.sh"
    ]
  }
}

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
    source      = "./scripts/jenkins-scripts/new_user.groovy"
    destination = "~/new_user.groovy"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/gh-creds.groovy"
    destination = "~/gh-creds.groovy"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/docker-creds.groovy"
    destination = "~/docker-creds.groovy"
  }
  provisioner "file" {
    source      = "./scripts/jenkins-scripts/docker-image-job.groovy"
    destination = "~/docker-image-job.groovy"
  }
  provisioner "shell" {
    inline = [
      "sudo mkdir -p ~/jenkins-scripts",
      "sudo mv ~/new_user.groovy ~/jenkins-scripts/new_user.groovy",
      "sudo mv ~/gh-creds.groovy ~/jenkins-scripts/gh-creds.groovy",
      "sudo mv ~/docker-creds.groovy ~/jenkins-scripts/docker-creds.groovy",
      "sudo mv ~/docker-image-job.groovy ~/jenkins-scripts/docker-image-job.groovy"
    ]
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins.sh",
      "scripts/caddy.sh",
      "scripts/job-setup.sh",
      "scripts/create_users.sh"
    ]
  }
}

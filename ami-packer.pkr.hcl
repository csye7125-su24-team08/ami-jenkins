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
  // launch_block_device_mappings {
  //   no_device   = true
  //   encrypted   = false
  //   volume_size = 30
  //   device_name = "/dev/sda1"
  // }
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
    source      = "./scripts/helm-webapp-processor-seedjob.groovy"
    destination = "~/helm-webapp-processor-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/helm-webapp-consumer-seedjob.groovy"
    destination = "~/helm-webapp-consumer-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/webapp-processor-seedjob.groovy"
    destination = "~/webapp-processor-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/webapp-consumer-seedjob.groovy"
    destination = "~/webapp-consumer-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/terraform-seedjob.groovy"
    destination = "~/terraform-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/infra-aws-seedjob.groovy"
    destination = "~/infra-aws-seedjob.groovy"
  }
  provisioner "file" {
    source      = "./scripts/helm-eks-autoscaler-seedjob.groovy"
    destination = "~/helm-eks-autoscaler-seedjob.groovy"
  }
  provisioner "shell" {
    scripts = [
      "scripts/jenkins-jcasc-setup.sh",
      "scripts/caddy.sh"
    ]
  }
}

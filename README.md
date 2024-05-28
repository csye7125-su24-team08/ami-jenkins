# AMI-Jenkins

## Overview:
This project automates the creation of an Amazon Machine Image (AMI) with Jenkins and a reverse proxy using Caddy, utilizing Packer.

### Instructions:
To utilize this project, follow the steps below:

1. Initialize Packer configuration:
   ```bash
   packer init .
   ```

2. Format Packer configuration (optional):
   ```bash
   packer fmt
   ```

3. Validate Packer configuration:
   ```bash
   packer validate .
   ```

4. Build the AMI using Packer:
   ```bash
   packer build .
   ```

These commands will set up and execute the Packer configuration, resulting in the creation of a custom AMI with Jenkins and Caddy configured as a reverse proxy.

variable "name" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
    ami_name = "${var.name} {{timestamp}}"
    instance_type = "t2.micro"
    region = "${var.region}"
    ami_description = "from {{.SourceAMI}}"
    
    source_ami_filter {
        filters = {
        virtualization-type = "hvm"
        name = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
        root-device-type = "ebs"
        }
        owners = ["099720109477"]
        most_recent = true
    }
    ssh_username = "ubuntu"   
    tags = {
        OS_Version = "Ubuntu"
        Release = "Latest"
        Base_AMI_ID = "{{ .SourceAMI }}"
        Base_AMI_Name = "{{ .SourceAMIName }}"
    }
}

build {
    sources = [
        "source.amazon-ebs.ubuntu"
    ]
    provisioner "ansible" {
        playbook_file = "ansible/playbook.yml"
        galaxy_file = "ansible/requirements.yml"
        user = "ubuntu"
        ansible_env_vars = [
            "ANSIBLE_HOST_KEY_CHECKING=False"
        ]
        extra_arguments = [
            "--extra-vars",
            "ansible_python_interpreter=/usr/bin/python3",
            "-vvvv"
        ]
    }
}
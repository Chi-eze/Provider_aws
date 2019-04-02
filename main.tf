# ----------------Configure aws Provider---------------------------------#

provider "aws" {
    region = "eu-west-1"
}

# -----------------Building an EC2 instance----------------
resource "aws_instance" "supermax" {
    ami = "ami-07683a44e80cd32c5"
    instance_type =  "t2.micro"    
    key_name = 
    vpc_security_group_ids = ["${aws_security_group.web-access.id}"]
    

    tags = {
        Name = "Web-Serve"
    }         


variable "server_port" {
    description = "The port used for HTTP requests"
    default = 22
}

resource "aws_security_group" "web-access" {
    name = "web-access"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}" 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

            tags {
        Name = "Test-exec"
    
    }
   
  }

}


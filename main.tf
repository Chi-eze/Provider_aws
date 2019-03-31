# ----------------Configure aws Provider---------------------------------#

provider "aws" {
    region = "eu-west-1"
}

# -----------------Building an EC2 instance----------------
resource "aws_instance" "supermax" {
    ami = "ami-07683a44e80cd32c5"
    instance_type =  "t2.micro"    

    tags = {
        Name = "Terraform_test"
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
}

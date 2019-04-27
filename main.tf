
#----------------------variables-----------------------


#output "public_ip" {
#  value = "${aws_instance.supermax.public_ip}"
#}

output "elb_dns_name" {
  value = "${aws_elb.elb-ai.dns_name}"
}
data "aws_availability_zones" "all" {}



# ----------------Configure aws Provider---------------------------------#

provider "aws" {
    region = "eu-west-1"
}


# -----------------Building an EC2 instance----------------
resource "aws_instance" "supermax" {
    ami = "ami-07683a44e80cd32c5"
    instance_type = "t2.micro"    
    user_data = <<-EOF
                #!/bin/bash
                echo "hello,world" > index.html
                nohup busybox httpd -f -p "${var.webaccess}" &
                EOF
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.web-access.id}"]
    tags = {
        Name = "Web-Serve"
    }         

}
#--------------------launch_Configuration---------------------

resource "aws_launch_configuration" "lc_ai" {
    name = "cluster_temp"
    image_id = "ami-07683a44e80cd32c5"
    instance_type = "m4.4xlarge"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.web-access.id}"]
    user_data = <<-EOF
                #!/bin/bash
                yum update
                yum install httpd -y
                cd /var/www/html/
                touch  index.html
                echo  "THIS IS A WEB HUB" > index.html
                chkconfig on
                EOF

                lifecycle {
                    create_before_destroy = true 
                }
  
}

  

#--------------------------security..............................

resource "aws_security_group" "web-access" {
    name = "web-connect"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}" 
        protocol = "tcp"
        cidr_blocks = [ "${var.cidr_blocks}"]
    }
    ingress {
        from_port = "${var.webaccess}"
        to_port = "${var.webaccess}"
        protocol = "tcp"
        cidr_blocks = [ "${var.cidr_blocks}"]
    }

            tags {
        Name = "Test-exec"
     }

    lifecycle {
        create_before_destroy = true 
    }   
  }
resource "aws_security_group" "elb_sg" {

    name = "elb_security"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.cidr_blocks}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.cidr_blocks}"]
    }
  
}






   

resource "aws_autoscaling_group" "asg_ai" {
    min_size = 2
    max_size = 6   
    launch_configuration = "${aws_launch_configuration.lc_ai.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    load_balancers = ["${aws_elb.elb-ai.id}"]
    health_check_type = "ELB"
    tag {
        key = "Name"
        value = "terraform-asg-example05"
        propagate_at_launch = true

    }

  
}


#-------------------------ELB-------------------------------

resource "aws_elb" "elb-ai" {
    name = "elb"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb_sg.id}"]

    listener {
        lb_port = 80
        lb_protocol ="http"
        instance_port = "${var.webaccess}"
        instance_protocol = "http"
    }
    health_check  {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "Http:${var.webaccess}/"
    }

  
}

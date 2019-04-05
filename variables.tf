variable "key_name" {}
variable "cidr_blocks" {
    type 
    = "list"
    default=[]
}
variable "server_port" {
    description = "The port used for ssh access"
    default = ""
 
}

variable "webaccess" {
    description = "The port used for HTTP request"
    default = ""
  
}




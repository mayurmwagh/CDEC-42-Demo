variable "engine" {
    type = string
    # default = "mysql"
}

variable "engine_version" {
    type = string 
    # default = "8.0"
  
}

variable "instance_class" {
    type = string
    # default = "db.t3.micro"
}

variable "username" {
    type = string
    # default = "admin"
}
variable "password" {
    type = string
    # default = "Redhat123"
}
variable "parameter_group_name" {
    type = string
    # default = "default.mysql8.0"
}

variable "publicly_accessible" {
    type = bool
    # default = true
}

variable "skip_final_snapshot" {
    type = bool 
    # default = true
  
}

# variable "namespace" {
#     type = string
#     # default = "Dev"
  
# }

variable "db_subnet_group_name" {
    type = string
    # default = "default-db-subnet-group-1"
  
}
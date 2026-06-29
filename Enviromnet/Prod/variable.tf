# 1.Metadata Variable Declarations

variable "project_name" {type   = string }
variable "environment" {type = string}
variable "managed_by" {type = string}

# Infrastructure Variable Declarations

variable "aws_region" {type = string}
variable "hub_cidr" { type = string}
variable "hub_public_subnet_cidr" {type = string}

variable "spoke1_cidr" {type = string}
variable "spoke1_private_subnet_cidr" {type = string}

variable "spoke2_cidr" {type = string}
variable "spoke2_private_subnet_cidr" {type = string}
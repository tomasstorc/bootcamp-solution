variable "tags" {
  type = map(string)
  default = {
    "owner"     = "storctom"
    "terraform" = "true"
  }
}

variable "naming-prefix" {
  type    = string
  default = "ts-test-bootcamp"
}

variable "location" {
  type    = string
  default = "Sweden Central"
}

variable "user_id" {
  type = string
}

variable "user_name" {
  type = string
}

variable "script_uri" {
  type = string
}
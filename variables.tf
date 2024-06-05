variable "tags" {
  type = map(string)
  default = {
    "owner" = "storctom"
    "terraform" = "true"
  }
}
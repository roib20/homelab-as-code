variable "connection" {
  description = "SSH connection parameters for provisioning"
  type = object({
    type  = optional(string, "ssh")
    host  = string
    user  = string
    agent = optional(bool, true)
  })
}

resource "terraform_data" "qemu-guest-agent" {
  connection {
    type        = try(var.connection.type, "ssh")
    host        = try(var.connection.host, null)
    user        = try(var.connection.user, null)
    agent       = try(var.connection.agent, true)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade --assume-yes && sudo apt-get install --assume-yes qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl reboot",
    ]
  }
}

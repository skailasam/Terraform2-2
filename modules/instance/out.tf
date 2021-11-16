output "instance_id" {
  value = aws_instance.instance.*.id
}

output "server_ip" {
  value = "${join(",",aws_instance.instance.*.public_ip)}"
}

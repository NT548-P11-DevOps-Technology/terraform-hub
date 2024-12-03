# # Generate inventory file from terraform state
# resource "local_file" "inventory" {
#   content = templatefile("./templates/inventory.yml.tftpl",
#     {
#       bastion_ip        = aws_instance.bastion_instance[0].private_ip,
#       bastion_id        = aws_instance.bastion_instance[0].id,
#       monitoring_fe_ip  = aws_instance.monitoring_fe_instance[0].private_ip,
#       monitoring_fe_id  = aws_instance.monitoring_fe_instance[0].id,
#       monitoring_be_ip  = aws_instance.monitoring_be_instance[0].private_ip,
#       monitoring_be_id  = aws_instance.monitoring_be_instance[0].id,
#       cluster_ip        = [for instance in aws_instance.k3s_instance : instance.private_ip],
#       cluster_id        = [for instance in aws_instance.k3s_instance : instance.id],
#     }
#   )
#   filename = "${path.root}/inventory.yml"
# }

# resource "null_resource" "set_up_openvpn_server" {
#   depends_on = [ aws_instance.bastion_instance ]

#   triggers = {
#     "always_run" = timestamp()
#   }

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     host        = aws_instance.bastion_instance[0].public_ip
#     private_key = file("${path.root}/${var.aws_key_name}.pem")
#     agent = false
#   }

#   provisioner "file" {
#     source      = "./scripts/openvpn-install.sh"
#     destination = "/home/ubuntu/openvpn-install.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [ 
#       "chmod +x /home/ubuntu/openvpn-install.sh",
#       "sudo /home/ubuntu/openvpn-install.sh"
#      ]
#   }
# }
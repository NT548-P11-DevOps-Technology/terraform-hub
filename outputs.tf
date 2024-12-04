output "gateway_ip" {
  value = module.instances.instances["gateway"].public_ip
}

# output "load_balancer" {
#   value = module.load_balancer.load_balancer_dns_name
# }
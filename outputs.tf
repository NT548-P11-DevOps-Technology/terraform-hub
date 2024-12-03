output "gateway_ip" {
  value = module.instances.instances["gateway"].public_ip
}

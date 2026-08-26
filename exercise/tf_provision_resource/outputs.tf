output "instance_ips" {
  description = "Elastic IP of each provisioned machine."
  value = {
    for name, eip in aws_eip.machine : name => eip.public_ip
  }
}

# Ready to redirect straight into machines.txt (see docs/03-compute-resources.md):
#   terraform output -raw machines_txt > machines.txt
output "machines_txt" {
  description = "Machine database in the IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET format used by docs/03-compute-resources.md."
  value = join("\n", [
    for name, cfg in var.machines :
    trimspace(join(" ", compact([
      aws_eip.machine[name].public_ip,
      "${name}.kubernetes.local",
      name,
      try(cfg.pod_subnet, ""),
    ])))
  ])
}

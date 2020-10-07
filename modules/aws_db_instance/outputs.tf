output "instance_id" {
  value       = join("", aws_db_instance.default.*.id)
  description = "ID of the instance"
}

output "instance_arn" {
  value       = join("", aws_db_instance.default.*.arn)
  description = "ARN of the instance"
}

output "instance_endpoint" {
  value       = join("", aws_db_instance.default.*.endpoint)
  description = "DNS Endpoint of the instance"
}

output "parameter_group_id" {
  value       = join("", aws_db_parameter_group.default.*.id)
  description = "ID of the Parameter Group"
}

output "vpc" {
  value = data.aws_vpcs.selected.ids
}

output "subnets" {
  value = data.aws_subnet_ids.subnets.*.ids
}

// output "security_group" {
//   value = data.aws_security_groups.sg_info.*.ids
// }
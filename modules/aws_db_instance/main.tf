provider "aws" {
  region = var.region
}

data "aws_vpcs" "selected" {
  filter {
    name    = "tag:Name"
    values  = [var.vpc_filter_name]
  }
}

data "aws_vpc" "cluster" {
  count = length(data.aws_vpcs.selected.ids)
  id    = tolist(data.aws_vpcs.selected.ids)[count.index]
}

data "aws_subnet_ids" "subnets" {
  count = length(data.aws_vpcs.selected.ids)
  vpc_id = data.aws_vpc.cluster[count.index].id
}

resource "aws_db_instance" "default" {
  count                       = length(data.aws_vpcs.selected.ids)
  identifier                  = var.db_instance_name
  name                        = var.database_name
  username                    = var.database_user
  password                    = var.database_password
  port                        = var.database_port
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.storage_encrypted
  kms_key_id                  = var.kms_key_arn
  // vpc_security_group_ids      = compact(concat(var.associate_security_group_ids))
  ca_cert_identifier          = var.ca_cert_identifier
  db_subnet_group_name        = join("", aws_db_subnet_group.default.*.name)
  parameter_group_name        = var.parameter_group_name
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  tags                        = var.tags
  deletion_protection         = var.deletion_protection
  final_snapshot_identifier   = length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : var.db_instance_name

  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  depends_on = [aws_db_parameter_group.default]
}

resource "aws_db_parameter_group" "default" {
  name   = var.parameter_group_name
  family = var.db_parameter_group
  tags   = var.tags

  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

resource "aws_db_subnet_group" "default" {
  count      = length(data.aws_vpcs.selected.ids)
  name       = var.db_subnet_group_name
  subnet_ids = data.aws_subnet_ids.subnets[count.index].ids
  tags       = var.tags
}
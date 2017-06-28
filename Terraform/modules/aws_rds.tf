#
# RDS Databases
#
resource "aws_db_instance" "internal" {
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "9.6.1"

  instance_class    = "db.t2.medium"
  availability_zone = "sa-east-1a"

  identifier                = "internal"
  final_snapshot_identifier = "internal"
  username                  = "root_internal"
  password                  = "Alv1C0o82KWLC4p6SiRj"
  port                      = "5432"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.global.security_groups_all_outbound_id}",
    "${data.terraform_remote_state.global.security_groups_postgres_inbound_id}",
  ]

  parameter_group_name        = "${aws_db_parameter_group.internal.id}"
  storage_type                = "gp2"
  multi_az                    = false
  publicly_accessible         = false
  storage_encrypted           = false
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  backup_retention_period     = 7
  backup_window               = "03:20-03:50"
  maintenance_window          = "wed:04:30-wed:05:00"
  apply_immediately           = false

  tags {
    Name        = "aws_db_instance_internal"
    Environment = "global"
    Project     = "internal"
    Creator     = "terraform"
  }
}

resource "aws_db_instance" "internal-rep01" {
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "9.6.1"

  instance_class    = "db.t2.medium"
  availability_zone = "sa-east-1a"

  identifier                = "internal-rep01"
  final_snapshot_identifier = "internal-rep01"
  username                  = "root_internal"
  port                      = "5432"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.global.security_groups_all_outbound_id}",
    "${data.terraform_remote_state.global.security_groups_postgres_inbound_id}",
  ]

  replicate_source_db = "${aws_db_instance.internal.id}"

  parameter_group_name        = "${aws_db_parameter_group.internal.id}"
  storage_type                = "gp2"
  multi_az                    = false
  publicly_accessible         = false
  storage_encrypted           = false
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  backup_retention_period     = 0
  maintenance_window          = "wed:04:30-wed:05:00"
  apply_immediately           = false

  tags {
    Name        = "aws_db_instance_internal-rep01"
    Environment = "global"
    Project     = "internal"
    Creator     = "terraform"
  }
}

resource "aws_db_parameter_group" "internal" {
  name   = "internal-postgres96"
  family = "postgres9.6"

  parameter {
    name  = "log_min_duration_statement"
    value = "200"
  }
}


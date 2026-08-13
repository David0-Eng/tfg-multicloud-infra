data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Instance role: the VM reads its secret from SSM with no credentials on disk.
resource "aws_iam_role" "app" {
  count = var.discord_webhook_param != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Least privilege: read exactly one parameter, nothing else.
resource "aws_iam_role_policy" "read_webhook_param" {
  count = var.discord_webhook_param != "" ? 1 : 0
  name  = "read-discord-webhook-parameter"
  role  = aws_iam_role.app[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ssm:GetParameter"
      Resource = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.discord_webhook_param}"
    }]
  })
}

resource "aws_iam_instance_profile" "app" {
  count = var.discord_webhook_param != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-app-profile"
  role  = aws_iam_role.app[0].name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = var.discord_webhook_param != "" ? aws_iam_instance_profile.app[0].name : null

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  # Require IMDSv2: blocks SSRF-style credential theft via the metadata service.
  metadata_options {
    http_tokens = "required"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    stack_repo_url        = var.stack_repo_url
    discord_webhook_param = var.discord_webhook_param
    aws_region            = data.aws_region.current.region
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-app"
    Project     = var.project_name
    Environment = var.environment
  }
}

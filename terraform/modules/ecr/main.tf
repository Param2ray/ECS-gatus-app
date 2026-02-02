resource "aws_ecr_repository" "gatus_app" {
  name = var.repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}



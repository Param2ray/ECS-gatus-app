resource "aws_ecr_repository" "gatus_app" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

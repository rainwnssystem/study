resource "aws_kms_key" "key" {
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "key" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.key.key_id
}
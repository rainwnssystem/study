resource "aws_kms_key" "ebs_csi" {
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "ebs_csi" {
  name          = "alias/${var.project_name}-ebs-csi-key"
  target_key_id = aws_kms_key.ebs_csi.key_id
}
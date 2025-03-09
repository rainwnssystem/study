resource "aws_kms_key" "ebs_csi" {
  deletion_window_in_days = 7
}
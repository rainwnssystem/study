resource "github_repository" "myapp" {
  name        = "${var.project_name}-myapp"
  description = "My awesome myapp code"

  visibility = "public"
}
resource "github_repository" "frontend" {
  name        = "${var.project_name}-frontend-code"
  visibility = "public"
}

resource "github_repository" "backend" {
  name        = "${var.project_name}-backend-code"
  visibility = "public"
}
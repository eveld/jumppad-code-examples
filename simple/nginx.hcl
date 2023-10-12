// Nginx container that listens on port 80
resource "container" "nginx" {
  image {
    name = "nginx:mainline-alpine3.18-slim"
  }

  resources {
    memory = 256
  }

  port {
    local = 80
    remote = 80
    host = 80
  }
}
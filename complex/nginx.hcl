variable "name" {
  default = "instruqt"
}

// Create a custom index.html file
// that uses a variable to change a name
resource "template" "index_html" {
  source = file("files/index.html")
  destination = "${data("nginx")}/index.html"

  variables = {
    name = variable.name
  }
}

// Nginx container that listens on port 80
// and serves our custom index.html file
resource "container" "nginx" {
  image {
    name = "nginx:mainline-alpine3.18-slim"
  }

  resources {
    memory = 256
  }

  volume {
    source = resource.template.index_html.destination
    destination = "/usr/share/nginx/html/index.html"
  }

  volume {
    source = "files/nginx.conf"
    destination = "/etc/nginx/conf.d/default.conf"
  }

  port {
    local = 80
    remote = 80
    host = 80
  }

   health_check {
    timeout = "10s"
    
    http {
      address = "http://localhost/index.html"
      success_codes = [200]
    }
   }
}
variable "name" {
  default = "instruqt"
}

resource "network" "main" {
  subnet = "10.0.0.0/16"
}

// Generate a CA certificate
resource "certificate_ca" "root" {
  output = data("certs")
}

// Use the CA certificate to generate a leaf certificate
resource "certificate_leaf" "cert" {
  ca_key = resource.certificate_ca.root.private_key.path
  ca_cert = resource.certificate_ca.root.certificate.path

  ip_addresses = ["127.0.0.1"]

  dns_names = [
    "localhost",
    "loadbalancer.container.jumppad.dev",
  ]

  output = data("certs")
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

resource "template" "loadbalancer_conf" {
  source = file("files/loadbalancer.conf")
  destination = "${data("nginx")}/loadbalancer.conf"

  variables = {
    servers = ["${resource.container.nginx.network[0].assigned_address}:${resource.container.nginx.port[0].local}"]
  }
}

resource "container" "loadbalancer" {
  image {
    name = "nginx:mainline-alpine3.18-slim"
  }

  network {
    id = resource.network.main.id
  }

  resources {
    memory = 256
  }

  volume {
    source = resource.template.loadbalancer_conf.destination
    destination = "/etc/nginx/conf.d/default.conf"
  }

  volume {
    source = "${data("certs")}/${resource.certificate_leaf.cert.private_key.filename}"
    destination = "/etc/nginx/certs/cert.key"
  }

  volume {
    source = "${data("certs")}/${resource.certificate_leaf.cert.certificate.filename}"
    destination = "/etc/nginx/certs/cert.crt"
  }

  port {
    local = 443
    remote = 443
    host = 443
  }
}

// Nginx container that listens on port 443
resource "container" "nginx" {
  image {
    name = "nginx:mainline-alpine3.18-slim"
  }

  network {
    id = resource.network.main.id
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
      address = "http://nginx.container.jumppad.dev/index.html"
      success_codes = [200]
    }
   }
}
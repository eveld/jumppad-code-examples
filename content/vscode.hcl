variable "docs_url" {
  default = "http://localhost"
}

variable "vscode_token" {
  default = "token"
}

resource "copy" "workspace" {
  source      = "./workspace"
  destination = data("terraform")
  permissions = "0755"
}

resource "template" "vscode_jumppad" {
  source      = <<-EOF
  {
  "tabs": [
    {
      "name": "Docs",
      "uri": "${variable.docs_url}",
      "type": "browser",
      "active": true
    },
    {
      "name": "Terminal",
      "location": "editor",
      "type": "terminal"
    }
  ]
  }
  EOF
  destination = "${data("vscode")}/workspace.json"
}

resource "container" "vscode" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/terraform-workshop:v0.3.2"
  }

  volume {
    source      = "${dir()}/scripts"
    destination = "/var/lib/jumppad/"
  }

  volume {
    source      = data("terraform")
    destination = "/terraform_basics"
  }

  volume {
    source      = resource.template.vscode_jumppad.destination
    destination = "/terraform_basics/.vscode/workspace.json"
  }

  volume {
    source      = "/var/run/docker.sock"
    destination = "/var/run/docker.sock"
  }

  environment = {
    EXTENSIONS       = "hashicorp.hcl,hashicorp.terraform"
    CONNECTION_TOKEN = variable.vscode_token
    DEFAULT_FOLDER   = "/terraform_basics"
  }

  port {
    local  = 8000
    remote = 8000
    host   = 8000
  }

  health_check {
    timeout = "60s"
    http {
      address       = "http://vscode.container.jumppad.dev:8000/"
      success_codes = [200, 302, 403]
    }
  }
}

variable "terraform_version" {
  default = "1.6.1"
}

variable "language" {
  default = "en"
}

resource "network" "main" {
  subnet = "10.0.0.0/16"
}

resource "docs" "docs" {
  network {
    id = resource.network.main.id
  }

  image {
    name = "ghcr.io/jumppad-labs/docs:v0.3.0"
  }

  content = [
    resource.book.terraform_basics
  ]

  assets = "${dir()}/assets"
}

resource "book" "terraform_basics" {
  title = "Understanding Terraform basics"

  chapters = [
    resource.chapter.introduction,
    resource.chapter.installation,
    resource.chapter.workflow,
    resource.chapter.providers,
    resource.chapter.state,
    resource.chapter.summary
  ]
}

resource "chapter" "introduction" {
  title = "Introduction"

  tasks = {}

  page "what_is_terraform" {
    content = file("docs/introduction/what_is_terraform.mdx")
  }

  page "what_will_you_learn" {
    content = file("docs/introduction/what_will_you_learn_${variable.language}.mdx")
  }

  page "workshow_environment" {
    content = file("docs/introduction/workshop_environment.mdx")
  }
}

resource "chapter" "summary" {
  tasks = {}

  page "summary" {
    content = file("docs/summary.mdx")
  }
}
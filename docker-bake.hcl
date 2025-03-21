variable "repository" {
  default = "kit101z/devcontainer"
}

variable "CI_COMMIT_SHA" {
  default = "$CI_COMMIT_SHA"
}

target "_common" {
  dockerfile = "Dockerfile"
  context = "."
  platforms  = ["linux/amd64", "linux/arm64"]
  labels     = {
    "com.cqcyit.container.build-time" = timestamp(),
    "com.cqcyit.container.git.sha"    = "${CI_COMMIT_SHA}"
  }
}
group "default" {
  targets = ["matrix"]
}
target "matrix" {
  matrix = {
    service = [ "base", "java", "node", "golang", "max" ]
  }
  name   = "build__${service}"
  context  = "."
  tags     = ["${repository}:${service}"]
  inherits = ["_common"]
}

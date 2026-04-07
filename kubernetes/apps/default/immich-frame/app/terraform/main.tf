locals {
  ssh_key_path = "/tmp/frame_key"
}

# Write the SSH key from the injected variable to a temp file
resource "local_sensitive_file" "ssh_key" {
  content         = var.ssh_private_key
  filename        = local.ssh_key_path
  file_permission = "0600"
}

provider "docker" {
  host     = "ssh://${var.frame_user}@${var.frame_host}"
  ssh_opts = ["-i", local.ssh_key_path, "-o", "StrictHostKeyChecking=no"]
}

# Bootstrap Docker on the Pi — runs once on first apply, idempotent
resource "null_resource" "docker_bootstrap" {
  depends_on = [local_sensitive_file.ssh_key]

  connection {
    type        = "ssh"
    host        = var.frame_host
    user        = var.frame_user
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "which docker || (curl -fsSL https://get.docker.com | sh)",
      "id -nG ${var.frame_user} | grep -q docker || sudo usermod -aG docker ${var.frame_user}",
      "sudo systemctl enable --now docker",
    ]
  }
}

resource "docker_image" "immichframe" {
  depends_on   = [null_resource.docker_bootstrap]
  name         = "ghcr.io/immichframe/immichframe:latest"
  keep_locally = true

  triggers = {
    pull_trigger = "ghcr.io/immichframe/immichframe:latest"
  }
}

resource "docker_container" "immichframe" {
  depends_on = [null_resource.docker_bootstrap]
  image      = docker_image.immichframe.image_id
  name       = "immichframe"
  restart    = "unless-stopped"

  env = [
    "ImmichServerUrl=${var.immich_server_url}",
    "ApiKey=${var.immich_api_key}",
  ]

  ports {
    internal = 8080
    external = 8080
  }
}

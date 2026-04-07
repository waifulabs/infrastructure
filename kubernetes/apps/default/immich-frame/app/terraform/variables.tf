variable "frame_host" {
  description = "IP address or hostname of the Raspberry Pi photo frame"
  type        = string
}

variable "frame_user" {
  description = "SSH user on the Raspberry Pi"
  type        = string
  default     = "pi"
}

variable "immich_server_url" {
  description = "Base URL of your Immich instance"
  type        = string
}

variable "immich_api_key" {
  description = "Immich API key for ImmichFrame"
  type        = string
  sensitive   = true
}

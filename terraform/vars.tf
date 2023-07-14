variable "resource_group_name" {
  default = "cp2-k8s"
}

variable "location_name" {
  default = "uksouth"
}

variable "kubernetes_cluster_name" {
  default = "kck8s"
}
variable "registry_name" {
  type        = string
  description = "Nombre del registry para las imágenes"
  default     = "dgmojeda"
}

variable "registry_sku" {
  type        = string
  description = "Tipo de SKU utilizado por el registry."
  default     = "Basic"
}

variable "network_name" {
  default = "vnet1"
}

variable "subnet_name" {
  default = "subnet1"
}

variable "vm_count" {
  default = 1
}

variable "public_key_path" {
  type        = string
  description = "Ruta para clave pública de acceso instancias"
  default     = "/home/usuario1/.ssh/1686747708_1857002.pub"
}

variable "ssh_user" {
  type        = string
  description = "Usuario ssh acceso maquina virtual"
  default     = "conte"
}

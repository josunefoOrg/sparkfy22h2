variable "aasResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf-aas"
}

variable "aspResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf-asp"
}

variable "umiName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf-umi"
}

variable "acrName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf23acr"
}

variable "resourceGroup" {
  description = "Resource group where the resource will be deployed"
  type        = string
  default     = "netcoreconf-demo"
}

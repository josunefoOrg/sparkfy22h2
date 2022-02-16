variable "aasResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojo-aas-spark"
}

variable "aspResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojo-asp-spark"
}

variable "umiName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojo-umi-spark"
}

variable "acrName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojoacrspark"
}

variable "resourceGroup" {
  description = "Resource group where the resource will be deployed"
  type        = string
  default     = "spark-jojo-demo"
}

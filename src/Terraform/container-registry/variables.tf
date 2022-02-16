variable "acrResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojoacrspark"
}

variable "umiResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "jojo-umi-spark"
}

variable "resourceGroup" {
  description = "Resource group where the resource will be deployed"
  type        = string
  default     = "spark-jojo-demo"
}

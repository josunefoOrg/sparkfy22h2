variable "acrResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf23acr"
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

variable "spnSparkObjectId" {
  description = "Object Id of the SPN who is deploying"
  type        = string
  default     = "0fb28633-cd4f-44cc-bfd0-672cad91a2e7"
}

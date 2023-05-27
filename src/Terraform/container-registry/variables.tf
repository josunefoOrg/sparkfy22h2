variable "acrResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf23acr"
}

variable "umiResourceName" {
  description = "Specifies the name of the Azure resource"
  type        = string
  default     = "netcoreconf-umi"
}

variable "resourceGroup" {
  description = "Resource group where the resource will be deployed"
  type        = string
  default     = "netcoreconf-demo"
}

variable "spnSparkObjectId" {
  description = "Object Id of the SPN who is deploying"
  type        = string
  default     = "a992a400-18db-41da-940d-245741154a03"
}

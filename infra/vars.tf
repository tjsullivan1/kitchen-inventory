variable "tags" {
  type        = map(any)
  description = "(optional) describe your variable"

}

variable "disambiguation" {
  type        = string
  description = "Please insert a value to add a clarification to your resource names"
}

variable "location" {
  type        = string
  description = "Please enter the Azure Region where these resources should be deployed"
  #TODO: Add validation to ensure that this is a valid region.
}
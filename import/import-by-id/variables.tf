variable "cam_hostname" {
  description = "CAM hostname or IP"
}
variable "cam_username" {
  description = "CAM username"
}
variable "cam_password" {
  description = "CAM password"
}
variable "cam_instancename" {
  description = "Name of the CAM instance that will be created after the import"
}
variable "cam_namespace" {
  description = "CAM namespace into which the imported instance will be created"
}
variable "cam_cloudconnection_id" {
  description = "CAM ID of the cloud connection used to connect to the cloud where the instance is going to be imported from "
}
variable "cam_template_id" {
  description = "CAM ID of the import template used as a base for terraform import "
}
variable "cam_template_version_id" {
  description = "CAM ID of the import template version used as a base for terraform import "
}

variable "cloud_instance_id" {
  description = "Cloud native ID of the instance to be imprted. e.g. 338aefb7-6987-4c43-88d5-09351b549b7f "
}
#variable "cam_instance_url" {
#  description = "URL of the imported CAM instance"
#}

output "imported_vm_ipv4"
{
  value = "${data.external.wait_for_instance.result["ipv4"]}"
}
output "imported_vm_name"
{
  value = "${data.external.wait_for_instance.result["name"]}"
}
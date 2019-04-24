data "external" "import" {
  program = ["/bin/bash", "${path.module}/scripts/import_by_name.sh"]
  query = {
    host_name  = "${var.cam_hostname}"
    user_name  = "${var.cam_username}"
    password = "${var.cam_password}"
    instance_name = "${var.cam_instancename}"
    instance_namespace = "${var.cam_namespace}"
    cloud_connection_name = "${var.cam_cloudconnection_name}"
    template_name = "${var.cam_template_name}"
    template_version_name = "${var.cam_template_version_name}"
    id_from_provider = "${var.cloud_instance_id}"
  }
}
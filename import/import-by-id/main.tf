data "external" "import" {
  program = ["/bin/bash", "${path.module}/scripts/import_by_id.sh"]
  query = {
    host_name  = "${var.cam_hostname}"
    user_name  = "${var.cam_username}"
    password = "${var.cam_password}"
    instance_name = "${var.cam_instancename}"
    instance_namespace = "${var.cam_namespace}"
    cloud_connection_id = "${var.cam_cloudconnection_id}"
    template_id = "${var.cam_template_id}"
    template_version_id = "${var.cam_template_version_id}"
    id_from_provider = "${var.cloud_instance_id}"
  }
}
resource "random_string" "random-dir" {
  length  = 8
  special = false
}

resource "null_resource" "create-temp-random-dir" {
  provisioner "local-exec" {
    command = "${format("mkdir -p  /tmp/%s" , "${random_string.random-dir.result}")}"
  }
}
data "external" "cam_token" {
  program = ["/bin/bash", "${path.module}/scripts/get_token.sh"]
  query = {
    cam_host_name  = "${var.cam_hostname}"
    cam_user_name  = "${var.cam_username}"
    cam_password   = "${var.cam_password}"
  }
}
data "external" "cam_tenant" {
  program = ["/bin/bash", "${path.module}/scripts/get_tenant.sh"]
  query = {
    cam_host_name   = "${var.cam_hostname}"
    cam_token       = "${data.external.cam_token.result["token"]}"
  }
}

resource "null_resource" "create_instance" {
  depends_on = ["null_resource.create-temp-random-dir"]
  

  provisioner "local-exec" {
    command = "cp ${path.module}/scripts/run_import.sh /tmp/${random_string.random-dir.result} " 
  }

  provisioner "local-exec" {
    command = "cp ${path.module}/scripts/functions.sh /tmp/${random_string.random-dir.result} " 
  }

  provisioner "local-exec" {
    working_dir = "/tmp/${random_string.random-dir.result}"
    command = "/bin/bash ./run_import.sh --cam_host_name=${var.cam_hostname} --cam_token=${data.external.cam_token.result["token"]} --cam_tenant=${data.external.cam_tenant.result["tenant"]} --cam_instance_name=${var.cam_instancename} --cam_instance_namespace=${var.cam_namespace} --cam_cloudconnection_id=${var.cam_cloudconnection_id} --cam_template_id=${var.cam_template_id} --cam_template_version_id=${var.cam_template_version_id} --cloud_instance_id=${var.cloud_instance_id}" 
  }
}

data "external" "cam_instance" {
  depends_on = ["null_resource.create_instance"]
  program = ["/bin/bash", "${path.module}/scripts/get_instance_id.sh"]
  query = {
    json_path   = "${random_string.random-dir.result}/cam.json"
  }
}

data "external" "wait_for_instance" {
  program = ["/bin/bash", "${path.module}/scripts/wait_for_instance.sh"]
  query = {
    cam_host_name           = "${var.cam_hostname}"
    cam_token               = "${data.external.cam_token.result["token"]}"
    cam_tenant_id           = "${data.external.cam_tenant.result["tenant"]}"
    cam_instance_id         = "${data.external.cam_instance.result["instance_id"]}"
    cam_instance_namespace  = "${var.cam_namespace}"
  }
}

resource "null_resource" "delete_instance" {
  depends_on = ["null_resource.create-temp-random-dir"]

  provisioner "local-exec" {
    when    = "destroy"
    command = "cp ${path.module}/scripts/delete_instance.sh /tmp/${random_string.random-dir.result} " 
  }

  provisioner "local-exec" {
    when    = "destroy"
    working_dir = "/tmp/${random_string.random-dir.result}"
    command = "/bin/bash ./delete_instance.sh --cam_host_name=${var.cam_hostname} --cam_token=${data.external.cam_token.result["token"]} --cam_tenant=${data.external.cam_tenant.result["tenant"]} --cam_instance_id=`jq --raw-output '.cam_instance_id' /tmp/${random_string.random-dir.result}/cam.json` --cam_instance_namespace=${var.cam_namespace} "
  }

  #cleanup the temp folder
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -fr /tmp/${random_string.random-dir.result}"
  }
}

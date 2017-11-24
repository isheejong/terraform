/* 2017.11.24 writed by hee-jong.lee */

/* provider */
provider "oci" {
          region           = "us-ashburn-1"
          tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaadgfchtlczd44dr26woegfwjylu6agka373reews47dzjwqvqs57q"
          user_ocid        = "ocid1.user.oc1..aaaaaaaa2grflxwcc2yjyh4xleuea43k2ezu7m3p46p3xrlnflzx7lfj42xa"
          fingerprint      = "93:17:cb:e6:59:36:6d:25:b5:1d:d2:0d:b3:fe:d5:cf"
          private_key_path = "/home/isheejong/trf/works/terraform/bmcs_api_key.pem"
}


/* variables */
variable "compartment_ocid"  { default = "ocid1.compartment.oc1..aaaaaaaawveptj3wxxz6z5ymq6d2ge3pzdxgk7wgutxm7z3h7cufwayjlmqa" }
variable "subnet_id1" { default = "ocid1.subnet.oc1.iad.aaaaaaaarjhisxztnw5hbskh7gqb5mgedsigydl25bgzupmmxrruyk3rdytq" }
variable "subnet_id2" { default = "ocid1.subnet.oc1.iad.aaaaaaaadudtr7rhjwejcakcthhzp4cao5lhtcwd6daafdmvs7v4l2gmfgaa" }
variable "subnet_id3" { default = "ocid1.subnet.oc1.iad.aaaaaaaafkzxomeb7tvobrgzpynh5ak5tl4mqylg3bxfsrzjvxqpjaw32yia" }
variable "availability_domain1" { default = "Hkdm:US-ASHBURN-AD-1" }
variable "availability_domain2" { default = "Hkdm:US-ASHBURN-AD-2" }
variable "availability_domain3" { default = "Hkdm:US-ASHBURN-AD-3" }
variable "ssh_public_key" { default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJ50jGhg3ST00H/GfY9bFfarckMPtZRoWScYaca7LI02HHV55msC5YT/JzBjyEY6RoEblzvhCEcrbuVqsWrQlMJ8ZAoing5bAwStMgB9RphlCQ7562it9GVjrrqPv3qpkMscBw8QRpboClsa6zK4vaQvLYj30Bpl7ZdqgU/zxKsiuRzV8K0k1tF1K+NnfmJx0ccezOvHb+3RTxPjWbRQ46ZZ16K0aWidrChF/IweCrd963VjI4MGkw0lfov1q9h4N9ESwv20GAwf7dGIRDEdjHVhzVBa1Ga/ge9a5aN8oIj3YyAb7gdcqKk2TwcGHup4uH+VYTOl8/5pOZM7eoiz2H" }


/* vm instances */
resource "oci_core_instance" "instance1" {

        compartment_id = "${var.compartment_ocid}"
        availability_domain = "${var.availability_domain2}"
        subnet_id = "${var.subnet_id2}"

        display_name = "instance1"
        image = "ocid1.image.oc1.iad.aaaaaaaadukpek2y3x6ekmfmjtc63etyjdd4asqpath23q6tk2gorofeeoqa"
        shape = "VM.Standard1.1"

        metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}"
        }
}


resource "oci_core_instance" "instance2" {

        compartment_id = "${var.compartment_ocid}"
        availability_domain = "${var.availability_domain2}"
        subnet_id = "${var.subnet_id2}"

        display_name = "instance2"
        image = "ocid1.image.oc1.iad.aaaaaaaadukpek2y3x6ekmfmjtc63etyjdd4asqpath23q6tk2gorofeeoqa"
        shape = "VM.Standard1.1"

        metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}"
        }
}

resource "oci_core_instance" "instance3" {

        compartment_id = "${var.compartment_ocid}"
        availability_domain = "${var.availability_domain2}"
        subnet_id = "${var.subnet_id2}"

        display_name = "instance3"
        image = "ocid1.image.oc1.iad.aaaaaaaadukpek2y3x6ekmfmjtc63etyjdd4asqpath23q6tk2gorofeeoqa"
        shape = "VM.Standard1.1"

        metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}"
        }
}


resource "oci_load_balancer" "lb1" {
  shape          = "100Mbps"
  compartment_id = "${var.compartment_ocid}"
  subnet_ids     = [
    "${var.subnet_id1}",
    "${var.subnet_id2}"
  ]
  display_name   = "lb1"
}



resource "oci_load_balancer_backendset" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = "8080"
    protocol = "HTTP"
    response_body_regex = ".*"
    url_path = "/"
  }
}


resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = "${oci_load_balancer.lb1.id}"
  name                     = "http"
  default_backend_set_name = "${oci_load_balancer_backendset.lb-bes1.id}"
  port                     = 80
  protocol                 = "HTTP"
}


resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.instance1.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2"  {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.instance2.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be3"  {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.instance3.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

output "lb_public_ip" {
  value = ["${oci_load_balancer.lb1.ip_addresses}"]
}


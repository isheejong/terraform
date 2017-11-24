/* 2017.11.24 writed by hee-jong.lee */

/* provider */
provider "oci" {
          region           = "us-ashburn-1"
          tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaae34ej5t3jzwnseacsneeh2jqrq25ho6ud74lu27p6kscgsj27aea"
          user_ocid        = "ocid1.user.oc1..aaaaaaaaffx5df263orcob4tn3ad2n2rkrkfbuhdtr2gvnipchcldwdc6pua"
          fingerprint      = "11:db:8d:a4:c8:91:7b:a7:aa:56:b6:b3:52:fc:c6:0e"
          private_key_path = "/home/mcuser/ociapikeys/oci_api_key.pem"
}


/* variables */
variable "compartment_ocid"  { default = "ocid1.compartment.oc1..aaaaaaaan2ba3eaknmc7tm7bu4j2ux7gencnxqfjf7ai4w4ognqgihmiragq" }
variable "subnet_id1" { default = "ocid1.subnet.oc1.iad.aaaaaaaa2igi5jtm66kthra2r22xckxsa3n7fvv3hk2wjbgkrmdazitkz7ia" }
variable "subnet_id2" { default = "ocid1.subnet.oc1.iad.aaaaaaaalpf5plxekn7bkk25qus2r44ly4oinosr2hyehoktat2fd5eg6y6q" }
variable "subnet_id3" { default = "ocid1.subnet.oc1.iad.aaaaaaaac4k7rgqzo27njsbz4zoswecu2nvzxc42xy2tiqr56qdwveogsioa" }
variable "availability_domain1" { default = "cCgE:US-ASHBURN-AD-1" }
variable "availability_domain2" { default = "cCgE:US-ASHBURN-AD-2" }
variable "availability_domain3" { default = "cCgE:US-ASHBURN-AD-3" }
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


/* this instance is mandantory instance and this instance already was created by user*/

resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "10.0.0.2"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be1"  {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.instance1.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2  {
  load_balancer_id = "${oci_load_balancer.lb1.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.instance2.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

output "lb_public_ip" {
  value = ["${oci_load_balancer.lb1.ip_addresses}"]
}

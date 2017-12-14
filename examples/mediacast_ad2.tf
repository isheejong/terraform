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
variable "compartment_ocid"   { default = "ocid1.compartment.oc1..aaaaaaaan2ba3eaknmc7tm7bu4j2ux7gencnxqfjf7ai4w4ognqgihmiragq" }
variable "subnet_id"          { default = "ocid1.subnet.oc1.iad.aaaaaaaalpf5plxekn7bkk25qus2r44ly4oinosr2hyehoktat2fd5eg6y6q" }
variable "load_balancer_id"   { default = "ocid1.loadbalancer.oc1.iad.aaaaaaaa2vz32elxiz3ae4b52klpcavrvmov4x5f5jy4qz5iscmndrx462ta" }
variable "backendset_name"    { default = "mediacast_backend"}

variable "availability_domain" { default = "cCgE:US-ASHBURN-AD-2" }
variable "ssh_public_key"       { default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJ50jGhg3ST00H/GfY9bFfarckMPtZRoWScYaca7LI02HHV55msC5YT/JzBjyEY6RoEblzvhCEcrbuVqsWrQlMJ8ZAoing5bAwStMgB9RphlCQ7562it9GVjrrqPv3qpkMscBw8QRpboClsa6zK4vaQvLYj30Bpl7ZdqgU/zxKsiuRzV8K0k1tF1K+NnfmJx0ccezOvHb+3RTxPjWbRQ46ZZ16K0aWidrChF/IweCrd963VjI4MGkw0lfov1q9h4N9ESwv20GAwf7dGIRDEdjHVhzVBa1Ga/ge9a5aN8oIj3YyAb7gdcqKk2TwcGHup4uH+VYTOl8/5pOZM7eoiz2H" }

variable "image" {default = "ocid1.image.oc1.iad.aaaaaaaac4oxvscuihv6e56i5572htriehxelfsm3bfqqzptpvelptbmj4sq"}


/* add instances */
resource "oci_core_instance" "ad2-instance-1" {

        compartment_id = "${var.compartment_ocid}"
        availability_domain = "${var.availability_domain}"
        subnet_id = "${var.subnet_id}"

        display_name = "ad2-instance-1"
        image = "${var.image}"
        shape = "VM.Standard1.1"

        metadata = {
                ssh_authorized_keys = "${var.ssh_public_key}"
        }
}



/* add backend set about above new instance*/

resource "oci_load_balancer_backend" "lb-be1"  {
  load_balancer_id = "${var.load_balancer_id}"
  backendset_name  = "${var.backendset_name}"
  ip_address       = "${oci_core_instance.ad2-instance-1.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

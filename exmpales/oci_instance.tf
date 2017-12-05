variable "compartment_ocid"  { default = "ocid1.compartment.oc1..aaaaaaaawveptj3wxxz6z5ymq6d2ge3pzdxgk7wgutxm7z3h7cufwayjlmqa" }

variable "subnet_id1" { default = "ocid1.subnet.oc1.iad.aaaaaaaarjhisxztnw5hbskh7gqb5mgedsigydl25bgzupmmxrruyk3rdytq" }
variable "subnet_id2" { default = "ocid1.subnet.oc1.iad.aaaaaaaadudtr7rhjwejcakcthhzp4cao5lhtcwd6daafdmvs7v4l2gmfgaa" }
variable "subnet_id3" { default = "ocid1.subnet.oc1.iad.aaaaaaaafkzxomeb7tvobrgzpynh5ak5tl4mqylg3bxfsrzjvxqpjaw32yia" }

variable "availability_domain1" { default = "Hkdm:US-ASHBURN-AD-1" }
variable "availability_domain2" { default = "Hkdm:US-ASHBURN-AD-2" }
variable "availability_domain3" { default = "Hkdm:US-ASHBURN-AD-3" }


resource "oci_core_instance" "auto_vm_01" {

	compartment_id = "ocid1.compartment.oc1..aaaaaaaawveptj3wxxz6z5ymq6d2ge3pzdxgk7wgutxm7z3h7cufwayjlmqa"
	availability_domain = "${var.availability_domain2}"
	subnet_id = "${var.subnet_id2}"

	display_name = "auto_vm_01"
	image = "ocid1.image.oc1.iad.aaaaaaaajdj2lfgbzcj6w2hlu6e7nfuekuh6hhd2qcxn44boirsuvgnsunxa"
	shape = "VM.Standard2.1"

	metadata = {
#    ssh_authorized_keys = "${var.ssh_public_key}"
	}
}


resource "oci_core_instance" "auto_vm_02" {

	compartment_id = "ocid1.compartment.oc1..aaaaaaaawveptj3wxxz6z5ymq6d2ge3pzdxgk7wgutxm7z3h7cufwayjlmqa"
	availability_domain = "${var.availability_domain2}"
	subnet_id = "${var.subnet_id2}"

	display_name = "auto_vm_02"
	image = "ocid1.image.oc1.iad.aaaaaaaajdj2lfgbzcj6w2hlu6e7nfuekuh6hhd2qcxn44boirsuvgnsunxa"
	shape = "VM.Standard2.1"

	metadata = {
#    ssh_authorized_keys = "${var.ssh_public_key}"
	}
}

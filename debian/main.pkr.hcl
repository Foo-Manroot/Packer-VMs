packer {
	required_plugins {
		vmware = {
			version = "~> 1"
			source = "github.com/hashicorp/vmware"
		}
	}
}

///////////////////////////////////////////

variable "iso_url"				{ type = string }
variable "iso_hash"				{ type = string }

variable "user_pass"			{ type = string }

///////////////////////////////////////////
///////////////////////////////////////////
///////////////////////////////////////////

source "vmware-iso" "vm" {
	iso_url           = var.iso_url
	iso_checksum      = var.iso_hash

	communicator = "ssh"
	ssh_username = "user"
	ssh_password = var.user_pass
	ssh_timeout = "10m"

	cpus = 4 	// 4 vCPUs spread on 2 sockets
	cores = 2
	memory = 32768 // 32 GiB of RAM. My laptop has 46 GiB

	disk_size = 51200	// 50 GB should be enough
	disk_adapter_type = "ide" // The installer doesn't seem to detect the drive otherwise
	disk_type_id = 0 // "Growable virtual disk contained in a single file (monolithic sparse)."

	// I don't know where this is documented.
    // I created a VM and `guestOS` was this in the generated .vmx
	guest_os_type = "debian12-64"
	vhv_enabled = true

	tools_upload_flavor = "linux"
	tools_upload_path = "/tmp/vmware_tools.iso"

	shutdown_command = "echo ${var.user_pass} | sudo -S /sbin/shutdown -h now"

	vm_name = "debian-tmp"

	// https://developer.hashicorp.com/packer/guides/automatic-operating-system-installs/preseed_ubuntu
	// Mounting an additional CD drives the Debian installer crazy, so I opted for pulling all provisioning files
	// from the HTTP server as well (exposed to the provisioners as PACKER_HTTP_ADDR: https://github.com/hashicorp/packer/pull/4409 )
	http_directory = "http_files"
	boot_command = [
		"<esc><wait>", // Go into the Debian bootloader shell. Apparently the x64 version has no Grub (?)
		"/install.amd/vmlinuz",
		" initrd=/install.amd/initrd.gz",
		" auto-install/enable=true",
		" debconf/priority=critical",
		" preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <enter>",
	]
	boot_wait = "1s" // In my tests it boots quite fast
}

build {
	sources = [
		"source.vmware-iso.vm"
	]

	provisioner "shell" {
		script = "init_provisioning.sh"
		env = {
			"ELEVATE_PASS": var.user_pass // password for `sudo`
		}
		timeout = "20m"
	}
}

# Packer VMs

These are some of my templates to automate the provisioning of the VMs I tend to use.
My goal is to not waste time with the configuration and end up with a familiar setup.

# Usage

Just go to the corresnponding subdirectory and execute `run.sh`.
In most cases, this is probably equivalent to `packer init . && packer build .`

It might be advisable to check the parameters defined on the `variables.auto.pkrvars.hcl`, especially the user password.


# Index

  - [debian](./debian/): A base Debian 13 with some personalisation (dark mode, no welcome tour, custom aliases, some extra tools installed, ...)

#!/bin/sh

if ! command -v packer >/dev/null
then
	printf "Packer doesn't seem to be installed.\nCheck out https://developer.hashicorp.com/packer/install\n"
	exit 1
fi

packer init .
packer build .
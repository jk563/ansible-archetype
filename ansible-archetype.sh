#!/usr/bin/env bash

# Prompt for name if not already supplied
if [[ -z ${1} ]] ; then
  read -p "What do you want to name your project? : " NAME_OF_PROJECT
else
  NAME_OF_PROJECT=${1}
fi

# Check directory doesn't already exist
if [[ -d ${NAME_OF_PROJECT} ]]; then
  echo "Directory already exists. Exiting."
  exit 1
fi

# Ansible Structure
mkdir -p ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}
cat > ${NAME_OF_PROJECT}/${NAME_OF_PROJECT}.yml <<EOF
---
# file: roles/${NAME_OF_PROJECT}/${NAME_OF_PROJECT}.yml

- hosts: ${NAME_OF_PROJECT}
  roles:
    - ${NAME_OF_PROJECT}

- hosts: default
  roles:
    - ${NAME_OF_PROJECT}
EOF

mkdir ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/tasks
cat > ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/tasks/main.yml <<EOF
---
# file: roles/${NAME_OF_PROJECT}/tasks/main.yml

EOF

mkdir ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/meta
mkdir ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/files
mkdir ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/templates
mkdir ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/vars
cat > ${NAME_OF_PROJECT}/roles/${NAME_OF_PROJECT}/vars/main.yml <<EOF
---
# file: roles/${NAME_OF_PROJECT}/vars/main.yml

EOF

# Vagrantfile
cat > ${NAME_OF_PROJECT}/Vagrantfile <<EOF
Vagrant.configure(2) do |config|

  config.vm.define "${NAME_OF_PROJECT}" do |${NAME_OF_PROJECT}|
    ${NAME_OF_PROJECT}.vm.box="jk563/fedora21"
    ${NAME_OF_PROJECT}.vm.box_url="https://atlas.hashicorp.com/jk563/boxes/fedora21.json"

    ${NAME_OF_PROJECT}.vm.provision "ansible" do |ansible|
        ansible.playbook = "${NAME_OF_PROJECT}.yml"
    end
  end

end
EOF

# Packer file
cat > ${NAME_OF_PROJECT}/packer.json <<EOF
{
  "variables": {
    "fedora21_fresh_install_ovf": "/Users/jamiekelly/packer_fedora_21_vagrant/output-fedora21_fresh_vagrant/packer-fedora21_fresh_vagrant-1445278811.ovf"
  },
  "builders": [
    {
      "name": "fedora21_${NAME_OF_PROJECT}",
      "type": "virtualbox-ovf",
      "source_path": "{{user \`fedora21_fresh_install_ovf\`}}",
      "ssh_username": "root",
      "ssh_password": "root",
      "headless": "true",
      "shutdown_command": "echo 'packer' | sudo -S shutdown -P now"
    }
  ],
  "provisioners": [
    {
      "type": "ansible",
      "playbook_file": "./${NAME_OF_PROJECT}.yml",
      "extra_arguments": ["--private-key", "/Users/jamiekelly/ansib"],
      "ssh_authorized_key_file": "/Users/jamiekelly/ansib.pub",
      "ssh_host_key_file": "/Users/jamiekelly/ansib",
      "sftp_command": "/usr/libexec/openssh/sftp-server -e"
    }
  ],
  "post-processors": [
    {
      "type": "vagrant",
      "output": "builds/packer_{{.BuildName}}_{{.Provider}}.box"
    }
  ]
}
EOF

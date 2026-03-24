# Run everything
ansible-playbook -i inventory.ini site.yml

# Just prepare the nodes
ansible-playbook -i inventory.ini site.yml --tags common

# Only the controlplane
ansible-playbook -i inventory.ini site.yml --tags server

# Workers only
ansible-playbook -i inventory.ini site.yml --tags agent

# Full dry run
ansible-playbook -i inventory.ini site.yml --check --diff

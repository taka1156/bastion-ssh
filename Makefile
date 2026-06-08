.PHONY: setup-ansible setup ssh rsync sftp lint

## Ansible setup (pass extra args with ARGS="...")
setup-ansible:
	@bash tool/setup_ansible.sh $(ARGS)

## Generate .env interactively
setup:
	@bash tool/setup_env.sh $(ARGS)

## Connect via SSH
ssh:
	@bash tool/ssh.sh

## Transfer files via rsync (pass extra args with ARGS="...")
rsync:
	@bash tool/rsync.sh $(ARGS)

## Open interactive SFTP session (pass extra args with ARGS="...")
sftp:
	@bash tool/sftp.sh $(ARGS)

lint:
	secretlint "**/*"

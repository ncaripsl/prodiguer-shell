# Create root alias.
alias prodiguer="$( dirname "${BASH_SOURCE[0]}" )"/exec.sh

# Supported command types.
declare -a command_types=(
	cv
	db
	mq
	stack
	utests
	web
)

# Supported commands.
declare -a commands=(
	# Controlled vocabulary admin.
	cv-git-pull
	cv-git-push
	cv-git-setup
	# DB admin.
	db-pgres-backup
	db-pgres-install
	db-pgres-reset
	db-pgres-restore
	db-pgres-uninstall
	# MQ admin.
	mq-configure
	mq-daemons-init
	mq-daemons-kill
	mq-daemons-refresh
	mq-daemons-restart
	mq-daemons-start
	mq-daemons-status
	mq-daemons-stop
	mq-purge
	mq-reset
	mq-server
	# MQ producers.
	mq-produce
	mq-produce-ext-smtp-from-file
	mq-produce-ext-smtp-polling
	mq-produce-ext-smtp-realtime
	# MQ consumers.
	mq-consume
	mq-consume-ext-smtp
	mq-consume-in-monitoring
	mq-consume-internal-api
	mq-consume-internal-smtp
	mq-consume-internal-sms
	# Stack management.
	stack-bootstrap
	stack-install
	stack-update
	stack-update-shell
	stack-update-repo
	stack-update-repos
	stack-update-venv
	stack-update-venvs
	stack-update-source
	stack-uninstall
	stack-uninstall-repo
	stack-config-commit
	stack-config-encrypt
	stack-config-decrypt
	# Web service.
	web-api
	web-api-heartbeat
	web-api-list-endpoints
)

# Set path to exec.sh.
PRODIGUER_SHELL_EXEC="$( dirname "${BASH_SOURCE[0]}" )"/exec.sh

# Create default alias.
alias prodiguer=$PRODIGUER_SHELL_EXEC

# Create command aliases.
for command in "${commands[@]}"
do
	alias prodiguer-$command=$PRODIGUER_SHELL_EXEC" "$command
done

# Create command type help aliases.
for command_type in "${command_types[@]}"
do
	alias help-prodiguer-$command_type=$PRODIGUER_SHELL_EXEC" help-"$command_type
done

# Create command help aliases.
for command in "${commands[@]}"
do
	alias help-prodiguer-$command=$PRODIGUER_SHELL_EXEC" help-"$command
done

# Composite commands.
alias prodiguer-db-reset='prodiguer-cv-git-pull && prodiguer-db-pgres-reset'

# Unset vars.
unset PRODIGUER_SHELL_EXEC
unset command_type
unset command_types
unset command
unset commands

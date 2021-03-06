# Import utils.
source $PRODIGUER_HOME/bash/init.sh

log "MQ : importing RabbitMQ broker definitions ..."

rabbitmqadmin -q -u prodiguer-mq-admin -p $1 import $PRODIGUER_DIR_TEMPLATES/mq-rabbit-broker-definitions.json

log "MQ : imported RabbitMQ server broker definitions"


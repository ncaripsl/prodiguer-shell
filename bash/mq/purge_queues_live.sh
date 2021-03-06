# Import utils.
source $PRODIGUER_HOME/bash/init.sh

# Set of supported MQ queues.
declare -a QUEUES=(
	'live-cv'
	'live-fe'
	'live-metrics'
	'live-metrics-pcmdi'
	'live-monitoring-compute'
	'live-monitoring-post-processing'
	'live-smtp'
	'live-superviseur'
)

for queue in "${QUEUES[@]}"
do
	log "MQ : purging live queue :: "$queue
	rabbitmqadmin -q -u prodiguer-mq-admin -p $1 -V prodiguer purge queue name=$queue
done

log "MQ : purged live queues"

# ###############################################################
# SECTION: API METRIC
# ###############################################################

# Add metrics.
run_metric_add()
{
	activate_venv server
	if [ "$2" ]; then
		python $DIR_JOBS/api/metric/run_add.py --file=$1 --duplicate_action=$2
	else
		python $DIR_JOBS/api/metric/run_add.py --file=$1 --duplicate_action=skip
	fi
}

# Adds a batch of metrics.
run_metric_add_batch()
{
	for file in $1/metrics*.json
	do
		if [ "$2" ]; then
			run_metric_add $file $2
		else
			run_metric_add $file skip
		fi
	done
}

# Delete metric.
run_metric_delete()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_delete.py --group=$1 --filter=$2
}

# Fetch metric group.
run_metric_fetch()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch.py --group=$1 --filter=$2 --encoding=json
}

# Fetch metric group columns.
run_metric_fetch_columns()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch_columns.py --group=$1
}

# Fetch metric count.
run_metric_fetch_count()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch_count.py --group=$1 --filter=$2
}

# Fetch metric group to file system.
run_metric_fetch_file()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch_file.py --group=$1 --output_dir=$2
}

# List groups.
run_metric_fetch_list()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch_list.py
}

# Format a set of metrics files.
run_metric_format()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_format.py --group=$1 --input_format=$2 --input_dir=$3 --output_dir=$4 --output_format=blocks
}

# Fetch metric group line count.
run_metric_fetch_setup()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_fetch_setup.py --group=$1 --filter=$2
}

# Format a set of metrics files.
run_metric_rename()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_rename.py --group=$1 --new_name=$2
}

# Sets the hash identifiers over a set of metrics.
run_metric_set_hashes()
{
	activate_venv server
	python $DIR_JOBS/api/metric/run_set_hashes.py --group=$1
}

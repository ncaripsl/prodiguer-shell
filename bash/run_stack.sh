#!/bin/bash

# ###############################################################
# SECTION: BOOTSTRAP
# ###############################################################

run_init_ops_directories()
{
	log "Initializing ops directories"
	set_working_dir
	mkdir -p $DIR_BACKUPS
	mkdir -p $DIR_CONFIG
	mkdir -p $DIR_DAEMONS
	mkdir -p $DIR_DATA
	mkdir -p $DIR_DATA/pgres
	mkdir -p $DIR_DATA/mongo
	mkdir -p $DIR_LOGS
	mkdir -p $DIR_LOGS/db
	mkdir -p $DIR_LOGS/mq
	mkdir -p $DIR_LOGS/web
	mkdir -p $DIR_PYTHON
	mkdir -p $DIR_TMP
	mkdir -p $DIR_VENV
}

# Run stack bootstrapper.
run_stack_bootstrap()
{
	log "BOOTSTRAP STARTS"
	set_working_dir

	run_init_ops_directories

	log "Initializing configuration"
	cp $DIR_TEMPLATES/config/prodiguer.sh $DIR_CONFIG/prodiguer.sh
	cp $DIR_TEMPLATES/config/prodiguer.json $DIR_CONFIG/prodiguer.json
	cp $DIR_TEMPLATES/config/mq-supervisord.conf $DIR_CONFIG/mq-supervisord.conf

	log "BOOTSTRAP ENDS"

	log
	log "IMPORTANT NOTICE"
	log "The bootstrap process installs the follwing config files:" 1
	log "$DIR_CONFIG/prodiguer.json" 2
	log "$DIR_CONFIG/prodiguer.sh" 2
	log "Please review and assign settings as appropriate to your " 1
	log "environemt prior to continuing with the installation process." 1
	log "IMPORTANT NOTICE ENDS"
}

# ###############################################################
# SECTION: INSTALL
# ###############################################################

# Display post install notice.
_install_notice()
{
	log
	log "IMPORTANT NOTICE"
	log "To prodiguer shell command aliases add the following line to your .bash_profile file:" 1
	log "test -f $DIR/exec.aliases && source $DIR/exec.aliases" 2
	log "IMPORTANT NOTICE ENDS"
}


# Installs virtual environments.
run_install_venv()
{
	if [ "$2" ]; then
		log "Installing virtual environment: $1"
	fi

	# Make directory.
	declare TARGET_VENV=$DIR_VENV/$1
	rm -rf $TARGET_VENV
    mkdir -p $TARGET_VENV

    # Initialise venv.
    export PATH=$DIR_PYTHON/bin:$PATH
	export PYTHONPATH=$PYTHONPATH:$DIR_PYTHON
    virtualenv -q $TARGET_VENV

    # Build dependencies.
    source $TARGET_VENV/bin/activate
	declare TARGET_REQUIREMENTS=$DIR_TEMPLATES/venv/requirements-$1.txt
    pip install -q --allow-all-external -r $TARGET_REQUIREMENTS

    # Cleanup.
    deactivate
}

# Installs python virtual environments.
run_install_venvs()
{
	run_install_venv "server" "echo"
}

# Installs a python executable primed with setuptools, pip & virtualenv.
run_install_python()
{
	log "Installing python "$PYTHON_VERSION" (takes approx 2 minutes)"

	# Download source.
	set_working_dir $DIR_PYTHON
	mkdir src
	cd src
	wget http://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz --no-check-certificate
	tar -xvf Python-$PYTHON_VERSION.tgz
	rm Python-$PYTHON_VERSION.tgz

	# Compile.
	cd Python-$PYTHON_VERSION
	./configure --prefix=$DIR_PYTHON
	make
	make install
	export PATH=$DIR_PYTHON/bin:$PATH
	export PYTHONPATH=$PYTHONPATH:$DIR_PYTHON

	# Install setuptools.
	cd $DIR_PYTHON/src
	wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
	python ez_setup.py

	# Install pip.
	easy_install --prefix $DIR_PYTHON pip

	# Install virtualenv.
	pip install virtualenv
}

# Installs a git repo.
run_install_repo()
{
	log "Installing repo: $1"

	rm -rf $DIR_REPOS/$1
	git clone -q https://github.com/Prodiguer/$1.git $DIR_REPOS/$1
}

# Installs git repos.
run_install_repos()
{
	run_install_repo prodiguer-cv
	run_install_repo prodiguer-docs
	run_install_repo prodiguer-fe
	run_install_repo prodiguer-server
}

# Sets up directories.
_install_dirs()
{
	mkdir -p $DIR_REPOS
	mkdir -p $DIR_PYTHON
	mkdir -p $DIR_TMP
}

# Installs stack.
run_stack_install()
{
	log "INSTALLING STACK"

	_install_dirs
	run_install_repos
	run_install_python
	run_install_venvs

	log "INSTALLED STACK"

	_install_notice
}


# ###############################################################
# SECTION: UPDATE
# ###############################################################

# Display post update notice.
_update_notice()
{
	log
	log "IMPORTANT NOTICE"
	log "The update process installed a new config file:" 1
	log "$DIR_CONFIG/new-prodiguer.json" 2
	log "If the config schema version of the new and existing config files is different then you will need to update your local configuration settings accordingly." 1
	log "IMPORTANT NOTICE ENDS"
}

# Updates a virtual environment.
_update_venv()
{
	log "Updating virtual environment :: $1"

	_uninstall_venv $1
	run_install_venv $1
}

# Updates virtual environments.
run_stack_update_venvs()
{
	export PATH=$DIR_PYTHON/bin:$PATH
	export PYTHONPATH=$PYTHONPATH:$DIR_PYTHON
	_update_venv "server"
}

# Updates a git repo.
_update_repo()
{
	log "Updating repo: $1"

	set_working_dir $DIR_REPOS/$1
	git pull -q
	remove_files "*.pyc"
	set_working_dir
}

# Updates git repos.
run_stack_update_repos()
{
	_update_repo prodiguer-cv
	_update_repo prodiguer-docs
	_update_repo prodiguer-fe
	_update_repo prodiguer-server
}

# Updates configuration.
run_update_config()
{
	log "Updating configuration"

	cp $DIR_TEMPLATES/config/prodiguer.json $DIR_CONFIG/new-prodiguer.json
	cp $DIR_TEMPLATES/config/prodiguer.sh $DIR_CONFIG/prodiguer.sh
	cp $DIR_TEMPLATES/config/mq-supervisord.conf $DIR_CONFIG/mq-supervisord.conf
}

# Updates shell.
run_stack_update_shell()
{
	log "Updating shell"

	set_working_dir
	git pull -q
	remove_files "*.pyc"
}

# Updates stack.
run_stack_update()
{
	log "UPDATING STACK"

	run_stack_update_shell
	run_update_config
	run_stack_update_repos
	run_stack_update_venvs

	log "UPDATED STACK"

	_update_notice
}

# ###############################################################
# SECTION: UNINSTALL
# ###############################################################

# Uninstalls shell.
_uninstall_shell()
{
	log "Uninstalling shell"

	rm -rf $DIR
}

# Uninstalls git repo.
_uninstall_repo()
{
	rm -rf $DIR_REPOS/$1
}

# Uninstalls git repos.
_uninstall_repos()
{
	log "Uninstalling repos"

	_uninstall_repo prodiguer-cv
	_uninstall_repo prodiguer-docs
	_uninstall_repo prodiguer-fe
	_uninstall_repo prodiguer-server
}

# Uninstalls python.
_uninstall_python()
{
	log "Uninstalling python"

	rm -rf $DIR_PYTHON
}

# Uninstalls a virtual environment.
_uninstall_venv()
{
	if [ "$2" ]; then
		log "Uninstalling virtual environment :: $1"
	fi

	rm -rf $DIR_VENV/$1
}

# Uninstalls virtual environments.
_uninstall_venvs()
{
	_uninstall_venv "server" "echo"
}

# Uninstalls stack.
run_stack_uninstall()
{
	log "UNINSTALLING STACK"

	_uninstall_venvs
	_uninstall_python
	_uninstall_repos
	_uninstall_shell

	log "UNINSTALLED STACK"
}

# ###############################################################
# SECTION: CONFIGURATION
# ###############################################################

# Encrypts configuration files and saves them as template.
run_stack_config_encrypt()
{
	log "ENCRYPTING CONFIG FILES"

	# Initialise file paths.
	declare COMPRESSED=$DIR_TEMPLATES/config/$1-$2.tar
	declare ENCRYPTED=$COMPRESSED.encrypted

	# Compress.
	set_working_dir $DIR_CONFIG
	tar cvf $COMPRESSED ./*

	# Encrypt.
	openssl aes-128-cbc -salt -in $COMPRESSED -out $ENCRYPTED

	# Clean up.
	rm $COMPRESSED
	set_working_dir

	log "ENCRYPTED CONFIG FILES"
}

# Decrypts configuration files and saves them as template.
run_stack_config_decrypt()
{
	log "DECRYPTING CONFIG FILES"

	# Set paths.
	declare COMPRESSED=$DIR_TEMPLATES/config/$1-$2.tar
	declare ENCRYPTED=$COMPRESSED.encrypted

	# Decrypt files.
	openssl aes-128-cbc -d -salt -in $ENCRYPTED -out $COMPRESSED

	# Clear current configuration.
	rm -rf $DIR_CONFIG/*.*

	# Decompress files.
	tar xpvf $COMPRESSED -C $DIR_CONFIG

	# Clean up.
	rm $COMPRESSED

	log "DECRYPTED CONFIG FILES"
}

# Commits updates to configuration template files.
run_stack_config_commit()
{
	log "COMMITTING CONFIG FILES"



	log "COMMITTED CONFIG FILES"
}

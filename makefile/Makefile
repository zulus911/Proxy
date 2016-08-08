#General setup for docker
SUBNET_CIDR='172.168.25.0/24'
NETWORK_NAME="isolate_network"

#Mongodb vars
MONGODB_BACKUP_URL=https://s3.amazonaws.com/nyt-mongo-backup/mongodb-backups/coral.tar.gz
MONGODB_DB_PATH=/opt/mongodb/db
MONGODB_CONFIG_PATH=/opt/mongodb/configs
MONGODB_BACKUP_PATH=/opt/mongodb/backup/dump
MONGODB_PORT=27017
MONGODB_INSTANCE_NAME=mongo-server
MOMGODB_VERSION=3.2
MONGODB_USER=coral-user
MONGODB_PASS=kiwort52
MONGODB_DB=coral
MONGODB_AUTH=coral
MONGODB_AUTH_STRING="db.createUser( { user: '$(MONGODB_USER)', pwd: '$(MONGODB_PASS)', roles: [ 'readWrite' ] })"

#RabbitMQ vars
RABBIT_ENV_FILE=rabbitmq.env
RABBIT_USER=rabbit
RABBIT_PASSWORD=rabbit
RABBITMQ_INSTANCE_NAME=rabbitmq-server

#Pillar
PILLAR_ENV_FILE=pillar.env

build-network:
	if [ -z `docker network ls | grep $(NETWORK_NAME)` ]; then  docker network create --subnet=$(SUBNET_CIDR) $(NETWORK_NAME); else echo "Network exists"; fi 

rabbitmq: build-network
	if [ -f $(RABBIT_ENV_FILE).template ];then rm $(RABBIT_ENV_FILE).template && cp $(RABBIT_ENV_FILE) $(RABBIT_ENV_FILE).template; else cp $(RABBIT_ENV_FILE) $(RABBIT_ENV_FILE).template; fi
	sed -i "s/<rabbit_user>/$(RABBIT_USER)/g" $(RABBIT_ENV_FILE).template
	sed -i "s/<rabbit_pass>/$(RABBIT_PASSWORD)/g" $(RABBIT_ENV_FILE).template
	docker run --env-file $(RABBIT_ENV_FILE).template --name $(RABBITMQ_INSTANCE_NAME) --net=$(NETWORK_NAME) -d rabbitmq:management

mongodb: build-network
	if [ -f /tmp/coral.tar.gz ]; then rm /tmp/coral.tar.gz; fi
	wget $(MONGODB_BACKUP_URL) -P/tmp
	if [ -d $(MONGODB_BACKUP_PATH) ]; then echo "$(MONGODB_BACKUP_PATH) exists"; else mkdir -p $(MONGODB_BACKUP_PATH); fi
	if [ -d $(MONGODB_DB_PATH) ]; then echo "$(MONGODB_BACKUP_PATH) exists"; else mkdir -p $(MONGODB_DB_PATH); fi
	if [ -d $(MONGODB_CONFIG_PATH) ]; then echo "$(MONGODB_CONFIG_PATH) exists"; else mkdir -p $(MONGODB_CONFIG_PATH); fi
	tar xvfz /tmp/coral.tar.gz --strip 1 -C $(MONGODB_BACKUP_PATH)
	docker run --net=$(NETWORK_NAME) --name $(MONGODB_INSTANCE_NAME) -v $(MONGODB_DB_PATH):/data/db -p 27017:$(MONGODB_PORT) -d mongo:$(MOMGODB_VERSION)
	mongorestore -d $(MONGODB_DB) $(MONGODB_BACKUP_PATH)
	mongo $(MONGODB_DB) --eval $(MONGODB_AUTH_STRING)

pillar:	mongodb rabbitmq
	#docker run --link $(MONGODB_INSTANCE_NAME):mongodb, $(RABBITMQ_INSTANCE_NAME):rabbitmq -d coralproject/pillar 

clean-dirs:
	if [ -d $(MONGODB_BACKUP_PATH) ]; then rm -rf $(MONGODB_BACKUP_PATH)/*; fi
	if [ -f  /tmp/coral.tar.gz ]; then rm /tmp/coral.tar.gz; fi
	if [ -d $(MONGODB_DB_PATH) ]; then rm -rf $(MONGODB_DB_PATH);fi

clean-docker:
	docker stop $(MONGODB_INSTANCE_NAME)
	docker rm $(MONGODB_INSTANCE_NAME)
	docker rmi mongo:$(MOMGODB_VERSION)
	docker stop $(RABBITMQ_INSTANCE_NAME)
	docker rm $(RABBITMQ_INSTANCE_NAME)
	docker rmi rabbitmq:management
	if [ -n `docker network ls | grep $(NETWORK_NAME)` ];then docker network rm $(NETWORK_NAME);fi

clean-all:	clean-dirs clean-docker

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

rabbitmq:
	docker run --name rabbitmq-server -d rabbitmq:management
mongodb:
	if [ -f /tmp/coral.tar.gz ]; then rm /tmp/coral.tar.gz; fi
	wget $(MONGODB_BACKUP_URL) -P/tmp
	if [ -d $(MONGODB_BACKUP_PATH) ]; then echo "$(MONGODB_BACKUP_PATH) exists"; else mkdir -p $(MONGODB_BACKUP_PATH); fi
	if [ -d $(MONGODB_DB_PATH) ]; then echo "$(MONGODB_BACKUP_PATH) exists"; else mkdir -p $(MONGODB_DB_PATH); fi
	if [ -d $(MONGODB_CONFIG_PATH) ]; then echo "$(MONGODB_CONFIG_PATH) exists"; else mkdir -p $(MONGODB_CONFIG_PATH); fi
	tar xvfz /tmp/coral.tar.gz --strip 1 -C $(MONGODB_BACKUP_PATH)
	docker run --name $(MONGODB_INSTANCE_NAME) -v $(MONGODB_DB_PATH):/data/db -p 27017:$(MONGODB_PORT) -d mongo:$(MOMGODB_VERSION)
	mongorestore -d $(MONGODB_DB) $(MONGODB_BACKUP_PATH)
	mongo $(MONGODB_DB) --eval $(MONGODB_AUTH_STRING)
pillar:	mongodb rabbitmq


clean-all:
	if [ -d $(MONGODB_BACKUP_PATH) ]; then rm -rf $(MONGODB_BACKUP_PATH)/*; fi
	if [ -f  /tmp/coral.tar.gz ]; then rm /tmp/coral.tar.gz; fi
	docker stop $(MONGODB_INSTANCE_NAME)
	docker rm $(MONGODB_INSTANCE_NAME)
	docker rmi mongo:$(MOMGODB_VERSION)
	if [ -d $(MONGODB_DB_PATH) ]; then rm -rf $(MONGODB_DB_PATH);fi

.PHONY: up down cleandata

up:
	docker-compose -f ./pgrest.yml up

down:
	docker-compose -f ./pgrest.yml down

cleandata:
	rm -rf ./pgdata/*
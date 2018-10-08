build:
	docker build . -t codecov/migrate -f migrate/Dockerfile
	docker build . -t codecov/migrate-pg9 -f pg9/Dockerfile
	docker build . -t codecov/migrate-pg10 -f pg10/Dockerfile

test:
	DATABASE_URL=postgres://peak@127.0.0.1:5432 pytest

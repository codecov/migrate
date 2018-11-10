build:
	docker build . -t codecov/migrate -f migrate/Dockerfile
	docker build . -t codecov/migrate-pg9 -f pg9/Dockerfile
	docker build . -t codecov/migrate-pg10 -f pg10/Dockerfile
	docker build . -t codecov/migrate-backup -f backup/Dockerfile


push:
	docker push codecov/migrate
	docker push codecov/migrate-pg9
	docker push codecov/migrate-pg10
	docker push codecov/migrate-backup

test:
	DATABASE_URL=postgres://peak@127.0.0.1:5432 pytest

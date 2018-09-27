build:
	docker build . -t codecov/migrate

test:
	DATABASE_URL=postgres://peak@127.0.0.1:5432 pytest

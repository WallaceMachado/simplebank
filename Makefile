postgres:
	docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=mysecret -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres12 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:mysecret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://root:mysecret@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migratedown:
	migrate -path db/migration -database "postgresql://root:mysecret@localhost:5432/simple_bank?sslmode=disable" -verbose down

migratedown1:
	migrate -path db/migration -database "postgresql://root:mysecret@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

migratecreate:
	migrate create -ext sql -dir db/migration -seq add_users
sqlc:
	sqlc generate

test:
	go test -v -cover ./...


server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/WallaceMachado/simplebank/db/sqlc Store

d-build:
	docker build -t simplebank:latest .

d-run:
	docker run --name simplebank --network bank-network -p 5000:5000 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:mysecret@postgres12:5432/simple_bank?sslmode=disable" simplebank:latest

d-create-network:
	docker network create bank-network

d-connect-network:
	docker network connect bank-network postgres12

d-inspect-network:
	docker network inspect bank-network

d-inspect-container-postgres:
	docker container inspect postgres12

dcu:
	docker-compose up

dcd:
	docker-compose down

.PHONY: postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 sqlc test server mock d-build d-run d-connect-network d-create-network dcu dcd
LOCAL_BIN:=$(CURDIR)/bin

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate:
	make generate-chat-server-api

generate-chat-server-api:
	mkdir -p pkg/chat_server_v1
	protoc --proto_path api/chat_server_v1 \
	--go_out=pkg/chat_server_v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/chat_server_v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/chat_server_v1/chat_server.proto

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.53.3

lint:
	GOBIN=$(LOCAL_BIN) golangci-lint run ./... --config .golangci.pipeline.yaml

build:
	GOOS=linux GOARCH=amd64 go build -o service_linux cmd/main.go

docker-build-and-push:
	docker buildx build --no-cache --platform linux/amd64 -t isergos/chat-server:v0.0.1 .
	docker login -u isergos -p dckr_pat_SYr7_l-Pni6wnQt1QtQsZYTpxkQ
	docker push isergos/chat-server:v0.0.1
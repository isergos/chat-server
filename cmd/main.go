package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"google.golang.org/protobuf/types/known/emptypb"

	desc "github.com/isergos/chat-server/pkg/chat_server_v1"
)

const grpcPort = 50052

type server struct {
	desc.UnimplementedChatServerV1Server
}

func (s *server) Create(_ context.Context, req *desc.CreateRequest) (*desc.CreateResponse, error) {
	log.Printf("user id: %v", req.GetUserNames())

	return &desc.CreateResponse{Id: 5}, nil
}

func (s *server) Delete(_ context.Context, req *desc.DeleteRequest) (*emptypb.Empty, error) {
	log.Printf("user id: %d", req.GetId())

	return &emptypb.Empty{}, nil
}

func (s *server) SendMessage(_ context.Context, req *desc.SendMessageRequest) (*emptypb.Empty, error) {
	log.Printf("message: %v", req.MessageInfo)

	return &emptypb.Empty{}, nil
}

func main() {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", grpcPort))

	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	reflection.Register(s)
	desc.RegisterChatServerV1Server(s, &server{})

	log.Printf("server listening at %v", lis.Addr())

	if err = s.Serve(lis); err != nil {
		log.Fatalf("failed to serve:  %v", err)
	}
}

package util

import (
	"context"
	"fmt"
	"log"
	"time"

	playingfieldpb "tit_for_tat/generated/playing_field"
	strategypb "tit_for_tat/generated/strategy"
	"tit_for_tat/server"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

// Connect to the PlayingField service using the specified address and public key credentials
func ConnectToPlayingField(playingFieldAddr string, creds credentials.TransportCredentials) (*grpc.ClientConn, playingfieldpb.PlayingFieldClient) {
	conn, err := grpc.NewClient(playingFieldAddr, grpc.WithTransportCredentials(creds))
	if err != nil {
		log.Fatalf("Failed to connect to PlayingField service: %v", err)
	}

	client := playingfieldpb.NewPlayingFieldClient(conn)
	return conn, client
}

// Notify the PlayingField service that this strategy is available
func SubscribeToPlayingField(client playingfieldpb.PlayingFieldClient, port string) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	_, err := client.Subscribe(ctx, &playingfieldpb.StrategyInfo{
		Name:    "Tit-for-Tat",
		Address: fmt.Sprintf("https://localhost:%s", port),
	})
	if err != nil {
		log.Fatalf("Failed to subscribe to PlayingField service: %v", err)
	}
}

// Create a gRPC server with the private key credentials
func CreateStrategyServer(creds credentials.TransportCredentials) *grpc.Server {
	strategyServer := grpc.NewServer(grpc.Creds(creds))
	strategypb.RegisterStrategyServer(strategyServer, &server.Server{})
	return strategyServer
}

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"
	"time"

	modelpb "tit_for_tat/generated/model"
	pf "tit_for_tat/generated/playing_field"
	pb "tit_for_tat/generated/strategy"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

const (
	CertificateSettingsEnvVar = "CERTIFICATE_SETTINGS"
	TitForTatPortEnvVar       = "TIT_FOR_TAT_PORT"
	PlayingFieldPortEnvVar    = "PLAYING_FIELD_PORT"
)

// server implements the StrategyServer interface
type server struct {
	pb.UnimplementedStrategyServer
}

// HandleRequest implements the Tit-for-Tat strategy
func (s *server) HandleRequest(ctx context.Context, req *pb.HandleRequestRequest) (*pb.HandleRequestResponse, error) {
	lastOpponentAction := req.GetOpponentAction()
	var action modelpb.PlayerAction

	// Tit-for-Tat logic: cooperate if last action was NONE or COOPERATED, otherwise defect
	if lastOpponentAction == modelpb.OpponentAction_NONE || lastOpponentAction == modelpb.OpponentAction_COOPERATED {
		action = modelpb.PlayerAction_COOPERATE
	} else {
		action = modelpb.PlayerAction_DEFECT
	}

	// Return the player's action in the response
	return &pb.HandleRequestResponse{PlayerAction: action}, nil
}

type CertificateSettings struct {
	Path     string
	Password string
}

func main() {
	// Get the certificate settings from the environment variable
	certSettingsJson := os.Getenv(CertificateSettingsEnvVar)
	if certSettingsJson == "" {
		log.Fatalf("%s environment variable not set", CertificateSettingsEnvVar)
	}

	// Parse the certificate settings JSON
	var certSettings CertificateSettings
	if err := json.Unmarshal([]byte(certSettingsJson), &certSettings); err != nil {
		log.Fatalf("Failed to parse certificate settings: %v", err)
	}

	// Get the port from the environment variable
	port := os.Getenv(TitForTatPortEnvVar)
	if port == "" {
		log.Fatalf("%s environment variable not set", TitForTatPortEnvVar)
	}

	// Get the playing field port from the environment variable
	playingFieldPort := os.Getenv(PlayingFieldPortEnvVar)
	if playingFieldPort == "" {
		log.Fatalf("%s environment variable not set", PlayingFieldPortEnvVar)
	}

	// Create a TCP listener on the specified port
	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	// Load the TLS credentials from the certificate file
	certPath, keyPath := fmt.Sprintf("%s.crt", certSettings.Path), fmt.Sprintf("%s.key", certSettings.Path)
	creds, err := credentials.NewServerTLSFromFile(certPath, keyPath)
	if err != nil {
		log.Fatalf("Failed to load TLS credentials: %v", err)
	}

	// Create a new gRPC server with the TLS credentials
	grpcServer := grpc.NewServer(grpc.Creds(creds))

	// Register the strategy service with the gRPC server
	pb.RegisterStrategyServer(grpcServer, &server{})

	// Log the server listening address and start serving
	log.Printf("Server listening at %v", lis.Addr())

	// TODO: Fix certifacte issue
	// Connect to the PlayingField service
	playingFieldAddr := fmt.Sprintf("localhost:%s", playingFieldPort)
	conn, err := grpc.NewClient(playingFieldAddr, grpc.WithTransportCredentials(creds))
	if err != nil {
		log.Fatalf("Failed to connect to PlayingField service: %v", err)
	}
	defer conn.Close()

	playingFieldClient := pf.NewPlayingFieldClient(conn)

	// Subscribe to the PlayingField service
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	_, err = playingFieldClient.Subscribe(ctx, &pf.StrategyInfo{
		Name:    "TitForTatStrategy",
		Address: fmt.Sprintf("localhost:%s", port),
	})
	if err != nil {
		log.Fatalf("Failed to subscribe to PlayingField service: %v", err)
	}

	// Serve the gRPC server
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

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
	certSettings := getCertificateSettings()
	port := getEnvVariable(TitForTatPortEnvVar)
	playingFieldPort := getEnvVariable(PlayingFieldPortEnvVar)

	lis := createTCPListener(port)
	serverCreds, clientCreds := loadTLSCredentials(certSettings)

	strategyServer := createStrategyServer(serverCreds)
	log.Printf("Server listening at %v", lis.Addr())

	playingFieldAddr := fmt.Sprintf("localhost:%s", playingFieldPort)
	conn, client := connectToPlayingField(playingFieldAddr, clientCreds)
	defer conn.Close()

	subscribeToPlayingField(client, port)

	if err := strategyServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

// Read the certificate settings from the environment and parse them into a struct
func getCertificateSettings() CertificateSettings {
	certSettingsJson := os.Getenv(CertificateSettingsEnvVar)
	if certSettingsJson == "" {
		log.Fatalf("%s environment variable not set", CertificateSettingsEnvVar)
	}

	var certSettings CertificateSettings
	if err := json.Unmarshal([]byte(certSettingsJson), &certSettings); err != nil {
		log.Fatalf("Failed to parse certificate settings: %v", err)
	}

	return certSettings
}

// Get an environment variable, and log an error if it is not set
func getEnvVariable(varName string) string {
	value := os.Getenv(varName)
	if value == "" {
		log.Fatalf("%s environment variable not set", varName)
	}
	return value
}

// Create a TCP listener on the specified port
func createTCPListener(port string) net.Listener {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}
	return lis
}

// Load the TLS credentials from the specified certificate settings (public key and private key)
func loadTLSCredentials(certSettings CertificateSettings) (credentials.TransportCredentials, credentials.TransportCredentials) {
	publicKeyPath, privateKeyPath := fmt.Sprintf("%s.crt", certSettings.Path), fmt.Sprintf("%s.key", certSettings.Path)

	// Load the server and client credentials from the public key and private key (private key credentials)
	serverCreds, err := credentials.NewServerTLSFromFile(publicKeyPath, privateKeyPath)
	if err != nil {
		log.Fatalf("Failed to load TLS credentials: %v", err)
	}

	// Load the client credentials from the public key (public key credentials)
	// - used to access other services (e.g. PlayingField)
	clientCreds, err := credentials.NewClientTLSFromFile(publicKeyPath, "localhost")
	if err != nil {
		log.Fatalf("Failed to load TLS credentials: %v", err)
	}

	return serverCreds, clientCreds
}

// Create a gRPC server with the private key credentials
func createStrategyServer(creds credentials.TransportCredentials) *grpc.Server {
	strategyServer := grpc.NewServer(grpc.Creds(creds))
	pb.RegisterStrategyServer(strategyServer, &server{})
	return strategyServer
}

// Connect to the PlayingField service using the specified address and public key credentials
func connectToPlayingField(playingFieldAddr string, creds credentials.TransportCredentials) (*grpc.ClientConn, pf.PlayingFieldClient) {
	conn, err := grpc.NewClient(playingFieldAddr, grpc.WithTransportCredentials(creds))
	if err != nil {
		log.Fatalf("Failed to connect to PlayingField service: %v", err)
	}

	client := pf.NewPlayingFieldClient(conn)
	return conn, client
}

// Notify the PlayingField service that this strategy is available
func subscribeToPlayingField(client pf.PlayingFieldClient, port string) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	_, err := client.Subscribe(ctx, &pf.StrategyInfo{
		Name:    "Tit-for-Tat",
		Address: fmt.Sprintf("https://localhost:%s", port),
	})
	if err != nil {
		log.Fatalf("Failed to subscribe to PlayingField service: %v", err)
	}
}

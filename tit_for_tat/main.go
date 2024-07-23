package main

import (
	"fmt"
	"log"

	"tit_for_tat/util"
)

const (
	// Environment variable keys
	CertificateSettingsEnvVar = "CERTIFICATE_SETTINGS"
	TitForTatPortEnvVar       = "TIT_FOR_TAT_PORT"
	PlayingFieldPortEnvVar    = "PLAYING_FIELD_PORT"
)

func main() {
	// Retrieve certificate settings from environment variable
	certSettings := util.GetCertificateSettings(CertificateSettingsEnvVar)
	// Retrieve Tit-for-Tat port from environment variable
	port := util.GetEnvVariable(TitForTatPortEnvVar)
	// Retrieve PlayingField port from environment variable
	playingFieldPort := util.GetEnvVariable(PlayingFieldPortEnvVar)

	// Create a TCP listener on the specified port
	lis := util.CreateTCPListener(port)
	// Load TLS credentials for the server and client
	serverCreds, clientCreds := util.LoadTLSCredentials(certSettings)

	// Create a gRPC server with the TLS credentials
	strategyServer := util.CreateStrategyServer(serverCreds)
	log.Printf("Server listening at %v", lis.Addr())

	// Connect to the PlayingField service
	playingFieldAddr := fmt.Sprintf("localhost:%s", playingFieldPort)
	conn, client := util.ConnectToPlayingField(playingFieldAddr, clientCreds)
	defer conn.Close()

	// Subscribe to the PlayingField service
	util.SubscribeToPlayingField(client, port)

	// Start the gRPC server
	if err := strategyServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

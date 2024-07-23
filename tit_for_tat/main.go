package main

import (
	"fmt"
	"log"

	"tit_for_tat/util"
)

const (
	CertificateSettingsEnvVar = "CERTIFICATE_SETTINGS"
	TitForTatPortEnvVar       = "TIT_FOR_TAT_PORT"
	PlayingFieldPortEnvVar    = "PLAYING_FIELD_PORT"
)

func main() {
	certSettings := util.GetCertificateSettings(CertificateSettingsEnvVar)
	port := util.GetEnvVariable(TitForTatPortEnvVar)
	playingFieldPort := util.GetEnvVariable(PlayingFieldPortEnvVar)

	lis := util.CreateTCPListener(port)
	serverCreds, clientCreds := util.LoadTLSCredentials(certSettings)

	strategyServer := util.CreateStrategyServer(serverCreds)
	log.Printf("Server listening at %v", lis.Addr())

	playingFieldAddr := fmt.Sprintf("localhost:%s", playingFieldPort)
	conn, client := util.ConnectToPlayingField(playingFieldAddr, clientCreds)
	defer conn.Close()

	util.SubscribeToPlayingField(client, port)

	if err := strategyServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}

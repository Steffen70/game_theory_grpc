package util

import (
	"encoding/json"
	"fmt"
	"log"

	"google.golang.org/grpc/credentials"
)

type CertificateSettings struct {
	Path     string
	Password string
}

// Load the TLS credentials from the specified certificate settings (public key and private key)
func LoadTLSCredentials(certSettings CertificateSettings) (credentials.TransportCredentials, credentials.TransportCredentials) {
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

// Read the certificate settings from the environment and parse them into a struct
func GetCertificateSettings(envVar string) CertificateSettings {
	certSettingsJson := GetEnvVariable(envVar)
	var certSettings CertificateSettings
	if err := json.Unmarshal([]byte(certSettingsJson), &certSettings); err != nil {
		log.Fatalf("Failed to parse certificate settings: %v", err)
	}
	return certSettings
}

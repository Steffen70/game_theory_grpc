package util

import (
	"fmt"
	"log"
	"net"
	"os"
)

// Get an environment variable, and log an error if it is not set
func GetEnvVariable(varName string) string {
	value := os.Getenv(varName)
	if value == "" {
		log.Fatalf("%s environment variable not set", varName)
	}
	return value
}

// Create a TCP listener on the specified port
func CreateTCPListener(port string) net.Listener {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", port))
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}
	return lis
}

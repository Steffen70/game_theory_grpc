/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Author: Steffen70 <steffen@seventy.mx>
 * Creation Date: 2024-07-25
 *
 * Contributors:
 * - Contributor Name <contributor@example.com>
 */

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

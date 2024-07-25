<?php
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

namespace App\Utils;

use Grpc\ChannelCredentials;
use PlayingField\PlayingFieldClient;

class GrpcUtil
{
    /**
     * Creates a gRPC client for the PlayingField service with the given port and certificate settings.
     *
     * @param string $playingFieldPort The port for the PlayingField service.
     * @param array $certSettings The certificate settings for secure gRPC communication.
     * @return PlayingFieldClient The initialized gRPC client for the PlayingField service.
     */
    public static function createClient($playingFieldPort, $certSettings)
    {
        // Create a new PlayingFieldClient with the specified port and TLS credentials.
        return new PlayingFieldClient("localhost:$playingFieldPort", [
            // Add ../ to the path, because we are in the public directory and the path is relative to the project root (php_interface = ../)
            'credentials' => ChannelCredentials::createSsl(file_get_contents('../' . $certSettings['path'] . '.crt'))
        ]);
    }
}

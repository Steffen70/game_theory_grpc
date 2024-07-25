# Game Theory gRPC Sample Project

This repository demonstrates a game theory scenario using multiple services written in different languages, all communicating via gRPC. The project showcases gRPC server-client interactions, server-side rendering with PHP, and the integration of different programming languages through gRPC.

## TODO

-   [x] Refactor `flake.nix` into smaller, separate files for each service; create a main `flake.nix` that imports all the service-specific files.
-   [ ] Add a package output to each service's `flake.nix` to build a standalone package for each service.
-   [ ] Add a package output to the main flake to build all services as a single package.
-   [ ] Test the Friedman Python strategy service.
-   [ ] Test the PHP interface by running a matchup between Friedman and Tit-for-Tat.
-   [ ] Implement a React web app for displaying `RoundResults` in real-time using gRPC-Web, and embed it in the `index.php`.
-   [ ] Implement CI/CD with Docker, using Nix flakes to install dependencies inside the Docker container.
-   [ ] Create an Auth-Provider service that uses OpenIddict to authenticate against a local user database.
-   [ ] Secure all services with the custom Auth-Provider (OAuth2.0/OpenId).

## Overview

### Services

-   **Main Service (`playing_field`)**: The central hub that orchestrates the game theory matchups. Written in C# using ASP.NET Core.
-   **PHP Web Interface (`php_interface`)**: A PHP-based web interface that interacts with the `playing_field` service, allowing users to initiate matchups and view results.
-   **Strategy Services**: Individual services that implement specific game theory strategies. Each service communicates with the `playing_field` service and acts as a gRPC server.

### Strategy Implementations

-   **Tit-for-Tat Strategy (`tit_for_tat`)**: Implemented in Go.
-   **Friedman Strategy (`friedman`)**: Implemented in Python.

## Getting Started

### Prerequisites

-   **Nix**: For managing dependencies and environment setup.
-   Code editor of choice: VSCode, Rider, PyCharm, PHPStorm, etc.

Run `nix develop` to install all dependencies and set the required environment variables.

Then enter the code editor from your shell to make sure the IDE/Editor will get the required context/path variables set by `nix develop`, e.g., `code .`.

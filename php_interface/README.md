# PHP Web Interface - `php_interface`

The PHP web interface demonstrates server-side rendering with gRPC data. It interacts with the `playing_field` service to load subscribed strategies and initiate matchups.

```powershell
# Install the PHP dependencies
composer install

# Generate the PHP gRPC client stubs
./generate_php.sh

# Navigate to the public directory
cd ./public

# Start the PHP built-in server
php -S localhost:$env:PHP_INTERFACE_PORT
```

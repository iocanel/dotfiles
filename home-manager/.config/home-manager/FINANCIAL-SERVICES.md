# Financial Services Module

This module provides a unified way to manage all financial-related services through systemd.

## Services Included

- **Firefly III** - Personal finance manager
  - **firefly-docker-network** - Docker network setup
  - **firefly-env-init** - Environment initialization
  - **firefly-iii** - Main Firefly III application
  - **firefly-importer** - Data importer service

## Usage

### Control All Financial Services

```bash
# Start all financial services
systemctl --user start financial-services.target

# Stop all financial services  
systemctl --user stop financial-services.target

# Check status of all services
systemctl --user status financial-services.target

# Enable/disable auto-start
systemctl --user enable financial-services.target
systemctl --user disable financial-services.target
```

### Control Individual Services

```bash
# Individual service control still works
systemctl --user start firefly-iii.service
systemctl --user stop firefly-importer.service
systemctl --user status firefly-docker-network.service
```

## Configuration

In your `home.nix`:

```nix
services.financial-services = {
  enable = true;
  
  firefly = {
    enable = true;
    siteOwner = "your-email@example.com";
    serverPort = 8090;    # Default
    importerPort = 8091;  # Default
    
    # Optional: customize Docker images
    serverImage = "fireflyiii/core:latest";
    importerImage = "fireflyiii/data-importer:latest";
    
    # Optional: customize network name
    networkName = "firefly-net";
  };
};
```

## Ports

- **Firefly III Server**: http://localhost:8090
- **Firefly III Importer**: http://localhost:8091

## Data Storage

- Configuration: `~/.config/firefly/`
- Database: `~/.config/firefly/db/database.sqlite`
- Exports: `~/.config/firefly/export/`
- Uploads: `~/.config/firefly/upload/`

## How It Works

- All services are grouped under the `financial-services.target` systemd target
- Services have proper dependencies (network setup → env init → main app → importer)
- Each service uses `PartOf` to bind to the target - when the target stops, all services stop
- The target uses `Wants` to declare dependencies on all services
- Environment files are automatically generated on first run
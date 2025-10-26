# Media Center Module

This module provides a unified way to manage all media center services through systemd.

## Services Included

- **Emby Server** - Media streaming server
- **Sonarr** - TV series management
- **Radarr** - Movie management  
- **Bazarr** - Subtitle management
- **Readarr** - Book/audiobook management
- **Jackett** - Torrent indexer

## Usage

### Control All Services

```bash
# Start all media center services
systemctl --user start media-center.target

# Stop all media center services  
systemctl --user stop media-center.target

# Check status of all services
systemctl --user status media-center.target

# Enable/disable auto-start
systemctl --user enable media-center.target
systemctl --user disable media-center.target
```

### Control Individual Services

```bash
# Individual service control still works
systemctl --user start sonarr.service
systemctl --user stop radarr.service
systemctl --user status jackett.service
```

## Configuration

In your `home.nix`:

```nix
services.media-center = {
  enable = true;
  userId = 1000;
  groupId = 100;
  timezone = "Europe/Athens";
  
  # Enable/disable individual services
  emby.enable = true;
  sonarr.enable = true;
  radarr.enable = true;
  bazarr.enable = true;
  readarr.enable = true;
  jackett.enable = true;
  
  # Customize ports if needed
  emby.port = 8096;
  sonarr.port = 8989;
  # ... etc
};
```

## How It Works

- All services are grouped under the `media-center.target` systemd target
- Each service uses `PartOf` to bind to the target - when the target stops, all services stop
- The target uses `Wants` to declare dependencies on all services
- Services are automatically started when the target starts (if enabled)
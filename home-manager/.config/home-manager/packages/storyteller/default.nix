{ pkgs, lib, ... }:

let
  storytellerDockerCompose = pkgs.writeText "storyteller-compose.yaml" ''
    services:
      storyteller:
        image: registry.gitlab.com/storyteller-platform/storyteller:latest
        container_name: storyteller
        volumes:
          - ~/Documents/Storyteller:/data:rw
        environment:
          - STORYTELLER_SECRET_KEY_FILE=/data/STORYTELLER_SECRET_KEY.txt
          - ENABLE_WEB_READER=true
        ports:
          - "8001:8001"
        restart: unless-stopped
  '';

  storytellerWrapper = pkgs.writeShellScriptBin "storyteller" ''
    set -e
    
    DATA_DIR="$HOME/Documents/Storyteller"
    SECRET_FILE="$DATA_DIR/STORYTELLER_SECRET_KEY.txt"
    COMPOSE_FILE="$HOME/.config/storyteller/compose.yaml"
    
    # Create data directory
    mkdir -p "$DATA_DIR"
    mkdir -p "$(dirname "$COMPOSE_FILE")"
    
    # Generate secret key if it doesn't exist
    if [ ! -f "$SECRET_FILE" ]; then
      echo "Generating Storyteller secret key..."
      ${pkgs.openssl}/bin/openssl rand -base64 32 > "$SECRET_FILE"
      echo "Secret key saved to: $SECRET_FILE"
    fi
    
    # Copy compose file
    cp ${storytellerDockerCompose} "$COMPOSE_FILE"
    
    case "''${1:-start}" in
      start)
        echo "Starting Storyteller..."
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" up -d
        echo "Storyteller is running at http://localhost:8001"
        ;;
      stop)
        echo "Stopping Storyteller..."
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" down
        ;;
      restart)
        echo "Restarting Storyteller..."
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" restart
        ;;
      logs)
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" logs -f
        ;;
      status)
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" ps
        ;;
      update)
        echo "Updating Storyteller..."
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" pull
        ${pkgs.docker-compose}/bin/docker-compose -f "$COMPOSE_FILE" up -d
        ;;
      *)
        echo "Usage: storyteller {start|stop|restart|logs|status|update}"
        echo ""
        echo "Commands:"
        echo "  start   - Start Storyteller (default)"
        echo "  stop    - Stop Storyteller"
        echo "  restart - Restart Storyteller"
        echo "  logs    - Show Storyteller logs"
        echo "  status  - Show Storyteller status"
        echo "  update  - Update and restart Storyteller"
        exit 1
        ;;
    esac
  '';

in
pkgs.symlinkJoin {
  name = "storyteller";
  paths = [ storytellerWrapper ];
  buildInputs = [ pkgs.docker-compose pkgs.openssl ];
  
  meta = with lib; {
    description = "Storyteller self-hosted platform wrapper";
    homepage = "https://storyteller-platform.gitlab.io/storyteller/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [];
  };
}
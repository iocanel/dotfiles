{ pkgs
, lib ? pkgs.lib
, version ? "0.1.0"
}:

let
  # Use string path to avoid nix copying to store (allows local node_modules updates)
  lifestyleDbSrc = "/home/iocanel/workspace/src/github.com/iocanel/lifestyle-db";

  # CLI for syncing data - uses 'node' from PATH to match the node_modules build
  lifestyleSyncCli = pkgs.writeShellScriptBin "lifestyle-sync" ''
    cd ${lifestyleDbSrc}
    exec node dist/sync/cli.js "$@"
  '';

  # MCP server
  lifestyleDbMcp = pkgs.writeShellScriptBin "lifestyle-db-mcp" ''
    cd ${lifestyleDbSrc}
    exec node dist/mcp/server.js "$@"
  '';

  # Combined CLI — passes all arguments directly to Commander
  lifestyleDbCli = pkgs.writeShellScriptBin "lifestyle-db" ''
    cd ${lifestyleDbSrc}
    exec node dist/sync/cli.js "$@"
  '';

in
pkgs.symlinkJoin {
  name = "lifestyle-db-${version}";
  paths = [ lifestyleDbCli lifestyleSyncCli lifestyleDbMcp ];

  meta = with lib; {
    description = "Aggregated lifestyle database with hybrid SQL + semantic search";
    homepage = "https://github.com/iocanel/lifestyle-db";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "lifestyle-db";
    maintainers = [];
  };
}

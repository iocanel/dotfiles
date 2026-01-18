#!/bin/bash

# Unified terminal script - detects GitHub vs GitLab and calls appropriate script

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

# Open terminal in repository function
open_terminal() {
    local url="$1"
    local host=$(extract_host "$url")
    local org=$(extract_organization "$url")
    local repo=$(extract_repository "$url")
    local ssh_url=$(build_ssh_url "$host" "$org" "$repo")
    local workspace=$(build_workspace_path "$host" "$org")
    
    kitty --title "Auxiliary Terminal" -e bash -c "source '$SCRIPT_DIR/git-lib.sh'; mkdir -p $workspace; cd $workspace; if [ ! -d ${repo} ]; then smart_clone '$host' '$org' '$repo' '$repo'; fi; cd $repo; exec fish"
}

# Route to appropriate implementation (fallback for compatibility)
route_terminal() {
    local url="$1"
    if is_github "$url"; then
        exec "$SCRIPT_DIR/github-terminal.sh" "$url"
    else
        exec "$SCRIPT_DIR/gitlab-terminal.sh" "$url"
    fi
}

# Test functions
test_open_terminal() {
    # Mock kitty to test function logic
    kitty() {
        echo "Mock kitty called with: $*"
    }
    
    # Test GitHub terminal
    local result=$(open_terminal "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "mkdir -p ~/workspace/src/github.com/owner"; then
        echo "✓ open_terminal works for GitHub"
    else
        echo "✗ open_terminal failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab terminal
    local result=$(open_terminal "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "mkdir -p ~/workspace/src/gitlab.example.com/owner"; then
        echo "✓ open_terminal works for GitLab"
    else
        echo "✗ open_terminal failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

test_route_terminal() {
    # Mock exec to test routing logic
    exec() {
        echo "Routed to: $*"
    }
    
    # Test GitHub routing
    local result=$(route_terminal "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "github-terminal.sh"; then
        echo "✓ route_terminal works for GitHub"
    else
        echo "✗ route_terminal failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab routing
    local result=$(route_terminal "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "gitlab-terminal.sh"; then
        echo "✓ route_terminal works for GitLab"
    else
        echo "✗ route_terminal failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

# Handle command line arguments
if [ "$1" = "--test" ]; then
    echo "Running tests for git-terminal.sh..."
    failed=0
    
    test_open_terminal || failed=1
    test_route_terminal || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        exit 0
    else
        echo "Some tests failed!"
        exit 1
    fi
fi

# Main execution - use new open_terminal function
open_terminal "$1"
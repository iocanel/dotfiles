#!/bin/bash

# Unified git clone script - detects GitHub vs GitLab and calls appropriate script

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

# Clone repository function
clone_repo() {
    local url="$1"
    local host=$(extract_host "$url")
    local org=$(extract_organization "$url")
    local repo=$(extract_repository "$url")
    local workspace=$(build_workspace_path "$host" "$org")
    
    kitty --class EditorTerm -e bash -c "mkdir -p $workspace; cd $workspace; $(declare -f smart_clone); $(declare -f get_clone_method); $(declare -f build_ssh_url); $(declare -f build_https_url); $(declare -f clone_with_fallback); smart_clone '$host' '$org' '$repo' '$repo'; exec fish"
}

# Route to appropriate implementation (fallback for compatibility)
route_clone() {
    local url="$1"
    if is_github "$url"; then
        exec "$SCRIPT_DIR/github-clone.sh" "$url"
    else
        exec "$SCRIPT_DIR/gitlab-clone.sh" "$url"
    fi
}

# Test functions
test_clone_repo() {
    # Mock kitty to test function logic
    kitty() {
        echo "Mock kitty called with: $*"
    }
    
    # Test GitHub clone
    local result=$(clone_repo "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "mkdir -p ~/workspace/src/github.com/owner"; then
        echo "✓ clone_repo works for GitHub"
    else
        echo "✗ clone_repo failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab clone
    local result=$(clone_repo "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "mkdir -p ~/workspace/src/gitlab.example.com/owner"; then
        echo "✓ clone_repo works for GitLab"
    else
        echo "✗ clone_repo failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

test_route_clone() {
    # Mock exec to test routing logic
    exec() {
        echo "Routed to: $*"
    }
    
    # Test GitHub routing
    local result=$(route_clone "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "github-clone.sh"; then
        echo "✓ route_clone works for GitHub"
    else
        echo "✗ route_clone failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab routing
    local result=$(route_clone "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "gitlab-clone.sh"; then
        echo "✓ route_clone works for GitLab"
    else
        echo "✗ route_clone failed for GitLab: $result"
        return 1
    fi
    
    return 0
}


# Handle command line arguments
if [ "$1" = "--test" ]; then
    # Don't run lib tests, just our own tests
    echo "Running tests for git-clone.sh..."
    failed=0
    
    test_clone_repo || failed=1
    test_route_clone || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        exit 0
    else
        echo "Some tests failed!"
        exit 1
    fi
fi

# Main execution - use new clone_repo function
clone_repo "$1"
#!/bin/bash

# Unified goto fork script - detects GitHub vs GitLab and calls appropriate script

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

# Go to fork function
goto_fork() {
    local url="$1"
    local host=$(extract_host "$url")
    local repo=$(extract_repository "$url")
    local path=$(extract_path "$url")
    
    local fork_url="https://$host/iocanel/$repo$path"
    echo "open -t $fork_url" >> $QUTE_FIFO
}

# Route to appropriate implementation (fallback for compatibility)
route_goto_fork() {
    local url="$1"
    if is_github "$url"; then
        exec "$SCRIPT_DIR/github-goto-fork.sh" "$url"
    else
        exec "$SCRIPT_DIR/gitlab-goto-fork.sh" "$url"
    fi
}

# Test functions
test_goto_fork() {
    # Mock QUTE_FIFO and echo
    local temp_fifo=$(mktemp)
    export QUTE_FIFO="$temp_fifo"
    
    # Test GitHub fork
    goto_fork "https://github.com/owner/repo/blob/main/file.txt"
    local result=$(cat "$temp_fifo")
    if echo "$result" | grep -q "open -t https://github.com/iocanel/repo/blob/main/file.txt"; then
        echo "✓ goto_fork works for GitHub"
    else
        echo "✗ goto_fork failed for GitHub: $result"
        rm "$temp_fifo"
        return 1
    fi
    
    # Clear fifo
    > "$temp_fifo"
    
    # Test GitLab fork
    goto_fork "https://gitlab.example.com/owner/repo/-/blob/main/file.txt"
    local result=$(cat "$temp_fifo")
    if echo "$result" | grep -q "open -t https://gitlab.example.com/iocanel/repo/-/blob/main/file.txt"; then
        echo "✓ goto_fork works for GitLab"
    else
        echo "✗ goto_fork failed for GitLab: $result"
        rm "$temp_fifo"
        return 1
    fi
    
    rm "$temp_fifo"
    unset QUTE_FIFO
    return 0
}

test_route_goto_fork() {
    # Mock exec to test routing logic
    exec() {
        echo "Routed to: $*"
    }
    
    # Test GitHub routing
    local result=$(route_goto_fork "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "github-goto-fork.sh"; then
        echo "✓ route_goto_fork works for GitHub"
    else
        echo "✗ route_goto_fork failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab routing
    local result=$(route_goto_fork "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "gitlab-goto-fork.sh"; then
        echo "✓ route_goto_fork works for GitLab"
    else
        echo "✗ route_goto_fork failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

# Handle command line arguments
if [ "$1" = "--test" ]; then
    echo "Running tests for git-goto-fork.sh..."
    failed=0
    
    test_goto_fork || failed=1
    test_route_goto_fork || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        exit 0
    else
        echo "Some tests failed!"
        exit 1
    fi
fi

# Main execution - use new goto_fork function
goto_fork "$1"
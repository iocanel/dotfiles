#!/bin/bash

# Unified new issue script - detects GitHub vs GitLab and calls appropriate script

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

# Create new issue function
new_issue() {
    local url="$1"
    local host=$(extract_host "$url")
    local org=$(extract_organization "$url")
    local repo=$(extract_repository "$url")
    
    local new_issue_url
    if is_github "$url"; then
        new_issue_url="https://$host/$org/$repo/issues/new"
    else
        new_issue_url="https://$host/$org/$repo/-/issues/new"
    fi
    
    echo "open -t $new_issue_url" >> $QUTE_FIFO
}

# Route to appropriate implementation (fallback for compatibility)
route_new_issue() {
    local url="$1"
    if is_github "$url"; then
        exec "$SCRIPT_DIR/github-new-issue.sh" "$url"
    else
        exec "$SCRIPT_DIR/gitlab-new-issue.sh" "$url"
    fi
}

# Test functions
test_new_issue() {
    # Mock QUTE_FIFO
    local temp_fifo=$(mktemp)
    export QUTE_FIFO="$temp_fifo"
    
    # Test GitHub new issue
    new_issue "https://github.com/owner/repo"
    local result=$(cat "$temp_fifo")
    if echo "$result" | grep -q "open -t https://github.com/owner/repo/issues/new"; then
        echo "✓ new_issue works for GitHub"
    else
        echo "✗ new_issue failed for GitHub: $result"
        rm "$temp_fifo"
        return 1
    fi
    
    # Clear fifo
    > "$temp_fifo"
    
    # Test GitLab new issue
    new_issue "https://gitlab.example.com/owner/repo"
    local result=$(cat "$temp_fifo")
    if echo "$result" | grep -q "open -t https://gitlab.example.com/owner/repo/-/issues/new"; then
        echo "✓ new_issue works for GitLab"
    else
        echo "✗ new_issue failed for GitLab: $result"
        rm "$temp_fifo"
        return 1
    fi
    
    rm "$temp_fifo"
    unset QUTE_FIFO
    return 0
}

test_route_new_issue() {
    # Mock exec to test routing logic
    exec() {
        echo "Routed to: $*"
    }
    
    # Test GitHub routing
    local result=$(route_new_issue "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "github-new-issue.sh"; then
        echo "✓ route_new_issue works for GitHub"
    else
        echo "✗ route_new_issue failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab routing
    local result=$(route_new_issue "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "gitlab-new-issue.sh"; then
        echo "✓ route_new_issue works for GitLab"
    else
        echo "✗ route_new_issue failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

# Handle command line arguments
if [ "$1" = "--test" ]; then
    echo "Running tests for git-new-issue.sh..."
    failed=0
    
    test_new_issue || failed=1
    test_route_new_issue || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        exit 0
    else
        echo "Some tests failed!"
        exit 1
    fi
fi

# Main execution - use new new_issue function
new_issue "$1"

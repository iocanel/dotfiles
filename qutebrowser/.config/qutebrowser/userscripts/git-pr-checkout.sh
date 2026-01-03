#!/bin/bash

# Unified PR/MR checkout script - detects GitHub vs GitLab and calls appropriate script

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

# Checkout PR/MR function
checkout_pr() {
    local url="$1"
    local host=$(extract_host "$url")
    local org=$(extract_organization "$url")
    local repo=$(extract_repository "$url")
    local ssh_url=$(build_ssh_url "$host" "$org" "$repo")
    
    local pr_number
    if is_github "$url"; then
        pr_number=$(extract_github_pr_number "$url")
        local script_name="clone_pr.sh"
        local checkout_cmd="gh pr checkout $pr_number"
    else
        pr_number=$(extract_gitlab_mr_number "$url")
        local script_name="clone_mr.sh"
        local checkout_cmd="glab mr checkout $pr_number"
    fi
    
    # Create a script to run in kitty
    local temp_script=~/$script_name
    cat <<EOF > $temp_script
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

TEMP_DIR=\$(mktemp -d)
cd \$TEMP_DIR
echo "Checking out $(if is_github "$url"; then echo "pull request"; else echo "merge request"; fi): $pr_number into \$TEMP_DIR/$repo..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$host" "$org" "$repo" "$repo"

# Check if clone was successful
if [ ! -d "$repo" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $repo
$checkout_cmd

exec fish
EOF

    chmod +x $temp_script
    kitty --class EditorTerm -e bash -c "$temp_script"
}

# Route to appropriate implementation (fallback for compatibility)
route_checkout_pr() {
    local url="$1"
    if is_github "$url"; then
        exec "$SCRIPT_DIR/github-pr-checkout.sh" "$url"
    else
        exec "$SCRIPT_DIR/gitlab-mr-checkout.sh" "$url"
    fi
}

# Test functions
test_checkout_pr() {
    # Mock kitty, chmod, and cat
    kitty() {
        echo "Mock kitty called with: $*"
    }
    chmod() {
        echo "Mock chmod called with: $*"
    }
    
    # Test GitHub PR checkout
    local result=$(checkout_pr "https://github.com/owner/repo/pull/123" 2>&1)
    if echo "$result" | grep -q "Mock kitty called" && echo "$result" | grep -q "clone_pr.sh"; then
        echo "✓ checkout_pr works for GitHub"
    else
        echo "✗ checkout_pr failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab MR checkout
    local result=$(checkout_pr "https://gitlab.example.com/owner/repo/-/merge_requests/456" 2>&1)
    if echo "$result" | grep -q "Mock kitty called" && echo "$result" | grep -q "clone_mr.sh"; then
        echo "✓ checkout_pr works for GitLab"
    else
        echo "✗ checkout_pr failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

test_route_checkout_pr() {
    # Mock exec to test routing logic
    exec() {
        echo "Routed to: $*"
    }
    
    # Test GitHub routing
    local result=$(route_checkout_pr "https://github.com/owner/repo/pull/123" 2>&1)
    if echo "$result" | grep -q "github-pr-checkout.sh"; then
        echo "✓ route_checkout_pr works for GitHub"
    else
        echo "✗ route_checkout_pr failed for GitHub: $result"
        return 1
    fi
    
    # Test GitLab routing
    local result=$(route_checkout_pr "https://gitlab.example.com/owner/repo/-/merge_requests/456" 2>&1)
    if echo "$result" | grep -q "gitlab-mr-checkout.sh"; then
        echo "✓ route_checkout_pr works for GitLab"
    else
        echo "✗ route_checkout_pr failed for GitLab: $result"
        return 1
    fi
    
    return 0
}

# Handle command line arguments
if [ "$1" = "--test" ]; then
    echo "Running tests for git-pr-checkout.sh..."
    failed=0
    
    test_checkout_pr || failed=1
    test_route_checkout_pr || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        exit 0
    else
        echo "Some tests failed!"
        exit 1
    fi
fi

# Main execution - use new checkout_pr function
checkout_pr "$1"
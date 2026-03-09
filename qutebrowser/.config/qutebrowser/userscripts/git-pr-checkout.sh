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
    local request_type
    if is_github "$url"; then
        pr_number=$(extract_github_pr_number "$url")
        local script_name="clone_pr.sh"
        local checkout_cmd="gh pr checkout $pr_number"
        request_type="pull request"
    else
        pr_number=$(extract_gitlab_mr_number "$url")
        local script_name="clone_mr.sh"
        local checkout_cmd="glab mr checkout $pr_number"
        request_type="merge request"
    fi

    if [ -z "$pr_number" ]; then
        notify-send -u critical "Git PR Checkout" "No $request_type number found in URL.\nUse <Ctrl-g>c for regular cloning."
        exit 1
    fi

    local review_dir=$(build_review_path "$host" "$org" "$repo" "$pr_number")

    # Create a script to run in terminal
    local temp_script=~/$script_name
    cat <<EOF > $temp_script
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

REVIEW_DIR="$review_dir"

# Check if already checked out
if [ -d "\$REVIEW_DIR" ]; then
    echo "$request_type already checked out at: \$REVIEW_DIR"
    cd "\$REVIEW_DIR"
    exec fish
fi

# Create parent directory
mkdir -p "\$(dirname "\$REVIEW_DIR")"
cd "\$(dirname "\$REVIEW_DIR")"
echo "Checking out $request_type: $pr_number into \$REVIEW_DIR..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$host" "$org" "$repo" "$pr_number"

# Check if clone was successful
if [ ! -d "$pr_number" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $pr_number
$checkout_cmd

exec fish
EOF

    chmod +x $temp_script
    term-aux -e bash -c "$temp_script"
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
    # Mock term-aux and chmod
    term-aux() {
        echo "Mock term-aux called with: $*"
    }
    chmod() {
        echo "Mock chmod called with: $*"
    }

    # Test GitHub PR checkout
    local result=$(checkout_pr "https://github.com/owner/repo/pull/123" 2>&1)
    if echo "$result" | grep -q "Mock term-aux called" && echo "$result" | grep -q "clone_pr.sh"; then
        echo "✓ checkout_pr works for GitHub"
    else
        echo "✗ checkout_pr failed for GitHub: $result"
        return 1
    fi

    # Test GitLab MR checkout
    local result=$(checkout_pr "https://gitlab.example.com/owner/repo/-/merge_requests/456" 2>&1)
    if echo "$result" | grep -q "Mock term-aux called" && echo "$result" | grep -q "clone_mr.sh"; then
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

# Main execution - delegate to platform-specific scripts
route_checkout_pr "$1"

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
    local workspace="$HOME/workspace/src/$host/$org"

    # Create a script to run in terminal
    local temp_script=~/clone_repo.sh
    cat <<EOF > $temp_script
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

WORKSPACE="$workspace"
REPO="$repo"

# Check if already cloned
if [ -d "\$WORKSPACE/\$REPO" ]; then
    echo "Repository already cloned at: \$WORKSPACE/\$REPO"
    cd "\$WORKSPACE/\$REPO"
    exec fish
fi

# Create workspace directory
mkdir -p "\$WORKSPACE"
cd "\$WORKSPACE"
echo "Cloning $repo into \$WORKSPACE..."

# Clone the repository
smart_clone "$host" "$org" "$repo" "$repo"

# Check if clone was successful and cd into repo
if [ -d "\$REPO" ]; then
    cd "\$REPO"
else
    echo "ERROR: Failed to clone repository"
fi

exec fish
EOF

    chmod +x $temp_script
    term-aux -e bash -c "$temp_script"
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
    # Mock term-aux and chmod to test function logic
    term-aux() {
        echo "Mock term-aux called with: $*"
    }
    chmod() {
        echo "Mock chmod called with: $*"
    }

    # Test GitHub clone
    local result=$(clone_repo "https://github.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "Mock term-aux called" && [ -f ~/clone_repo.sh ]; then
        echo "✓ clone_repo works for GitHub"
    else
        echo "✗ clone_repo failed for GitHub: $result"
        return 1
    fi

    # Test GitLab clone
    local result=$(clone_repo "https://gitlab.example.com/owner/repo" 2>&1)
    if echo "$result" | grep -q "Mock term-aux called"; then
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

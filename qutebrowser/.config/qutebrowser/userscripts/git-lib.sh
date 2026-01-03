#!/bin/bash

# Shared library for git userscripts

# Source the generic TOML library
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/toml-lib.sh"

# Detect if URL is GitHub or GitLab
is_github() {
    local url="$1"
    echo "$url" | grep -q "github.com"
}

# Extract host from URL
extract_host() {
    local url="$1"
    echo "$url" | sed -n 's/.*:\/\/\([^\/]*\)\/.*/\1/p'
}

# Extract organization from URL
extract_organization() {
    local url="$1"
    echo "$url" | sed -n 's/.*\/\/[^\/]*\/\([^\/]*\)\/.*/\1/p'
}

# Extract repository name from URL
extract_repository() {
    local url="$1"
    echo "$url" | sed -n 's/.*\/\/[^\/]*\/[^\/]*\/\([^\/]*\).*/\1/p'
}

# Extract path after repository from URL
extract_path() {
    local url="$1"
    echo "$url" | sed -n 's/.*\/\/[^\/]*\/[^\/]*\/[^\/]*\(\/.*\)/\1/p'
}

# Extract pull request number from GitHub URL
extract_github_pr_number() {
    local url="$1"
    echo "$url" | sed -n 's/.*pull\/\([0-9]*\).*/\1/p'
}

# Extract merge request number from GitLab URL
extract_gitlab_mr_number() {
    local url="$1"
    echo "$url" | sed -n 's/.*merge_requests\/\([0-9]*\).*/\1/p'
}

# Build SSH clone URL
build_ssh_url() {
    local host="$1"
    local org="$2"
    local repo="$3"
    local username="$4"  # Optional username override
    
    if [ -n "$username" ]; then
        echo "git@$host:$username/$repo.git"
    else
        echo "git@$host:$org/$repo.git"
    fi
}

# Build HTTPS clone URL
build_https_url() {
    local host="$1"
    local org="$2"
    local repo="$3"
    echo "https://$host/$org/$repo.git"
}

# Parse TOML config and extract method and username
get_config_values() {
    local host="$1"
    local org="$2" 
    local repo="$3"
    local config_file="${GIT_CONFIG_FILE:-$HOME/.config/qutebrowser/git.toml}"
    
    # Default values - start with empty method so we can detect when config is found
    local method=""
    local username=""
    
    if [ -f "$config_file" ]; then
        # Try repo-specific config first
        local repo_section="\"$host/$org/$repo\""
        if toml_has_section "$repo_section" "$config_file"; then
            method=$(toml_get_value "$repo_section" "method" "$config_file")
            username=$(toml_get_value "$repo_section" "username" "$config_file")
        fi
        
        # If not found or empty, try host-specific config
        if [ -z "$method" ]; then
            local host_section="\"$host\""
            if toml_has_section "$host_section" "$config_file"; then
                local host_method=$(toml_get_value "$host_section" "method" "$config_file")
                local host_username=$(toml_get_value "$host_section" "username" "$config_file")
                
                if [ -n "$host_method" ]; then
                    method="$host_method"
                    if [ -z "$username" ]; then
                        username="$host_username"
                    fi
                fi
            fi
        fi
        
        # If not found or empty, try global config
        if [ -z "$method" ]; then
            if toml_has_section "default" "$config_file"; then
                local default_method=$(toml_get_value "default" "method" "$config_file")
                if [ -n "$default_method" ]; then
                    method="$default_method"
                fi
            fi
        fi
        
    fi
    
    # Default to fallback if nothing found
    if [ -z "$method" ]; then
        method="fallback"
    fi
    
    echo "$method|$username"
}

# Get clone method from config (ssh|https|fallback) - for backward compatibility
get_clone_method() {
    local config_values=$(get_config_values "$1" "$2" "$3")
    echo "${config_values%%|*}"
}

# Get username from config
get_clone_username() {
    local config_values=$(get_config_values "$1" "$2" "$3")
    echo "${config_values##*|}"
}

# Try SSH clone with timeout, fallback to HTTPS if it fails
clone_with_fallback() {
    local host="$1"
    local org="$2"
    local repo="$3"
    local target_dir="$4"
    local username="$5"  # Optional username
    
    local ssh_url=$(build_ssh_url "$host" "$org" "$repo" "$username")
    local https_url=$(build_https_url "$host" "$org" "$repo")
    
    echo "Attempting SSH clone: $ssh_url"
    
    # Set SSH timeout and try SSH clone
    if timeout 10 git -c core.sshCommand="ssh -o ConnectTimeout=10 -o ServerAliveInterval=10 -o ServerAliveCountMax=1" clone "$ssh_url" "$target_dir" 2>/dev/null; then
        echo "SSH clone successful"
        return 0
    else
        echo "SSH clone failed, trying HTTPS: $https_url"
        # Clean up partial clone if it exists
        rm -rf "$target_dir" 2>/dev/null
        
        # Clone with HTTPS
        if git clone "$https_url" "$target_dir"; then
            echo "HTTPS clone successful"
            # Configure git to always use HTTPS for this host to avoid future SSH timeouts
            (cd "$target_dir" && git config url."https://$host/".insteadOf "git@$host:")
            echo "Configured git to use HTTPS for $host"
            return 0
        else
            echo "HTTPS clone failed"
            return 1
        fi
    fi
}

# Clone repository using configured method
smart_clone() {
    local host="$1"
    local org="$2"
    local repo="$3"
    local target_dir="$4"
    
    local config_values=$(get_config_values "$host" "$org" "$repo")
    local method="${config_values%%|*}"
    local username="${config_values##*|}"
    
    local ssh_url=$(build_ssh_url "$host" "$org" "$repo" "$username")
    local https_url=$(build_https_url "$host" "$org" "$repo")
    
    case "$method" in
        "ssh")
            echo "Using SSH (configured): $ssh_url"
            git clone "$ssh_url" "$target_dir"
            ;;
        "https")
            echo "Using HTTPS (configured): $https_url"
            git clone "$https_url" "$target_dir"
            ;;
        "fallback"|*)
            clone_with_fallback "$host" "$org" "$repo" "$target_dir" "$username"
            ;;
    esac
}

# Build workspace path
build_workspace_path() {
    local host="$1"
    local org="$2"
    echo "~/workspace/src/$host/$org"
}

# Test functions
test_is_github() {
    if is_github "https://github.com/owner/repo"; then
        echo "✓ is_github detects GitHub URL"
    else
        echo "✗ is_github failed to detect GitHub URL"
        return 1
    fi
    
    if ! is_github "https://gitlab.example.com/owner/repo"; then
        echo "✓ is_github correctly rejects GitLab URL"
    else
        echo "✗ is_github incorrectly detected GitLab URL as GitHub"
        return 1
    fi
    return 0
}

test_extract_host() {
    local host=$(extract_host "https://gitlab.example.com/owner/repo")
    if [ "$host" = "gitlab.example.com" ]; then
        echo "✓ extract_host works"
        return 0
    else
        echo "✗ extract_host failed, got: '$host'"
        return 1
    fi
}

test_extract_organization() {
    local org=$(extract_organization "https://github.com/testorg/testrepo")
    if [ "$org" = "testorg" ]; then
        echo "✓ extract_organization works"
        return 0
    else
        echo "✗ extract_organization failed, got: '$org'"
        return 1
    fi
}

test_extract_repository() {
    local repo=$(extract_repository "https://github.com/testorg/testrepo")
    if [ "$repo" = "testrepo" ]; then
        echo "✓ extract_repository works"
        return 0
    else
        echo "✗ extract_repository failed, got: '$repo'"
        return 1
    fi
}

test_extract_path() {
    local path=$(extract_path "https://github.com/owner/repo/blob/main/file.txt")
    if [ "$path" = "/blob/main/file.txt" ]; then
        echo "✓ extract_path works"
        return 0
    else
        echo "✗ extract_path failed, got: '$path'"
        return 1
    fi
}

test_extract_github_pr_number() {
    local pr=$(extract_github_pr_number "https://github.com/owner/repo/pull/123")
    if [ "$pr" = "123" ]; then
        echo "✓ extract_github_pr_number works"
        return 0
    else
        echo "✗ extract_github_pr_number failed, got: '$pr'"
        return 1
    fi
}

test_extract_gitlab_mr_number() {
    local mr=$(extract_gitlab_mr_number "https://gitlab.example.com/owner/repo/-/merge_requests/456")
    if [ "$mr" = "456" ]; then
        echo "✓ extract_gitlab_mr_number works"
        return 0
    else
        echo "✗ extract_gitlab_mr_number failed, got: '$mr'"
        return 1
    fi
}

test_build_ssh_url() {
    local ssh_url=$(build_ssh_url "github.com" "owner" "repo")
    if [ "$ssh_url" = "git@github.com:owner/repo.git" ]; then
        echo "✓ build_ssh_url works without username"
    else
        echo "✗ build_ssh_url failed without username, got: '$ssh_url'"
        return 1
    fi
    
    # Test with username override
    local ssh_url_with_user=$(build_ssh_url "gitlab.com" "owner" "repo" "customuser")
    if [ "$ssh_url_with_user" = "git@gitlab.com:customuser/repo.git" ]; then
        echo "✓ build_ssh_url works with username override"
        return 0
    else
        echo "✗ build_ssh_url failed with username, got: '$ssh_url_with_user'"
        return 1
    fi
}

test_build_https_url() {
    local https_url=$(build_https_url "gitlab.example.com" "owner" "repo")
    if [ "$https_url" = "https://gitlab.example.com/owner/repo.git" ]; then
        echo "✓ build_https_url works"
        return 0
    else
        echo "✗ build_https_url failed, got: '$https_url'"
        return 1
    fi
}

test_build_workspace_path() {
    local workspace=$(build_workspace_path "gitlab.example.com" "owner")
    if [ "$workspace" = "~/workspace/src/gitlab.example.com/owner" ]; then
        echo "✓ build_workspace_path works"
        return 0
    else
        echo "✗ build_workspace_path failed, got: '$workspace'"
        return 1
    fi
}

test_get_config_values_default() {
    local temp_config=$(mktemp)
    export GIT_CONFIG_FILE="$temp_config"
    
    cat > "$temp_config" << 'EOF'
[default]
method = "ssh"
EOF
    
    local config_values=$(get_config_values "unknown.com" "org" "repo")
    local method="${config_values%%|*}"
    local username="${config_values##*|}"
    
    if [ "$method" = "ssh" ] && [ -z "$username" ]; then
        echo "✓ get_config_values uses default config"
    else
        echo "✗ get_config_values default failed, method: '$method', username: '$username'"
        rm "$temp_config"
        return 1
    fi
    
    rm "$temp_config"
    unset GIT_CONFIG_FILE
    return 0
}

test_get_config_values_host() {
    local temp_config=$(mktemp)
    export GIT_CONFIG_FILE="$temp_config"
    
    cat > "$temp_config" << 'EOF'
[default]
method = "ssh"

["github.com"]
method = "https"
username = "hostuser"
EOF
    
    local config_values=$(get_config_values "github.com" "org" "repo")
    local method="${config_values%%|*}"
    local username="${config_values##*|}"
    
    if [ "$method" = "https" ] && [ "$username" = "hostuser" ]; then
        echo "✓ get_config_values uses host-specific config"
    else
        echo "✗ get_config_values host failed, method: '$method', username: '$username'"
        rm "$temp_config"
        return 1
    fi
    
    rm "$temp_config"
    unset GIT_CONFIG_FILE
    return 0
}

test_get_config_values_repo() {
    local temp_config=$(mktemp)
    export GIT_CONFIG_FILE="$temp_config"
    
    cat > "$temp_config" << 'EOF'
[default]
method = "ssh"

["github.com"]
method = "https"

["gitlab.example.com/org/special-repo"]
method = "fallback"
username = "repouser"
EOF
    
    local config_values=$(get_config_values "gitlab.example.com" "org" "special-repo")
    local method="${config_values%%|*}"
    local username="${config_values##*|}"
    
    if [ "$method" = "fallback" ] && [ "$username" = "repouser" ]; then
        echo "✓ get_config_values uses repo-specific config"
    else
        echo "✗ get_config_values repo failed, method: '$method', username: '$username'"
        rm "$temp_config"
        return 1
    fi
    
    rm "$temp_config"
    unset GIT_CONFIG_FILE
    return 0
}

test_get_config_values_no_config() {
    local temp_config="/tmp/nonexistent_config_file_$$"
    export GIT_CONFIG_FILE="$temp_config"
    
    local config_values=$(get_config_values "github.com" "org" "repo")
    local method="${config_values%%|*}"
    local username="${config_values##*|}"
    
    if [ "$method" = "fallback" ] && [ -z "$username" ]; then
        echo "✓ get_config_values defaults when no config file"
    else
        echo "✗ get_config_values no-file failed, method: '$method', username: '$username'"
        return 1
    fi
    
    unset GIT_CONFIG_FILE
    return 0
}

test_get_clone_method() {
    local temp_config=$(mktemp)
    export GIT_CONFIG_FILE="$temp_config"
    
    cat > "$temp_config" << 'EOF'
[default]
method = "ssh"

["github.com"]
method = "https"
EOF
    
    # Test backward compatibility function
    local method=$(get_clone_method "unknown.com" "org" "repo")
    if [ "$method" = "ssh" ]; then
        echo "✓ get_clone_method backward compatibility works"
    else
        echo "✗ get_clone_method backward compatibility failed, got: '$method'"
        rm "$temp_config"
        return 1
    fi
    
    rm "$temp_config"
    unset GIT_CONFIG_FILE
    return 0
}

test_smart_clone() {
    # Mock git to test function logic
    git() {
        echo "Mock git called with: $*"
        return 0
    }
    
    # Create a temporary TOML config file
    local temp_config=$(mktemp)
    export GIT_CONFIG_FILE="$temp_config"
    
    cat > "$temp_config" << 'EOF'
["github.com"]
method = "ssh"
EOF
    
    # Test configured SSH clone
    local result=$(smart_clone "github.com" "owner" "repo" "target" 2>&1)
    if echo "$result" | grep -q "Using SSH (configured)"; then
        echo "✓ smart_clone uses configured SSH"
    else
        echo "✗ smart_clone SSH config failed: $result"
        rm "$temp_config"
        return 1
    fi
    
    rm "$temp_config"
    unset GIT_CONFIG_FILE
    return 0
}

# Run all tests
run_tests() {
    echo "Running tests for git-lib.sh..."
    local failed=0
    
    test_is_github || failed=1
    test_extract_host || failed=1
    test_extract_organization || failed=1
    test_extract_repository || failed=1
    test_extract_path || failed=1
    test_extract_github_pr_number || failed=1
    test_extract_gitlab_mr_number || failed=1
    test_build_ssh_url || failed=1
    test_build_https_url || failed=1
    test_build_workspace_path || failed=1
    test_get_config_values_default || failed=1
    test_get_config_values_host || failed=1
    test_get_config_values_repo || failed=1
    test_get_config_values_no_config || failed=1
    test_get_clone_method || failed=1
    test_smart_clone || failed=1
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed!"
        return 0
    else
        echo "Some tests failed!"
        return 1
    fi
}

# Run tests if --test is passed and we're not being sourced
if [ "$1" = "--test" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_tests
    exit $?
fi
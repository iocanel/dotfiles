# Shellib Package for Home Manager

This package provides the `grab` tool from the shellib ecosystem for downloading and using shell libraries from GitHub repositories.

## Usage

After installation via Home Manager, the `grab` command will be available in your PATH.

### Basic Usage

```bash
# Download and source a library
source $(grab github.com/shellib/git as git)

# Use functions with namespace
git::extract_host "https://github.com/owner/repo"
git::clone "github.com" "owner" "repo" "/path/to/target"
```

### How grab works

- Downloads repositories to `~/.shellib/host/org/repo/version/`
- Looks for `library.sh` in the root or specified path
- Supports versioning with `@branch` or `@tag`
- Provides namespace aliasing with `as alias`
- Caches libraries locally for performance

### Examples

```bash
# Download latest from main branch
source $(grab github.com/shellib/git)

# Download specific version
source $(grab github.com/shellib/toml@v1.0.0)

# Use with namespace
source $(grab github.com/shellib/git as git)
git::extract_host "https://github.com/owner/repo"

# Download from subdirectory
source $(grab github.com/owner/repo/subdir)
```

## Directory Structure

```
~/.shellib/
├── github.com/
│   └── shellib/
│       ├── git/
│       │   └── master/
│       │       └── library.sh
│       └── toml/
│           └── master/
│               └── library.sh
```

## Integration with Qutebrowser Userscripts

The qutebrowser userscripts in this dotfiles repository have been updated to use grab:

```bash
# Load shellib dependencies
if [ ! -f "$HOME/bin/grab" ]; then
  mkdir -p $HOME/bin
  export PATH=$PATH:$HOME/bin
  curl -o $HOME/bin/grab -L https://github.com/shellib/grab/raw/master/grab.sh && chmod +x $HOME/bin/grab
fi

source $(grab github.com/shellib/git as git)
```

## License

MIT License - see the grab script for details.
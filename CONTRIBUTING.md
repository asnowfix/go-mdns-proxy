# Contributing to go-mdns-proxy

## Development

### Prerequisites

- Go 1.24.2 or later
- Windows environment for building (uses Windows-specific syscalls)

### Building

```bash
# Download dependencies
go mod tidy

# Build (Windows only)
go build -o mdns-proxy.exe .
```

### Testing

The application must be tested on Windows as it uses Windows-specific networking APIs.

## Release Process

### Creating a Release

1. **Tag the release**:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

2. **Automatic workflow trigger**:
   - The `on-tag-main.yml` workflow detects the tag push
   - It automatically triggers the `package-release.yml` workflow
   - The workflow builds the MSI installer: `MDNSProxy-<version>.msi`

3. **Review and publish**:
   - Go to [GitHub Releases](https://github.com/asnowfix/go-mdns-proxy/releases)
   - Find the draft release created by the workflow
   - Review the release notes
   - Publish the release

### Release Artifacts

The release will include:
- `MDNSProxy-<version>.msi` - Windows installer package

### MSI Package Details

The MSI installer:
- Installs `mdns-proxy.exe` to `C:\Program Files\MDNSProxy\`
- Creates a Windows service named "MDNSProxy"
- Configures the service to start automatically on boot
- Adds the installation directory to PATH
- Requires Windows SDK and WiX Toolset (installed automatically in CI)

## Workflow Files

### `.github/workflows/on-tag-main.yml`
Triggered when a version tag (v*.*.*) is pushed. Automatically triggers the packaging workflow.

### `.github/workflows/package-release.yml`
Builds the Windows MSI installer and creates a GitHub release.

## Version Numbering

Follow semantic versioning: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

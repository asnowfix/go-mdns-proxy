# Contributing to go-mdns-proxy <!-- omit in toc -->

## Table of Contents <!-- omit in toc -->

- [Development](#development)
  - [Prerequisites](#prerequisites)
  - [Building](#building)
  - [Testing](#testing)
- [Release Process](#release-process)
  - [Workflow Overview](#workflow-overview)
  - [Before First Release](#before-first-release)
  - [Minor Release (vM.m.0)](#minor-release-vmm0)
  - [Patch Release (vM.m.p)](#patch-release-vmmp)
  - [Post-Release](#post-release)
- [Workflow Files](#workflow-files)
  - [`.github/workflows/create-branch-on-minor-tag.yml`](#githubworkflowscreate-branch-on-minor-tagyml)
  - [`.github/workflows/auto-tag-patch.yml`](#githubworkflowsauto-tag-patchyml)
  - [`.github/workflows/on-tag-main.yml`](#githubworkflowson-tag-mainyml)
  - [`.github/workflows/package-release.yml`](#githubworkflowspackage-releaseyml)
- [Required GitHub Secrets](#required-github-secrets)
- [Version Numbering](#version-numbering)

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

### Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         MAIN BRANCH                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ git tag v0.1.0
                              │ git push origin v0.1.0
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  create-branch-on-minor-tag.yml (triggered by v*.*.0 tag)       │
│  ✓ Creates branch v0.1.x from tag v0.1.0                        │
│  ✓ Triggers package-release.yml                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  package-release.yml                                             │
│  ✓ Builds mdns-proxy.exe                                         │
│  ✓ Creates MDNSProxy-0.1.0.msi                                   │
│  ✓ Creates draft GitHub release                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    📦 Release v0.1.0 published


┌─────────────────────────────────────────────────────────────────┐
│                      MAINTENANCE BRANCH v0.1.x                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ PR merged (bugfix)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  auto-tag-patch.yml (triggered by PR merge to v*.*.x)           │
│  ✓ Calculates next patch version (v0.1.1)                       │
│  ✓ Creates signed tag v0.1.1                                    │
│  ✓ Triggers package-release.yml                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  package-release.yml                                             │
│  ✓ Builds mdns-proxy.exe                                         │
│  ✓ Creates MDNSProxy-0.1.1.msi                                   │
│  ✓ Creates draft GitHub release                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    📦 Release v0.1.1 published
```

### Before First Release

- [ ] Configure GitHub Secrets:
  - [ ] `GPG_PRIVATE_KEY` - GPG private key for signing tags
  - [ ] `GPG_PASSPHRASE` - Passphrase for the GPG key
- [ ] Verify workflows are enabled in repository settings
- [ ] Test build locally: `go build -o mdns-proxy.exe .`

### Minor Release (vM.m.0)

For new minor versions (e.g., v0.1.0, v0.2.0, v1.0.0):

1. **Tag the release from main**:
   ```bash
   git checkout main
   git tag v0.1.0
   git push origin v0.1.0
   ```

2. **Automatic workflow trigger**:
   - The `create-branch-on-minor-tag.yml` workflow detects the tag
   - Creates a maintenance branch `v0.1.x` from the tag
   - Triggers the `package-release.yml` workflow
   - Builds the MSI installer: `MDNSProxy-0.1.0.msi`

3. **Checklist**:
   - [ ] Ensure all changes are merged to `main`
   - [ ] Update version in documentation if needed
   - [ ] Create and push tag (see step 1)
   - [ ] Wait for workflows to complete (~10 minutes)
   - [ ] Check GitHub Actions for any failures
   - [ ] Verify branch `v0.1.x` was created
   - [ ] Go to [GitHub Releases](https://github.com/asnowfix/go-mdns-proxy/releases)
   - [ ] Find draft release `v0.1.0`
   - [ ] Review release notes
   - [ ] Download and test `MDNSProxy-0.1.0.msi`
   - [ ] Publish release

### Patch Release (vM.m.p)

For patch releases on existing minor versions (e.g., v0.1.1, v0.1.2):

1. **Create a PR to the maintenance branch**:
   ```bash
   git checkout v0.1.x
   git pull origin v0.1.x
   git checkout -b fix/my-bugfix
   # Make your changes
   git commit -m "Fix: description"
   git push origin fix/my-bugfix
   ```

2. **Merge the PR**:
   - Create a PR targeting the `v0.1.x` branch
   - Get it reviewed and approved
   - Merge the PR (do NOT delete branch yet)

3. **Automatic patch tagging**:
   - The `auto-tag-patch.yml` workflow detects the merged PR
   - Runs tests (`go build`, `go test`)
   - Automatically calculates the next patch version (e.g., v0.1.1)
   - Creates and pushes the signed tag
   - Triggers the `package-release.yml` workflow
   - Builds the MSI installer: `MDNSProxy-0.1.1.msi`

4. **Checklist**:
   - [ ] Create bugfix branch from maintenance branch (see step 1)
   - [ ] Make changes and commit
   - [ ] Push branch and create PR targeting `v0.1.x`
   - [ ] Get PR reviewed and approved
   - [ ] Merge PR
   - [ ] Wait for auto-tag workflow (~5 minutes)
   - [ ] Verify tag was created: `git fetch --tags && git tag -l "v0.1.*"`
   - [ ] Wait for package workflow (~10 minutes)
   - [ ] Check GitHub Actions for any failures
   - [ ] Go to [GitHub Releases](https://github.com/asnowfix/go-mdns-proxy/releases)
   - [ ] Find draft release (e.g., `v0.1.1`)
   - [ ] Review release notes
   - [ ] Download and test MSI
   - [ ] Publish release
   - [ ] Delete bugfix branch

### Post-Release

- [ ] Test MSI installation on clean Windows machine
- [ ] Verify service starts automatically
- [ ] Test mDNS bridging functionality
- [ ] Update documentation if needed
- [ ] Announce release (if applicable)

## Workflow Files

### `.github/workflows/create-branch-on-minor-tag.yml`
Triggered when a minor version tag (v*.*.0) is pushed. Creates a maintenance branch (v*.*.x) and triggers packaging.

### `.github/workflows/auto-tag-patch.yml`
Triggered when a PR is merged to a maintenance branch (v*.*.x). Automatically creates the next patch tag and triggers packaging.

### `.github/workflows/on-tag-main.yml`
Triggered when any version tag (v*.*.*) is pushed from main. Triggers the packaging workflow.

### `.github/workflows/package-release.yml`
Builds the Windows MSI installer and creates a GitHub release.

## Required GitHub Secrets

The following secrets must be configured in the repository settings for signed releases:

- `GPG_PRIVATE_KEY` - GPG private key for signing tags
- `GPG_PASSPHRASE` - Passphrase for the GPG key

To generate a GPG key:
```bash
gpg --full-generate-key
gpg --armor --export-secret-keys YOUR_KEY_ID
```

## Version Numbering

Follow semantic versioning: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (e.g., v1.0.0 → v2.0.0)
- **MINOR**: New features, backward compatible (e.g., v0.1.0 → v0.2.0)
- **PATCH**: Bug fixes, backward compatible (e.g., v0.1.0 → v0.1.1)

## Branch Strategy

- **`main`**: Active development, all new features
- **`vMAJOR.MINOR.x`**: Maintenance branches for patch releases
  - Created automatically when tagging `vMAJOR.MINOR.0`
  - Only receives bug fixes via PRs
  - Patch tags created automatically on PR merge
  - Example: `v0.1.x`, `v0.2.x`, `v1.0.x`

## Troubleshooting

### Workflow didn't trigger
- Check GitHub Actions tab for workflow runs
- Verify tag matches pattern: `v[0-9]+.[0-9]+.[0-9]+`
- Ensure workflows are enabled in repository settings
- Verify tag was pushed: `git ls-remote --tags origin`

### Branch not created
- Check if branch already exists: `git ls-remote --heads origin`
- Review workflow logs in GitHub Actions
- Ensure tag matches `v*.*.0` pattern

### Build failed
- Check workflow logs in GitHub Actions
- Verify `go.mod` and dependencies are correct
- Test build locally on Windows: `go build -o mdns-proxy.exe .`
- Ensure all tests pass: `go test ./...`

### MSI build fails
- Check Windows SDK installation in workflow logs
- Verify `wix.json` configuration
- Ensure go.mod has correct module name
- Review WiX Toolset installation step

### GPG signing failed
- Verify `GPG_PRIVATE_KEY` and `GPG_PASSPHRASE` secrets are set
- Check GPG key is valid and not expired
- Review GPG import step in workflow logs
- Ensure key has signing capabilities

### Release not created
- Check if draft release exists in GitHub Releases
- Verify workflow completed successfully
- Check workflow logs for errors in release step
- Ensure previous tag reference is correct

### Auto-tag didn't create patch version
- Verify PR was merged (not closed without merging)
- Check that PR target branch matches `v*.*.x` pattern
- Review auto-tag-patch workflow logs
- Ensure tests passed in the workflow

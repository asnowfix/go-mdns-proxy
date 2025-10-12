# WSL mDNS Proxy <!-- omit in toc -->

A Windows service that bridges mDNS (multicast DNS) traffic between the physical network interface and the WSL virtual network interface, enabling mDNS service discovery to work seamlessly in WSL environments.

## Table of Contents <!-- omit in toc -->

- [Problem](#problem)
- [Solution](#solution)
- [Installation](#installation)
  - [Download MSI Installer](#download-msi-installer)
  - [Install as Windows Service](#install-as-windows-service)
- [Usage](#usage)
  - [Manual Control](#manual-control)
- [Building from Source](#building-from-source)
- [Development \& Release Workflow](#development--release-workflow)
  - [Release Process](#release-process)
- [Testing](#testing)
  - [From WSL](#from-wsl)
  - [From Windows](#from-windows)
- [Technical Details](#technical-details)
- [License](#license)
- [References](#references)

## Problem

By default, WSL networking is isolated from the Windows host's physical network. This means:
- mDNS queries from WSL don't reach the physical network
- mDNS responses from the physical network don't reach WSL
- Service discovery (Avahi, Bonjour, etc.) doesn't work in WSL

## Solution

This bridge listens for mDNS multicast packets on both interfaces and forwards them bidirectionally, making WSL behave like a native Linux host on the physical network for mDNS purposes.

## Installation

### Download MSI Installer

Download the latest `MDNSProxy-<version>.msi` from the [Releases](https://github.com/asnowfix/go-mdns-proxy/releases) page.

### Install as Windows Service

Double-click the MSI installer. The service will be automatically installed and configured to start on boot.

## Usage

The service runs automatically on Windows startup. It will:
- Auto-detect the WSL interface (looks for "wsl" or "vethernet" in the name)
- Auto-detect the host interface (finds the interface with the default gateway route)
- Forward mDNS traffic bidirectionally between the two interfaces

### Manual Control

```powershell
# Start the service
Start-Service MDNSProxy

# Stop the service
Stop-Service MDNSProxy

# Check service status
Get-Service MDNSProxy
```

## Building from Source

```powershell
# Build executable
go build -o mdns-proxy.exe .

# Run manually (for testing)
.\mdns-proxy.exe
```

## Development & Release Workflow

### Release Process

**Minor Release (v0.1.0):**
1. Tag `v0.1.0` on `main` branch
2. Workflow creates `v0.1.x` maintenance branch
3. MSI package `MDNSProxy-0.1.0.msi` is built and released

**Patch Release (v0.1.1):**
1. Create PR targeting `v0.1.x` branch
2. Merge PR
3. Workflow auto-tags `v0.1.1`
4. MSI package `MDNSProxy-0.1.1.msi` is built and released

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed release instructions.

## Testing

### From WSL

```bash
# Install avahi-utils
sudo apt-get install avahi-utils

# Browse for services
avahi-browse -a

# Resolve a hostname
avahi-resolve -n hostname.local
```

### From Windows

```powershell
# Use dns-sd (part of Bonjour)
dns-sd -B _http._tcp
```

## Technical Details

- **Port**: UDP 5353
- **IPv4 Multicast**: 224.0.0.251
- **IPv6 Multicast**: ff02::fb (link-local)
- **Socket Options**: SO_REUSEADDR enabled for port sharing
- **Multicast Loopback**: Enabled for proper bridging

## License

[MPL-2.0](./LICENSE)

## References

- [Windows Service](https://docs.microsoft.com/en-us/windows/win32/services/services)
- [go-spew](https://github.com/davecgh/go-spew)
- [go-mdns](https://github.com/miekg/mdns)
- [go-msi](https://github.com/andrewdavies1989/go-msi)
- [WiX Toolset](https://wixtoolset.org/)
- [GitHub Actions](https://github.com/features/actions)
- [GitHub Packages](https://github.com/features/packages)
- [GitHub](https://github.com/features/packages)
- [WSL](https://github.com/microsoft/WSL/issues/5301)
- [Reroute mDNS query from WSL subnet to Windows host subnet](https://stackoverflow.com/questions/62108116/reroute-mdns-query-from-wsl-subnet-to-windows-host-subnet)
- [mDNS not working in WSL2 works ok in Windows host](https://www.reddit.com/r/bashonubuntuonwindows/comments/1e9rjid/mdns_not_working_in_wsl2_works_ok_in_windows_host/)
- [How to make Windows Subsystem for Linux use proxied connections](https://superuser.com/questions/1612914/how-to-make-windows-subsystem-for-linux-use-proxied-connections)

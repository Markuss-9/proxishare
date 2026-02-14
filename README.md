# ProxiShare

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Requirements

To build ProxiShare, you need:

- **Flutter SDK** (version 3.35.6 or later) - [Installation](https://flutter.dev/docs/get-started/install)
- **Node.js** (latest LTS or later) - for building the web UI - [Download](https://nodejs.org/)
- **Dart SDK** (included with Flutter)

### Windows

#### Additional Requirements

For building Windows installers, you also need:

- **Inno Setup** - for packaging the application as an installer
  - [Download Inno Setup](https://jrsoftware.org/isdl.php)
  - Or install via package manager: `choco install innosetup -y` (using Chocolatey)

#### Local Build Instructions

1. **Setup dependencies:**

   ```bash
   make install-webui    # Install Node.js dependencies
   make install-flutter  # Get Flutter dependencies
   ```

2. **Run tests** (optional):

   ```bash
   make test-webui       # Test web UI
   make test             # Test Flutter app
   ```

3. **Build the application:**

   ```bash
   make build-webui      # Build web UI assets
   make build-windows    # Build Windows desktop app and installer
   ```

4. **Find the installer:**
   The installer will be created at: `installer/ProxiShare-Setup-<version>.exe` (e.g., `ProxiShare-Setup-1.0.0.exe`)

   > **Note:** The installer output folder is separate from the build artifacts for cleaner distribution and packaging workflows.

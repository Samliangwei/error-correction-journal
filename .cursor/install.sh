#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Flutter SDK..."
if [ ! -d "/home/ubuntu/flutter" ]; then
  cd /home/ubuntu
  curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz | tar xJ
fi

# Add Flutter to PATH via symlink
sudo ln -sf /home/ubuntu/flutter/bin/flutter /usr/local/bin/flutter
sudo ln -sf /home/ubuntu/flutter/bin/dart /usr/local/bin/dart

echo "==> Configuring Flutter..."
flutter config --no-analytics
flutter precache --web

echo "==> Installing Python dependencies..."
if [ -f "/workspace/server/requirements.txt" ]; then
  cd /workspace/server
  pip3 install --user -r requirements.txt
fi

echo "==> Installing Flutter dependencies..."
if [ -f "/workspace/app/pubspec.yaml" ]; then
  cd /workspace/app
  flutter pub get
fi

echo "==> Setup complete!"

#!/bin/bash
# BMAD Update Script for groove.rb

echo "🔄 Updating BMAD..."

# Update git submodule
echo "📥 Pulling latest BMAD source..."
git submodule update --remote BMAD-METHOD

# Copy updated modules
echo "📋 Installing updated modules..."
cp -r BMAD-METHOD/src/modules/bmm/* bmad/bmm/
cp -r BMAD-METHOD/src/modules/bmb/* bmad/bmb/
cp -r BMAD-METHOD/src/modules/cis/* bmad/cis/

echo "✅ BMAD updated successfully!"
echo "📝 Version: $(cat BMAD-METHOD/package.json | grep version | cut -d'"' -f4)"

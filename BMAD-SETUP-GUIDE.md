# BMAD Setup Guide for groove.rb

## The Problem
You had **3 different BMAD installations** causing confusion:
1. **BMAD-METHOD/** - Source code (now git submodule ✅)
2. **bmad/** - Manual copy (removed ✅)
3. **.cursor/rules/bmad/** - Manual Cursor files (removed ✅)

## The Solution

### ✅ **What We Fixed**:
1. **Removed messy installations** - Cleaned up all manual copies
2. **Added BMAD as git submodule** - `BMAD-METHOD/` is now properly managed
3. **Switched to v6-alpha branch** - Latest version with proper workflows

### 🔧 **How to Install BMAD Properly**:

Since `npm` isn't available on your system, here's the manual approach:

#### **Option 1: Install npm (Recommended)**
```bash
# Install npm (if you have sudo access)
sudo apt-get update
sudo apt-get install npm

# Then install BMAD properly
cd BMAD-METHOD
npm install
node tools/cli/bmad-cli.js install
```

#### **Option 2: Manual Installation (Current)**
Since npm isn't available, we'll manually create the necessary files:

1. **Create bmad directory structure**:
```bash
mkdir -p bmad/{bmm,bmb,cis}
```

2. **Copy core modules from BMAD-METHOD**:
```bash
cp -r BMAD-METHOD/src/modules/bmm/* bmad/bmm/
cp -r BMAD-METHOD/src/modules/bmb/* bmad/bmb/
cp -r BMAD-METHOD/src/modules/cis/* bmad/cis/
```

3. **Create config.json**:
```bash
cat > bmad/config.json << 'EOF'
{
  "version": "6.0.0-alpha.0",
  "modules": ["bmm", "bmb", "cis"],
  "ides": ["cursor"]
}
EOF
```

### 🎯 **How Updates Work Now**:

#### **Easy Updates**:
```bash
# Update BMAD source
git submodule update --remote BMAD-METHOD

# Re-run manual installation (if using Option 2)
# Copy updated modules to bmad/
```

#### **Version Management**:
- **BMAD-METHOD/** - Source code (git submodule)
- **bmad/** - Your installed modules (auto-generated)
- **Updates** - Pull latest from git submodule

### 🚀 **Next Steps**:

1. **Choose installation method** (npm or manual)
2. **Run installation** to create `bmad/` directory
3. **Test BMAD agents** in Cursor chat
4. **Continue Epic 3 development**

### 📝 **Benefits of This Approach**:

✅ **Clean separation** - Source vs installed files  
✅ **Easy updates** - `git submodule update`  
✅ **No duplication** - Single source of truth  
✅ **Version control** - Track BMAD versions  
✅ **Easy maintenance** - Clear file organization  

**This is now the "BMAD way" - clean, maintainable, and updateable!** 🎯

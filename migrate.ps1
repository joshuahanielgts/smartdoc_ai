# LucidDrive AI - React + Vite Migration Script
# This script will migrate the project from Next.js to React + Vite

Write-Host "🚀 Starting LucidDrive AI Migration to React + Vite..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Backup
Write-Host "📦 Step 1: Creating backups..." -ForegroundColor Yellow
if (Test-Path "package.json") {
    Copy-Item "package.json" "package.json.backup" -Force
    Write-Host "✓ Backed up package.json" -ForegroundColor Green
}
if (Test-Path "tsconfig.json") {
    Copy-Item "tsconfig.json" "tsconfig.json.backup" -Force
    Write-Host "✓ Backed up tsconfig.json" -ForegroundColor Green
}

# Step 2: Update package.json
Write-Host ""
Write-Host "📝 Step 2: Updating package.json..." -ForegroundColor Yellow
if (Test-Path "package.json.new") {
    Copy-Item "package.json.new" "package.json" -Force
    Write-Host "✓ Updated package.json" -ForegroundColor Green
} else {
    Write-Host "✗ package.json.new not found!" -ForegroundColor Red
    exit 1
}

# Step 3: Update tsconfig.json
Write-Host ""
Write-Host "⚙️ Step 3: Updating TypeScript configuration..." -ForegroundColor Yellow
if (Test-Path "tsconfig.json.new") {
    Copy-Item "tsconfig.json.new" "tsconfig.json" -Force
    Write-Host "✓ Updated tsconfig.json" -ForegroundColor Green
} else {
    Write-Host "✗ tsconfig.json.new not found!" -ForegroundColor Red
    exit 1
}

# Step 4: Clean install
Write-Host ""
Write-Host "🧹 Step 4: Cleaning old dependencies..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force "node_modules"
    Write-Host "✓ Removed node_modules" -ForegroundColor Green
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force "package-lock.json"
    Write-Host "✓ Removed package-lock.json" -ForegroundColor Green
}
if (Test-Path ".next") {
    Remove-Item -Recurse -Force ".next"
    Write-Host "✓ Removed .next directory" -ForegroundColor Green
}

# Step 5: Install new dependencies
Write-Host ""
Write-Host "📦 Step 5: Installing new dependencies..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Cyan
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

# Step 6: Verification
Write-Host ""
Write-Host "✅ Step 6: Verifying installation..." -ForegroundColor Yellow
$requiredFiles = @(
    "vite.config.ts",
    "index.html",
    "src/main.tsx",
    "src/App.tsx",
    "src/index.css",
    "src/pages/Dashboard.tsx"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "✗ $file is missing!" -ForegroundColor Red
        $allFilesExist = $false
    }
}

# Final message
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
if ($allFilesExist) {
    Write-Host "✨ Migration completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Review MIGRATION.md for details"
    Write-Host "2. Run: npm run dev"
    Write-Host "3. Open: http://localhost:9002"
    Write-Host ""
    Write-Host "⚠️  Important:" -ForegroundColor Yellow
    Write-Host "AI features need backend implementation."
    Write-Host "See MIGRATION.md for details."
} else {
    Write-Host "⚠️  Migration completed with warnings!" -ForegroundColor Yellow
    Write-Host "Some files are missing. Please check manually."
}
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 Ready to start? Run: npm run dev" -ForegroundColor Green

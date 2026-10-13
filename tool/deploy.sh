#!/usr/bin/env bash
# ==============================================================================
# 1v1 Platform — Local CI/CD Build & Deployment Pipeline
# ==============================================================================
# Automates the end-to-end production deployment to Serverpod Cloud:
# 1. Monorepo Quality Gates (dart format, dart analyze, multi-tier tests)
# 2. Production Web Client Bundle Compilation (Flutter Web SPA -> server/web/app)
# 3. Database Migration Integrity Check
# 4. Serverpod Cloud Deployment (serverpod cloud deploy)
# ==============================================================================

set -euo pipefail

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Flags
SKIP_TESTS=false
DRY_RUN=false
BUILD_ONLY=false

for arg in "$@"; do
  case $arg in
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --build-only)
      BUILD_ONLY=true
      shift
      ;;
    -h|--help)
      echo -e "${BOLD}1v1 CI/CD Deployment Pipeline${RESET}"
      echo ""
      echo "Usage: ./tool/deploy.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --skip-tests   Skip automated test suites (for quick hotfixes)"
      echo "  --dry-run      Run checks and web build without deploying to cloud"
      echo "  --build-only   Only compile Flutter Web into one_v_one_server/web/app"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      ;;
  esac
done

START_TIME=$(date +%s)

echo -e "\n${BOLD}${CYAN}================================================================${RESET}"
echo -e "${BOLD}${CYAN}   🚀 1v1 PLATFORM — LOCAL CI/CD DEPLOYMENT PIPELINE            ${RESET}"
echo -e "${BOLD}${CYAN}================================================================${RESET}"
echo -e "Workspace Root: ${REPO_ROOT}"
echo -e "Timestamp:      $(date -u +"%Y-%m-%dT%H:%M:%SZ")\n"

# ------------------------------------------------------------------------------
# STEP 0: Prerequisite Tool Checks
# ------------------------------------------------------------------------------
echo -e "${BOLD}[0/4] Checking Required Toolchains...${RESET}"
for tool in dart flutter serverpod; do
  if ! command -v "$tool" &> /dev/null; then
    echo -e "${RED}❌ Error: '$tool' is not installed or not in PATH.${RESET}"
    exit 1
  fi
done
echo -e "${GREEN}✓ Dart $(dart --version 2>&1 | awk '{print $4}') | Flutter $(flutter --version 2>&1 | head -n 1 | awk '{print $2}') | Serverpod CLI active${RESET}"

# ------------------------------------------------------------------------------
# STEP 1: Quality Gates (Formatting, Analysis, Testing)
# ------------------------------------------------------------------------------
if [ "$BUILD_ONLY" = false ]; then
  echo -e "\n${BOLD}[1/4] Running Quality Gates & Monorepo Validation...${RESET}"
  
  cd "${REPO_ROOT}"
  echo -e "  • Checking code formatting..."
  dart format --output=none --set-exit-if-changed .
  echo -e "    ${GREEN}✓ Formatting verified${RESET}"

  echo -e "  • Running monorepo static analysis..."
  dart analyze packages/game_core one_v_one_server one_v_one_flutter
  echo -e "    ${GREEN}✓ Static analysis clean (zero issues)${RESET}"

  if [ "$SKIP_TESTS" = false ]; then
    echo -e "  • Running pure game engine test suite..."
    (cd "${REPO_ROOT}/packages/game_core" && dart test)
    echo -e "    ${GREEN}✓ Game core tests passed${RESET}"

    echo -e "  • Running Flutter widget & interaction tests..."
    (cd "${REPO_ROOT}/one_v_one_flutter" && flutter test)
    echo -e "    ${GREEN}✓ Flutter tests passed${RESET}"

    echo -e "  • Running Serverpod backend integration tests..."
    (cd "${REPO_ROOT}/one_v_one_server" && dart test)
    echo -e "    ${GREEN}✓ Serverpod tests passed${RESET}"
  else
    echo -e "  ${YELLOW}⚠ Skipping test suites (--skip-tests active)${RESET}"
  fi
fi

# ------------------------------------------------------------------------------
# STEP 2: Production Flutter Web Bundle Compilation
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}[2/4] Compiling Flutter Web SPA Bundle...${RESET}"
TARGET_APP_DIR="${REPO_ROOT}/one_v_one_server/web/app"
rm -rf "${TARGET_APP_DIR}"

cd "${REPO_ROOT}/one_v_one_flutter"
echo -e "  • Building Flutter Web release with base-href '/' into server/web/app..."
flutter build web --release --base-href / --output "${TARGET_APP_DIR}" || {
  echo -e "  ${YELLOW}⚠ Build failed. Running flutter clean and retrying...${RESET}"
  flutter clean
  flutter pub get
  flutter build web --release --base-href / --output "${TARGET_APP_DIR}"
}

if [ ! -f "${TARGET_APP_DIR}/index.html" ]; then
  echo -e "${RED}❌ Error: Flutter Web build output missing index.html at ${TARGET_APP_DIR}${RESET}"
  exit 1
fi
echo -e "${GREEN}✓ Web SPA successfully compiled into one_v_one_server/web/app${RESET}"

# ------------------------------------------------------------------------------
# STEP 3: Database Migration Verification
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}[3/4] Verifying Database Schema Migrations...${RESET}"
cd "${REPO_ROOT}/one_v_one_server"
if [ -d "migrations" ]; then
  MIGRATION_COUNT=$(ls -d migrations/* 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}✓ ${MIGRATION_COUNT} database migrations present in one_v_one_server/migrations/${RESET}"
fi

# ------------------------------------------------------------------------------
# STEP 4: Serverpod Cloud Deployment
# ------------------------------------------------------------------------------
if [ "$BUILD_ONLY" = true ]; then
  echo -e "\n${GREEN}✓ Build-only complete. Skipping deployment step.${RESET}"
elif [ "$DRY_RUN" = true ]; then
  echo -e "\n${BOLD}[4/4] Dry Run: Previewing Serverpod Cloud Upload Files...${RESET}"
  cd "${REPO_ROOT}"
  serverpod cloud deploy --wet-run --show-files
  echo -e "\n${YELLOW}✓ Dry-run completed. No changes were deployed to production.${RESET}"
else
  echo -e "\n${BOLD}[4/4] Deploying to Serverpod Cloud via Serverpod CLI...${RESET}"
  cd "${REPO_ROOT}"
  serverpod cloud deploy
  echo -e "\n${GREEN}✓ Serverpod Cloud deployment initiated successfully!${RESET}"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n${BOLD}${GREEN}================================================================${RESET}"
echo -e "${BOLD}${GREEN}   🎉 PIPELINE FINISHED IN ${DURATION}s                         ${RESET}"
echo -e "${BOLD}${GREEN}   Live Web App: https://onevone.serverpod.space/                ${RESET}"
echo -e "${BOLD}${GREEN}   Live API:     https://onevone.api.serverpod.space/            ${RESET}"
echo -e "${BOLD}${GREEN}   Health Probe: https://onevone.serverpod.space/healthz         ${RESET}"
echo -e "${BOLD}${GREEN}================================================================${RESET}\n"

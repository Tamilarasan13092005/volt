# VolunteerSync — Complete Deployment Guide
> **Beginner-friendly guide** to deploy VolunteerSync to GitHub Pages with full CI/CD automation.

---

## 📁 Complete Project Structure (After This Setup)

```
volunteersync-app/
│
├── .github/
│   └── workflows/
│       ├── flutter.yml          ← Original workflow (kept)
│       └── flutter-ci.yml       ← ✨ NEW: Complete CI/CD pipeline
│
├── integration_test/            ← ✨ NEW: Integration tests (real device)
│   ├── app_test.dart            ← Full E2E test suite (27 tests)
│   └── helpers/
│       └── test_helpers.dart    ← Shared test utilities
│
├── lib/
│   ├── core/                    → Theme, constants, utilities
│   ├── features/
│   │   ├── auth/screens/
│   │   │   ├── login_screen.dart     ← ✨ MODIFIED: Added automation Keys
│   │   │   ├── register_screen.dart  ← ✨ MODIFIED: Added automation Keys
│   │   │   ├── landing_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── dashboard/           → Dashboard feature
│   │   ├── volunteers/          → Volunteers feature
│   │   ├── events/              → Events feature
│   │   ├── attendance/          → Attendance feature
│   │   ├── reports/             → Reports feature
│   │   ├── ai_chat/             → AI Chat feature
│   │   └── settings/            → Settings feature
│   ├── models/                  → Data models
│   ├── providers/               → State management (Provider)
│   ├── routes/                  → GoRouter config
│   ├── widgets/
│   │   └── common/
│   │       ├── main_shell.dart  ← ✨ MODIFIED: Added nav Keys
│   │       └── common_widgets.dart
│   └── main.dart
│
├── test/
│   ├── unit/
│   │   └── auth_provider_test.dart  ← ✨ NEW: Unit tests
│   ├── widget/
│   │   ├── login_widget_test.dart   ← ✨ NEW: Login widget tests
│   │   └── register_widget_test.dart← ✨ NEW: Register widget tests
│   └── widget_test.dart             ← ✨ REPLACED: Clean entry point
│
├── web/
│   ├── index.html               ← ✨ UPDATED: SEO + splash + SPA fix
│   ├── 404.html                 ← ✨ NEW: SPA routing fix for GitHub Pages
│   ├── manifest.json            ← ✨ UPDATED: Proper PWA config
│   ├── favicon.png
│   └── icons/
│
├── .gitignore                   ← ✨ FIXED: Removed duplicates
├── analysis_options.yaml        ← ✨ UPDATED: Production lint rules
├── pubspec.yaml                 ← ✨ UPDATED: Added test dependencies
└── DEPLOYMENT_GUIDE.md          ← ✨ NEW: This file
```

---

## 🚀 Step-by-Step: Deploy to GitHub Pages

### Step 1: Create a GitHub Repository

1. Go to [github.com](https://github.com) and sign in
2. Click the **+** button (top right) → **New repository**
3. Set:
   - **Repository name**: `volunteersync-app`
   - **Visibility**: Public *(GitHub Pages is free for public repos)*
   - **Do NOT** check "Initialize with README" (you already have code)
4. Click **Create repository**

---

### Step 2: Push Your Code to GitHub

Open a terminal in your project folder (`c:\Projects\volunteersync-app`) and run these commands **one by one**:

```bash
# Check if Git already knows about your project
git status
```
> **What this does**: Shows which files are new/changed/deleted.

```bash
# Stage all files (prepare them to be saved)
git add .
```
> **What `git add .` does**: Adds ALL files in the current folder to the "staging area" (think of it as a shopping cart before checkout).

```bash
# Save a snapshot of your code with a message
git commit -m "feat: initial production-ready VolunteerSync setup"
```
> **What `git commit` does**: Permanently saves your staged files with a description of what changed.

```bash
# Connect your local project to your GitHub repository
# IMPORTANT: Replace YOUR_GITHUB_USERNAME with your actual GitHub username
git remote add origin https://github.com/Tamilarasan13092005/volunteersync-app.git
```
> **What `git remote add` does**: Tells Git "when I say 'origin', I mean this GitHub URL".

```bash
# Rename your current branch to 'main' (GitHub's default)
git branch -M main
```
> **What this does**: Renames the branch. GitHub Pages expects a `main` branch.

```bash
# Upload (push) your code to GitHub
git push -u origin main
```
> **What `git push` does**: Sends your committed code to GitHub.
> The `-u origin main` means "from now on, this branch automatically pushes to GitHub".

---

### Step 3: Enable GitHub Pages in Repository Settings

1. Go to your repository on GitHub: `https://github.com/Tamilarasan13092005/volunteersync-app`
2. Click **Settings** tab
3. In the left sidebar, click **Pages**
4. Under **Source**, select: **Deploy from a branch**
5. Under **Branch**, select: `gh-pages` → `/ (root)`
6. Click **Save**

> ⚠️ **Note**: The `gh-pages` branch is created automatically by the CI/CD pipeline on first push. If you don't see it yet, wait for the GitHub Actions workflow to run first (Step 4).

---

### Step 4: Watch the CI/CD Pipeline Run

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. You'll see **"VolunteerSync — CI/CD Pipeline"** running
4. Click on it to see each step in real-time
5. A green ✅ means success, red ❌ means failure

**The pipeline takes approximately 4-7 minutes** for the first run.

---

### Step 5: Visit Your Live App

After the pipeline succeeds (green ✅), your app is live at:

```
https://Tamilarasan13092005.github.io/volunteersync-app/
```

> ⏱️ **Wait 1-3 minutes** after the pipeline finishes before visiting the URL.
> GitHub Pages needs time to propagate the new files.

---

## 🔄 How Automatic Deployment Works

After the initial setup, **every time you push code**, this happens automatically:

```
You type:  git push origin main
                    ↓
         GitHub receives your code
                    ↓
     GitHub Actions triggers flutter-ci.yml
                    ↓
    ┌─────────────────────────────────────┐
    │        JOB 1: Build & Test          │
    │  1. flutter pub get                 │
    │  2. flutter analyze                 │
    │  3. flutter test (unit + widget)    │
    │  4. flutter build web --release     │
    │  5. Verify build output             │
    └────────────────┬────────────────────┘
                     │ (only if all steps pass)
                     ↓
    ┌─────────────────────────────────────┐
    │      JOB 2: Deploy to GitHub Pages  │
    │  1. Build web again (clean server)  │
    │  2. Push build/web → gh-pages branch│
    └────────────────┬────────────────────┘
                     ↓
    Your live site updates automatically!
    https://Tamilarasan13092005.github.io/volunteersync-app/
```

---

## 🧪 Running Tests Locally

### Run all unit tests (fastest — no device needed):
```bash
flutter test test/unit/
```

### Run all widget tests (no device needed):
```bash
flutter test test/widget/
```

### Run all tests together:
```bash
flutter test test/
```

### Run integration tests (needs a device or emulator):
```bash
# First, start an emulator or connect a device, then:
flutter test integration_test/app_test.dart
```

### Demo login credentials (for integration tests):
- **Email**: `alex@volunteersync.io`
- **Password**: `password123`

---

## 🏗️ Build Commands

### Build for web (production):
```bash
flutter build web --release --base-href /volunteersync-app/
```

### Serve the build locally to preview:
```bash
# Install dhttpd if you don't have it
dart pub global activate dhttpd

# Serve the build
cd build/web
dhttpd
# Open http://localhost:8080
```

### Check for code issues:
```bash
flutter analyze --no-fatal-infos
```

---

## 🔑 Automation Keys Reference

These Keys are added to widgets so automation tests can find them:

| Key String | Widget | Screen |
|-----------|--------|--------|
| `login_email_field` | Email TextFormField | Login |
| `login_password_field` | Password TextFormField | Login |
| `login_password_toggle` | Show/hide password button | Login |
| `login_submit_button` | Sign In button | Login |
| `forgot_password_link` | Forgot Password link | Login |
| `signup_link` | Sign up free → link | Login |
| `register_name_field` | Full Name TextFormField | Register |
| `register_org_field` | Organization TextFormField | Register |
| `register_email_field` | Work Email TextFormField | Register |
| `register_password_field` | Password TextFormField | Register |
| `register_password_toggle` | Show/hide password button | Register |
| `register_terms_checkbox` | Terms agreement checkbox | Register |
| `register_submit_button` | Create Account button | Register |
| `signin_link` | Sign in link | Register |
| `nav_dashboard` | Dashboard nav item | Main Shell |
| `nav_volunteers` | Volunteers nav item | Main Shell |
| `nav_events` | Events nav item | Main Shell |
| `nav_attendance` | Attendance nav item | Main Shell |
| `nav_reports` | Reports nav item | Main Shell |
| `nav_ai_chat` | AI Assistant nav item | Main Shell |
| `nav_settings` | Settings nav item | Main Shell |

---

## 🛠️ Common Errors & Solutions

### ❌ Error: "gh-pages branch not found" in GitHub Pages settings
**Cause**: The CI/CD pipeline hasn't run yet.
**Fix**: Push any change to `main` and wait for the pipeline to complete. The `gh-pages` branch is created automatically.

---

### ❌ Error: White screen on GitHub Pages
**Cause**: The `--base-href` flag wasn't set correctly.
**Fix**: Make sure the build command is:
```bash
flutter build web --release --base-href /volunteersync-app/
```
The `/volunteersync-app/` must match your **exact** repository name.

---

### ❌ Error: 404 when refreshing /dashboard
**Cause**: GitHub Pages tries to find a `dashboard/index.html` file which doesn't exist.
**Fix**: The `web/404.html` file we created handles this. Make sure it's in your `web/` folder and was included in the build.

---

### ❌ Error: "flutter analyze" fails in CI
**Cause**: Code has errors that weren't caught locally.
**Fix**: Run `flutter analyze` locally first:
```bash
flutter analyze --no-fatal-infos
```
Fix all reported errors before pushing.

---

### ❌ Error: "flutter pub get" fails in CI
**Cause**: A package version conflict or network issue.
**Fix**: Run locally:
```bash
flutter pub get
flutter pub upgrade
```
Commit the updated `pubspec.lock` file.

---

### ❌ Error: GitHub Actions shows "Permission denied" on gh-pages push
**Cause**: The workflow doesn't have write permissions.
**Fix**: The `flutter-ci.yml` file already includes:
```yaml
permissions:
  contents: write
```
If the error persists, go to Repository → Settings → Actions → General → Workflow permissions → set to "Read and write permissions".

---

### ❌ Error: "integration_test" package not found
**Cause**: You haven't run `flutter pub get` after updating `pubspec.yaml`.
**Fix**:
```bash
flutter pub get
```

---

## 📋 Beginner Deployment Checklist

Before deploying, verify each item:

- [ ] GitHub repository created and is **Public**
- [ ] Code pushed to `main` branch (`git push -u origin main`)
- [ ] GitHub Actions tab shows the workflow running
- [ ] Both jobs show green ✅ checkmarks
- [ ] GitHub Pages enabled: Settings → Pages → gh-pages branch
- [ ] Visited `https://Tamilarasan13092005.github.io/volunteersync-app/`
- [ ] App loads without white screen
- [ ] Page refresh on `/dashboard` works (no 404)
- [ ] Can log in with demo credentials

### For future deploys:
- [ ] Made code changes
- [ ] `git add .`
- [ ] `git commit -m "description of changes"`
- [ ] `git push origin main`
- [ ] ⏱️ Wait 5-7 minutes for CI/CD to complete
- [ ] Verify changes are live

---

## 🔒 Security Notes

1. **Supabase anon key**: The key in `main.dart` is a public anon key by design. It cannot be used to bypass Row Level Security (RLS) policies. This is safe for production.

2. **GitHub Secrets**: No secrets are stored in the workflow file. The `GITHUB_TOKEN` is automatically provided by GitHub.

3. **Row Level Security**: Ensure your Supabase database has RLS enabled on all tables.

---

*Generated by VolunteerSync DevOps Setup — June 2026*

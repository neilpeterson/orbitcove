---
description: Clean up project by removing unnecessary code and updating documentation
allowed-tools: Glob, Grep, Read, Edit, Write, Bash(git:*), Bash(swift:*), Bash(xcodebuild:*), Bash(swiftlint:*), Bash(ls:*), Bash(find:*), Task
---

# Project Scrub Command

Performs comprehensive iOS project cleanup: removes unnecessary code, simplifies where possible, and ensures all documentation is current.

## Workflow:

### 1. **Pre-Scrub Assessment**
   - Read `docs/status.md` to understand current project state
   - Create a checklist of areas to review
   - Ask user if there are specific areas of concern

### 2. **Code Cleanup**

   **A. Find Unused Code:**
   - Run SwiftLint to identify issues: `swiftlint`
   - Look for:
     - Commented-out code blocks
     - Unused imports (import statements for unused frameworks)
     - Unused private properties/functions
     - Dead code paths (unreachable code after return/throw)
     - TODO/FIXME comments that need action or removal
     - Empty protocol conformances
     - Unused @Published properties in ViewModels

   **B. SwiftUI-Specific Cleanup:**
   - Remove unused @State/@Binding properties
   - Check for Views that could use computed properties instead of state
   - Look for unnecessary .onAppear/.onChange handlers
   - Find Views without #Preview blocks
   - Check for hardcoded strings that should be in constants
   - Look for inline styles that should use Theme system
   - Verify @Environment usage is consistent

   **C. Simplification Opportunities:**
   - Look for overly complex Views (should be broken into components)
   - Check for repeated View code that could be extracted
   - Find magic numbers/strings that should be constants
   - Identify ViewModels with too many responsibilities
   - Look for force unwraps (!) that should be handled safely
   - Check for deeply nested closures that could be flattened

   **D. File Organization:**
   - Check for empty directories
   - Look for duplicate or redundant files
   - Verify file placement matches folder structure
   - Check for temporary or backup files (.bak, .tmp, .DS_Store, etc.)
   - Ensure Views are in Views/, ViewModels in ViewModels/, etc.
   - Look for files not included in Xcode project

### 3. **Xcode Project & Configuration**

   **Review:**
   - `*.xcodeproj/project.pbxproj` - Check for orphaned file references
   - Build settings - Ensure Debug/Release configs are correct
   - Info.plist - Verify required keys are present
   - Entitlements - Check for unused capabilities
   - `.gitignore` - Ensure Xcode artifacts are ignored properly

   **Actions:**
   - Remove unused build phases
   - Clean up scheme configurations
   - Remove duplicate file references
   - Verify bundle identifiers are correct
   - Check deployment target is appropriate

### 4. **Asset Cleanup**

   **Review Assets.xcassets:**
   - Look for unused image assets (images not referenced in code)
   - Check for missing required app icons
   - Verify color sets match Theme.swift definitions
   - Look for duplicate assets with different names
   - Check that all assets have proper @2x/@3x variants

   **Actions:**
   - Remove unused assets
   - Update asset catalog organization
   - Verify LaunchScreen assets are current

### 5. **Documentation Review**

   **A. README.md:**
   - Verify build instructions work
   - Check feature list matches implementation
   - Ensure screenshots are current (if any)
   - Verify links are not broken
   - Update roadmap/status if needed
   - Check minimum iOS version is documented

   **B. docs/status.md:**
   - Update "Current Focus" section
   - Move completed "In Progress" items to "Completed"
   - Add any new tasks to backlog
   - Update "Recent Changes" with latest work
   - Remove stale entries
   - Verify milestone completion status

   **C. Feature Documentation:**
   - Verify API examples are correct
   - Check that documented Views/ViewModels exist
   - Ensure architecture diagrams are current
   - Update any changed type signatures
   - Verify navigation flows match implementation

   **D. Project Instructions (.claude/CLAUDE.md):**
   - Verify workflow rules are still relevant
   - Check architecture matches current structure
   - Update tech stack if dependencies changed
   - Review build commands for accuracy
   - Update feature priorities if changed
   - Verify project structure diagram is current

### 6. **Model & Data Cleanup**

   **Review:**
   - Check LocalModels.swift for unused model types
   - Verify all model properties are used in Views
   - Look for model duplication or overlap
   - Check Codable conformances are correct
   - Verify mock data in MockData.swift matches models

   **Actions:**
   - Remove unused model properties
   - Consolidate similar models if possible
   - Update MockData to reflect current model state
   - Ensure all enums have proper CaseIterable/Identifiable conformance

### 7. **Dependencies**

   **Review:**
   - Check Package.swift (if using SPM)
   - Look for unused framework imports
   - Verify minimum deployment targets
   - Check for outdated dependencies

   **Actions:**
   - Remove unused packages
   - Update outdated dependencies
   - Verify all dependencies are necessary

### 8. **Build & Test Verification**

   **Build Check:**
   - Clean build folder: `xcodebuild clean`
   - Full build: `xcodebuild -scheme OrbitCoveApp -destination 'platform=iOS Simulator,name=iPhone 15' build`
   - Check for warnings and address them
   - Run SwiftLint: `swiftlint`

   **Tests (if present):**
   - Run full test suite
   - Look for obsolete tests
   - Ensure test names are descriptive
   - Check for flaky tests

### 9. **Repository Hygiene**

   **Check for:**
   - Uncommitted changes: `git status`
   - Untracked files that should be committed or gitignored
   - Large files that shouldn't be in repo (binaries, etc.)
   - Sensitive data (API keys, credentials, certificates)
   - Xcode user-specific files in repo
   - .DS_Store files

   **Common files that should be gitignored:**
   - `*.xcuserstate`
   - `xcuserdata/`
   - `DerivedData/`
   - `.DS_Store`
   - `*.ipa`
   - `*.dSYM`

### 10. **Create Summary Report**

   **Document all changes made:**
   - What was removed and why
   - What was simplified
   - Documentation updates made
   - Any issues found but not fixed (and why)
   - Recommendations for future cleanup
   - Warnings that should be addressed

### 11. **Update Status**

   - Update `docs/status.md` with scrub completion
   - Add entry to "Recent Changes"
   - Note any technical debt identified

### 12. **Commit Changes**

   - Stage all changes
   - Create detailed commit message explaining cleanup
   - Suggest whether changes should be in one commit or split
   - Ask user if they want to create PR or push directly

## Important Notes:

- **Be Conservative**: Only remove code you're certain is unused
- **Preserve History**: Don't remove comments that explain "why" decisions were made
- **Test After Changes**: Build after any code modifications
- **Ask Before Big Changes**: If unsure about removing something, ask the user
- **Document Everything**: Keep track of what was removed for the summary
- **SwiftUI Previews**: Ensure #Preview blocks still work after changes

## Tools to Use:

- `git status` - Check for untracked files
- `swiftlint` - Check for code style issues
- `xcodebuild` - Verify project builds
- Task tool with Explore agent - For comprehensive code exploration
- Grep tool - Search for patterns (TODO, FIXME, unused imports, etc.)
- Glob tool - Find files by pattern
- Read tool - Review documentation files

## Common Grep Patterns:

```bash
# Find TODOs and FIXMEs
Grep: pattern="TODO|FIXME" glob="*.swift"

# Find force unwraps
Grep: pattern="[^?]!" glob="*.swift"

# Find print statements (debug code)
Grep: pattern="print\\(" glob="*.swift"

# Find unused imports
Grep: pattern="^import " glob="*.swift"

# Find hardcoded colors
Grep: pattern="Color\\." glob="*.swift"

# Find empty closures
Grep: pattern="\\{ \\}" glob="*.swift"
```

## Success Criteria:

- ✅ Project builds without errors
- ✅ Project builds without warnings (or warnings documented)
- ✅ SwiftLint passes (or violations documented)
- ✅ All documentation is current
- ✅ No unnecessary files remain
- ✅ Assets are all used and organized
- ✅ Dependencies are minimal
- ✅ Code is as simple as possible
- ✅ Status.md accurately reflects project state
- ✅ All Views have working #Preview blocks

## Example Usage:

```bash
/scrub
```

The command will systematically go through all areas and report findings.

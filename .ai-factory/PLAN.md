# Implementation Plan: Role Selection Persistence

Branch: main
Created: 2026-04-10

## Summary
Fix role selection (Driver/Client) to only show on first login, not every app launch.

## Problem
Current: LoadWidget always navigates to ViborWidget when `loginComplete == true`
Expected: Show role selection only on first auth, then remember choice

## Settings
- Testing: yes
- Logging: standard

## Tasks

### Phase 1: App State
- [x] Task 1: Add `roleSelected` field to FFAppState (lib/app_state.dart)
  - Persisted bool, default false
  - Secure storage key: 'ff_roleSelected'

### Phase 2: Navigation Logic
- [x] Task 2: Update LoadWidget navigation (lib/login/load/load_widget.dart) [depends on 1]
  - roleSelected=true + driver=true → MainDriverWidget
  - roleSelected=true + driver=false → MainUserWidget
  - roleSelected=false → ViborWidget

- [x] Task 3: Set roleSelected=true in ViborWidget (lib/login/vibor/vibor_widget.dart) [depends on 1]
  - Set flag when user picks role

### Phase 3: Testing
- [x] Task 4: Write unit tests (test/role_selection_test.dart) [depends on 1,2,3]
  - Test persistence
  - Test navigation logic

## Files to Modify
1. `lib/app_state.dart` - add roleSelected field
2. `lib/login/load/load_widget.dart` - update navigation logic
3. `lib/login/vibor/vibor_widget.dart` - set roleSelected on choice
4. `test/role_selection_test.dart` - new test file

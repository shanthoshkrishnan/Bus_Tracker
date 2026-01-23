# Contributing to LO BUS

Thank you for your interest in contributing to the LO BUS project! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and constructive in all interactions
- Provide helpful feedback
- Focus on the code, not the person
- Ask questions if you're unsure about something

## How to Contribute

### 1. Fork & Clone

```bash
git clone https://github.com/yourusername/bus_tracker.git
cd bus_tracker
```

### 2. Create a Feature Branch

```bash
git checkout -b feature/AmazingFeature
```

Use descriptive branch names:
- `feature/new-feature-name` for new features
- `bugfix/issue-description` for bug fixes
- `docs/update-readme` for documentation changes

### 3. Make Your Changes

- Follow Dart style guide: https://dart.dev/guides/language/effective-dart
- Add comments for complex logic
- Keep commits atomic and focused
- Test your changes locally

### 4. Format & Lint

```bash
# Format code
flutter format .

# Run static analysis
flutter analyze

# Run tests
flutter test
```

### 5. Commit & Push

```bash
# Commit with descriptive message
git commit -m "Add feature: description of changes"

# Push to your fork
git push origin feature/AmazingFeature
```

### 6. Create Pull Request

- Go to https://github.com/yourusername/bus_tracker
- Click "New Pull Request"
- Provide clear title and description
- Reference related issues (e.g., "Fixes #123")

## Commit Message Guidelines

Use clear, descriptive commit messages:

```
[Type] Brief description

Detailed explanation of what and why.

- Point 1
- Point 2
```

Types:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Test additions/updates
- `style:` Code formatting
- `perf:` Performance improvements

## Pull Request Requirements

- ✅ Code follows style guidelines
- ✅ Comments added for complex logic
- ✅ Tests pass locally
- ✅ No new warnings
- ✅ Documentation updated (if needed)
- ✅ Commit messages are clear

## Testing

Before submitting a PR, run tests:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Specific file
flutter test test/services/firebase_service_test.dart
```

## Reporting Bugs

Create an issue with:

1. **Title:** Clear description of the bug
2. **Steps to Reproduce:**
   - Step 1
   - Step 2
   - Step 3

3. **Expected Behavior:** What should happen
4. **Actual Behavior:** What actually happens
5. **Screenshots:** If applicable
6. **Environment:**
   - Flutter version (`flutter --version`)
   - Device/Emulator
   - OS version

## Feature Requests

Create an issue with:

1. **Title:** Feature description
2. **Use Case:** Why this feature is needed
3. **Proposed Solution:** How it should work
4. **Alternatives:** Other possible approaches
5. **Additional Context:** Any relevant information

## Coding Standards

### Dart Style

```dart
// Good: Clear, descriptive names
Future<List<Bus>> getAllActiveBuses() async {
  try {
    final buses = await _firestore
        .collection('buses')
        .where('status', isEqualTo: 'active')
        .get();
    
    return buses.docs
        .map((doc) => Bus.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('❌ Error fetching buses: $e');
    rethrow;
  }
}

// Avoid: Unclear names, poor error handling
Future<List> getData() async {
  var data = await _firestore.collection('buses').get();
  return data.docs.map((d) => Bus.fromFirestore(d)).toList();
}
```

### Comments

```dart
// DO: Explain WHY, not WHAT
/// Updates the bus location every 10 seconds to minimize battery usage
/// while maintaining acceptable tracking accuracy.
Future<void> updateBusLocation() async {
  // ...
}

// AVOID: Obvious comments
/// Increments the counter by 1
counter++; // Add 1 to counter
```

### Error Handling

```dart
// DO: Specific error handling
try {
  await _firestore.collection('buses').doc(busId).delete();
  print('✅ Bus deleted successfully');
} catch (e) {
  if (e is FirebaseException) {
    print('❌ Firebase error: ${e.message}');
  } else {
    print('❌ Unexpected error: $e');
  }
  rethrow;
}

// AVOID: Generic error handling
try {
  // ...
} catch (e) {
  print('Error: $e');
}
```

## Documentation

- Update `README.md` for setup changes
- Update `README_FRONTEND.md` for UI changes
- Update `README_BACKEND.md` for backend changes
- Add inline code comments for complex logic
- Keep docs in sync with code

## Questions?

- Open an issue with tag `question:`
- Check existing issues for answers
- Ask in pull request discussions

## Review Process

1. **Automated Checks:** Tests and linting run automatically
2. **Code Review:** Maintainers review for quality and consistency
3. **Feedback:** Suggestions for improvement
4. **Approval:** PR is approved and merged

## Recognition

Contributors will be added to:
- CONTRIBUTORS.md (coming soon)
- GitHub contributors page

---

Thank you for contributing! Your efforts help make LO BUS better! 🚌

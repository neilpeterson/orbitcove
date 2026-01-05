# Contributing to OrbitCove

Thank you for your interest in contributing to OrbitCove! This document provides guidelines for contributing to the project.

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone. We expect all contributors to:
- Be respectful and considerate
- Welcome newcomers
- Focus on what is best for the community
- Show empathy towards others

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Detailed steps to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: iOS version, device model, app version
- **Screenshots**: If applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- **Clear Description**: What you want to add or change
- **Use Case**: Why this enhancement would be useful
- **Alternatives**: Any alternative solutions you've considered
- **Implementation Ideas**: If you have technical suggestions

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/neilpeterson/orbitcove.git
   cd orbitcove
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the coding style guidelines
   - Write clear, concise commit messages
   - Add tests if applicable
   - Update documentation as needed

4. **Test Your Changes**
   - Build and test on iOS devices/simulator
   - Ensure no existing functionality is broken
   - Verify accessibility features work

5. **Submit Pull Request**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes

## Development Setup

### Prerequisites
- Xcode 15.0 or later
- macOS 13.0 or later
- iOS 15.0+ device or simulator

### Getting Started
1. Clone the repository
2. Open `OrbitCove` folder in Xcode
3. Select target device
4. Build and run (⌘+R)

## Coding Guidelines

### Swift Style Guide

Follow these Swift conventions:

1. **Naming**
   - Use descriptive names
   - PascalCase for types
   - camelCase for variables and functions
   - Uppercase for constants

2. **Code Organization**
   - Group related code with // MARK:
   - Keep files focused and single-purpose
   - Use extensions for protocol conformance

3. **SwiftUI Best Practices**
   - Extract complex views into components
   - Use @State, @Binding, @ObservedObject appropriately
   - Keep view bodies clean and readable

4. **Comments**
   - Write self-documenting code
   - Add comments for complex logic
   - Use documentation comments for public APIs

### Privacy Guidelines

When contributing, always consider privacy:

- Don't add analytics or tracking
- Minimize data collection
- Implement secure data storage
- Use encryption for sensitive data
- Follow Apple's privacy guidelines

## Project Structure

```
OrbitCove/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── Components/      # Reusable UI components
├── Services/        # Business logic and services
└── Assets.xcassets/ # Images and assets
```

## Testing

- Write unit tests for business logic
- Test on multiple iOS versions
- Test on different device sizes
- Verify accessibility features
- Test privacy features

## Documentation

- Update README.md for major changes
- Add inline documentation for complex code
- Update FEATURES.md for new features
- Keep PRIVACY.md current

## Review Process

1. **Automated Checks**: CI/CD runs automatically
2. **Code Review**: Maintainers review code
3. **Testing**: Verify functionality
4. **Approval**: Maintainer approval required
5. **Merge**: Changes merged to main branch

## Questions?

- Check existing documentation
- Review closed issues
- Open a new issue for questions

## Recognition

Contributors will be recognized in the project! Thank you for helping make OrbitCove better.

---

**Happy Contributing!** 🚀

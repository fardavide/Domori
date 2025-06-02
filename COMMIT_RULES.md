# Commit Message Rules

## Format
All commit messages must follow this format:
```
<emoji> <type>: <description>

[optional body]

[optional footer]
```

## Required Emoji Categories
Every commit message must start with one of these emojis:

- 🐛 **fix**: Bug fixes
- ✨ **feat**: New features
- 📝 **docs**: Documentation updates
- 🎨 **style**: Code style/formatting changes (no logic changes)
- ♻️ **refactor**: Code refactoring (no new features or bug fixes)
- ⚡ **perf**: Performance improvements
- 🧪 **test**: Adding or updating tests
- 🔧 **config**: Configuration changes
- 🚀 **release**: Version releases
- 🔥 **remove**: Removing code or files

## Examples
```
🐛 fix: resolve crash when loading empty data
✨ feat: add dark mode support
📝 docs: update README with installation instructions
🎨 style: format code according to style guide
♻️ refactor: extract common validation logic
⚡ perf: optimize image loading performance
🧪 test: add unit tests for user authentication
🔧 config: update Xcode project settings
🚀 release: bump version to 1.2.0
🔥 remove: delete deprecated API endpoints
```

## Description Guidelines
- Use imperative mood ("add feature" not "added feature")
- Keep the first line under 50 characters
- Capitalize the first letter after the emoji and type
- Don't end with a period
- Be specific and descriptive 
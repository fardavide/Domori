# Project Rules - Domori

## 📋 Reference Documentation Index

### Core Guidelines
- **Testing**: TESTING_STRATEGY.md
- **Screenshots**: SCREENSHOT_REQUIREMENTS.md  
- **Code Style**: CODE_STYLE.md
- **UI Guidelines**: UI_GUIDELINES.md
- **Development**: DEVELOPMENT_PRACTICES.md
- **Commits**: COMMIT_RULES.md
- **Changelog**: CHANGELOG.md

---

## 🔄 Automatic File Checking Rules

**CRITICAL**: When making changes to any part of the project, you MUST automatically check and follow the relevant documentation WITHOUT being prompted. This ensures consistency and quality.

### When Changing Tests → Check TESTING_STRATEGY.md
- Follow test naming conventions and structure
- Use European addresses with Euro currency in test data
- Ensure iPhone 16 Pro simulator compatibility
- Validate mandatory fields (price, size, bedrooms, bathrooms)
- Maintain performance targets (~171s for iPhone tests)

### When Updating UI → Check UI_GUIDELINES.md
- Follow tag spacing guidelines (3px between tags)
- Use consistent component patterns and visual hierarchy
- Maintain tag color system based on PropertyRating
- Apply proper padding and corner radius specifications
- Follow responsive design principles

### When Adding Features → Check DEVELOPMENT_PRACTICES.md
- Follow feature implementation workflow
- Ensure cross-platform compatibility
- Add appropriate unit and integration tests
- Update documentation if needed
- Consider migration requirements

### When Modifying Screenshots → Check SCREENSHOT_REQUIREMENTS.md
- Use iPhone 16 Pro device (6.3" display)
- Include European properties with Euro currency
- Fill ALL mandatory fields (never allow €0, 0 sqm, etc.)
- Follow the 5-screenshot flow requirements
- Validate App Store readiness

### When Writing Code → Check CODE_STYLE.md
- Follow Swift naming conventions (UiModel not UIModel)
- Maintain consistent code structure and documentation
- Use proper error handling and type safety
- Follow architectural patterns

### When Making Commits → Check COMMIT_RULES.md
- Use conventional commit format with emoji
- Write clear, descriptive commit messages
- Group related changes appropriately
- Include version bumps when needed

### When Releasing → Check CHANGELOG.md
- Add user-facing changes only
- Use App Store-friendly language
- Focus on user benefits and improvements
- Follow the update guide format

---

## 🎯 Quality Assurance Checklist

Before completing any task, verify:
- [ ] Relevant documentation was checked and followed
- [ ] Changes align with established patterns and guidelines
- [ ] Tests cover new functionality (if applicable)
- [ ] Cross-platform compatibility considered
- [ ] Documentation updated if needed
- [ ] User experience remains consistent

---

## 📝 Documentation Maintenance

### Keep Documentation Current
- Update guidelines when patterns change
- Ensure examples reflect current codebase
- Remove outdated information promptly
- Cross-reference related documentation

### Structure Guidelines
- Keep technical details while staying concise
- Use actionable language and clear examples
- Organize information hierarchically
- Provide copy-pasteable commands and code snippets

## Development Practices
Development: DEVELOPMENT_PRACTICES.md

## UI Guidelines
UI: UI_GUIDELINES.md

## Code Style
CodeStyle: CODE_STYLE.md

## Testing Strategy
Testing: TESTING_STRATEGY.md

## App Store Submission
AppStore: APP_STORE_SUBMISSION_GUIDE.md

## Screenshots
Screenshots: SCREENSHOT_REQUIREMENTS.md

## Documentation
README: README.md 
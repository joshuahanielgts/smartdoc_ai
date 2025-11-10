# Contributing to LucidDrive AI

First off, thank you for considering contributing to LucidDrive AI! It's people like you that make LucidDrive AI such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inspiring community for all. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs** if possible
- **Include your environment details** (OS, browser, Node.js version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## Development Setup

1. **Clone your fork**

   ```bash
   git clone https://github.com/your-username/lucid-drive.ai.git
   cd lucid-drive.ai
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Set up environment variables**

   ```bash
   cp .env.example .env
   # Add your Google AI API key
   ```

4. **Run the development server**
   ```bash
   npm run dev
   ```

## Style Guidelines

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Examples:

```
feat: Add voice assistant warning feature
fix: Correct DRI calculation in monitoring hook
docs: Update README with deployment instructions
style: Format code with Prettier
refactor: Simplify alert handling logic
test: Add tests for safety tips generation
chore: Update dependencies
```

### TypeScript Style Guide

- Use TypeScript for all new files
- Define proper types and interfaces
- Avoid using `any` type
- Use meaningful variable and function names
- Add comments for complex logic
- Follow the existing code structure

### React/Next.js Guidelines

- Use functional components with hooks
- Use React Server Components where possible
- Keep components small and focused
- Use proper TypeScript types for props
- Follow the established file structure

### CSS/Tailwind Guidelines

- Use Tailwind utility classes
- Follow the existing design system
- Use CSS variables for theme colors
- Ensure responsive design
- Test in both light and dark modes

## Project Structure

```
src/
├── ai/               # AI flows and Genkit configuration
├── app/              # Next.js app router pages
├── components/       # React components
│   ├── dashboard/    # Dashboard-specific components
│   └── ui/          # Reusable UI components (shadcn/ui)
├── hooks/           # Custom React hooks
└── lib/             # Utility functions and types
```

## Testing

Currently, the project uses manual testing. Automated tests are welcome contributions!

## Additional Notes

### Issue and Pull Request Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `question` - Further information is requested

## Recognition

Contributors will be recognized in:

- The project README
- Release notes for their contributions
- The project's contributors page

## Questions?

Feel free to open an issue with your question or contact the maintainers directly.

---

Thank you for contributing to LucidDrive AI! 🚗💨

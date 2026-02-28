# AGENTS.md - Developer Guide

## Overview

This is a React 19 + TypeScript + Vite webui project using Tailwind CSS v4, Zustand for state management, and Vitest for testing.

---

## Build, Lint, and Test Commands

### Development
```bash
npm run dev          # Start development server
npm run preview      # Preview production build
```

### Building
```bash
npm run build        # Type-check and build for production
```

### Linting & Formatting
```bash
npm run lint         # Run ESLint on entire project
npm run pretty       # Format code with Prettier (writes in place)
```

### Testing
```bash
npm run test         # Run all tests in watch mode
npm run test -- --run           # Run all tests once (no watch)
npm run test -- tests/pages/Homepage.test.tsx  # Run single test file
npm run test -- -t "test name"   # Run tests matching a pattern
npm run test -- --coverage       # Run tests with coverage report
```

---

## Project Structure

```
src/
├── components/      # React components
│   └── ui/          # shadcn/ui base components
├── hooks/          # Custom React hooks
├── lib/            # Utilities (utils.ts has cn() helper)
├── pages/          # Page-level components
├── client.ts       # API client (LocalServer)
├── store.ts        # Zustand store
├── router.tsx      # React Router setup
└── main.tsx        # App entry point

tests/
├── setup.ts        # Vitest setup (mocks, cleanup)
├── test-utils.tsx  # Testing utilities
└── pages/         # Component tests
```

---

## Code Style Guidelines

### Imports & Path Aliases
- Use the `@/` alias for imports from `src/`
- Example: `import Button from '@/components/ui/button';`
- Order imports: external libs → internal modules → relative paths
- Use `type` keyword for type-only imports: `import { type ClassValue } from 'clsx'`

### TypeScript
- **Strict mode is enabled** in tsconfig.app.json
- Use explicit return types for utility functions when helpful
- Prefer `interface` for public/state types, `type` for unions/utility types
- Use `type` imports for types: `import { type VariantProps } from 'class-variance-authority'`

### Naming Conventions
- **Components**: PascalCase (e.g., `FileGrid.tsx`, `Button.tsx`)
- **Hooks**: camelCase starting with `use` (e.g., `useServerStatus.ts`)
- **Utilities**: camelCase (e.g., `utils.ts`)
- **Store**: `useXxxStore` for Zustand stores (e.g., `useMediaStore`)
- **Files**: kebab-case for non-component files (e.g., `client.ts`, `router.tsx`)

### React & Components
- Use React 19 features (no explicit `React` import needed for JSX)
- Prefer small, focused components for readability and maintainability
- Extract logic into custom hooks when component code grows complex
- Use `function` declarations for components, not arrow functions
- Use `data-slot` attribute for polymorphic components (see button.tsx)
- Destructure props with defaults for optional values
- Use `class-variance-authority` (cva) for component variants

### Styling with Tailwind
- Use `cn()` utility from `@/lib/utils` to merge Tailwind classes
- Pattern: `cn(buttonVariants({ variant, size }), className)`
- Use Tailwind CSS v4 syntax (no arbitrary values without brackets)
- Use `clsx` for conditional class strings

### State Management (Zustand)
- Use `create<T>()` with explicit type annotation
- Define state interface as `type XxxState = { ... }`
- Use functional updates: `set((state) => ({ count: state.count + 1 }))`
- Revoke object URLs when cleaning up file data

### Error Handling
- Use `try/catch` with async/await for API calls
- Return meaningful error messages to users via UI
- Use `console.error` sparingly for debugging (prefer proper error boundaries)

### Testing Patterns
- Use `@testing-library/react` for component testing with `vitest` globals (`describe`, `it`, `expect`, `vi`)
- Mock Zustand stores: `vi.spyOn(store, 'useXxxStore').mockReturnValue(...)`
- Use `fireEvent` for user interactions, `act()` for async state updates
- Use `vi.fn()` for mock functions, `vi.clearAllMocks()` in `afterEach`

### Key Dependencies
- **UI**: React 19, Tailwind CSS v4, Radix UI primitives, Lucide icons
- **State**: Zustand | **HTTP**: Axios | **Testing**: Vitest, @testing-library/react, jsdom
- **Build**: Vite 7, TypeScript 5.9

---

## Common Patterns

### Component (shadcn-style)
```tsx
import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
import { componentVariants } from './component-variants';

function Component({
  className,
  variant,
  asChild = false,
  ...props
}: React.ComponentProps<'div'> &
  VariantProps<typeof componentVariants> & {
    asChild?: boolean;
  }) {
  const Comp = asChild ? Slot : 'div';
  return <Comp className={cn(componentVariants({ variant, className }))} {...props} />;
}

export { Component };
```

### Adding a New Store
```tsx
import { create } from 'zustand';

type XxxState = {
  value: string;
  setValue: (v: string) => void;
};

export const useXxxStore = create<XxxState>((set) => ({
  value: '',
  setValue: (value) => set({ value }),
}));
```

### Adding a Test
```tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import MyComponent from '@/components/MyComponent';

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });
});
```

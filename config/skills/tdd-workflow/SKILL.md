---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
origin: ECC
disable-model-invocation: true
user-invocable: false
---

# Test-Driven Development Workflow

This skill ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Tests BEFORE Code
ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements
- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

### 3. Test Types

#### Unit Tests
- Individual functions and utilities
- Component logic
- Pure functions
- Helpers and utilities

#### Integration Tests
- API endpoints
- Database operations
- Service interactions
- External API calls

#### E2E Tests (Playwright)
- Critical user flows
- Complete workflows
- Browser automation
- UI interactions

## TDD Workflow Steps

### Step 1: Write User Journeys
```
As a [role], I want to [action], so that [benefit]

Example:
As a user, I want to search for items by keyword,
so that I can find relevant results without exact matches.
```

### Step 2: Generate Test Cases
For each user journey, create comprehensive test cases:

```typescript
describe('Item Search', () => {
  it('returns relevant items for query', async () => {
    // Test implementation
  })

  it('handles empty query gracefully', async () => {
    // Test edge case
  })

  it('falls back to substring search when primary index unavailable', async () => {
    // Test fallback behavior
  })

  it('sorts results by relevance score', async () => {
    // Test sorting logic
  })
})
```

### Step 3: Run Tests (They Should Fail)
```bash
npm test
# Tests should fail - we haven't implemented yet
```

### Step 4: Implement Code
Write minimal code to make tests pass:

```typescript
// Implementation guided by tests
export async function searchItems(query: string) {
  // Implementation here
}
```

### Step 5: Run Tests Again
```bash
npm test
# Tests should now pass
```

### Step 6: Refactor
Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Optimize performance
- Enhance readability

### Step 7: Verify Coverage
```bash
npm run test:coverage
# Verify 80%+ coverage achieved
```

## Testing Patterns

### Unit Test Pattern (Jest/Vitest)
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)

    fireEvent.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### API Integration Test Pattern
```typescript
import { NextRequest } from 'next/server'
import { GET } from './route'

describe('GET /api/items', () => {
  it('returns items successfully', async () => {
    const request = new NextRequest('http://localhost/api/items')
    const response = await GET(request)
    const data = await response.json()

    expect(response.status).toBe(200)
    expect(data.success).toBe(true)
    expect(Array.isArray(data.data)).toBe(true)
  })

  it('validates query parameters', async () => {
    const request = new NextRequest('http://localhost/api/items?limit=invalid')
    const response = await GET(request)

    expect(response.status).toBe(400)
  })

  it('handles database errors gracefully', async () => {
    // Mock database failure
    const request = new NextRequest('http://localhost/api/items')
    // Test error handling
  })
})
```

### E2E Test Pattern (Playwright)
```typescript
import { test, expect } from '@playwright/test'

test('user can search and filter items', async ({ page }) => {
  await page.goto('/items')

  await expect(page.locator('h1')).toContainText('Items')

  await page.fill('input[placeholder="Search items"]', 'typescript')

  await page.waitForTimeout(600)

  const results = page.locator('[data-testid="item-card"]')
  await expect(results).toHaveCount(5, { timeout: 5000 })

  await page.click('button:has-text("Active")')
  await expect(results).toHaveCount(3)
})

test('user can create a new item', async ({ page }) => {
  await page.goto('/dashboard')

  await page.fill('input[name="name"]', 'Test Item')
  await page.fill('textarea[name="description"]', 'Test description')

  await page.click('button[type="submit"]')

  await expect(page.locator('text=Item created successfully')).toBeVisible()
})
```

## Test File Organization

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   └── Button.test.tsx
│   └── ItemCard/
│       ├── ItemCard.tsx
│       └── ItemCard.test.tsx
├── app/
│   └── api/
│       └── items/
│           ├── route.ts
│           └── route.test.ts
└── e2e/
    ├── items.spec.ts
    └── auth.spec.ts
```

## Mocking External Services

### Database Mock
```typescript
jest.mock('@/lib/db', () => ({
  db: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() => Promise.resolve({
          data: [{ id: 1, name: 'Test Item' }],
          error: null
        }))
      }))
    }))
  }
}))
```

### Cache Mock
```typescript
jest.mock('@/lib/cache', () => ({
  searchByVector: jest.fn(() => Promise.resolve([
    { slug: 'test-item', similarity_score: 0.95 }
  ])),
  checkHealth: jest.fn(() => Promise.resolve({ connected: true }))
}))
```

## Test Coverage Verification

```bash
npm run test:coverage
```

```json
{
  "jest": {
    "coverageThresholds": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

## Common Testing Mistakes to Avoid

### ❌ WRONG: Testing Implementation Details
```typescript
expect(component.state.count).toBe(5)
```

### ✅ CORRECT: Test User-Visible Behavior
```typescript
expect(screen.getByText('Count: 5')).toBeInTheDocument()
```

### ❌ WRONG: Brittle Selectors
```typescript
await page.click('.css-class-xyz')
```

### ✅ CORRECT: Semantic Selectors
```typescript
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

### ❌ WRONG: No Test Isolation
```typescript
test('creates item', () => { /* ... */ })
test('updates same item', () => { /* depends on previous test */ })
```

### ✅ CORRECT: Independent Tests
```typescript
test('creates item', () => {
  const item = createTestItem()
  // Test logic
})

test('updates item', () => {
  const item = createTestItem()
  // Update logic
})
```

## Continuous Testing

```bash
npm test -- --watch
```

```yaml
# GitHub Actions
- name: Run Tests
  run: npm test -- --coverage
- name: Upload Coverage
  uses: codecov/codecov-action@v3
```

## Best Practices

1. **Write Tests First** — Always TDD
2. **One Assert Per Test** — Focus on single behavior
3. **Descriptive Test Names** — Explain what's tested
4. **Arrange-Act-Assert** — Clear test structure
5. **Mock External Dependencies** — Isolate unit tests
6. **Test Edge Cases** — Null, undefined, empty, large
7. **Test Error Paths** — Not just happy paths
8. **Keep Tests Fast** — Unit tests < 50ms each
9. **Clean Up After Tests** — No side effects
10. **Review Coverage Reports** — Identify gaps

## Success Metrics

- 80%+ code coverage achieved
- All tests passing (green)
- No skipped or disabled tests
- Fast test execution (< 30s for unit tests)
- E2E tests cover critical user flows

---

**Remember**: Tests are not optional. They are the safety net that enables confident refactoring, rapid development, and production reliability.

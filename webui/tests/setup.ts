import '@testing-library/jest-dom'; // adds custom matchers like toBeInTheDocument
import { afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';

// Clean up DOM after each test
afterEach(() => {
  cleanup();
});

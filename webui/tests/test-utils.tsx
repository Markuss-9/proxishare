import React from 'react';
import { render } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
// import { useMediaStore } from '@/store';

export function renderWithProviders(
  ui: React.ReactElement,
  { route = '/' } = {}
) {
  window.history.pushState({}, 'Test page', route);

  return render(<MemoryRouter initialEntries={[route]}>{ui}</MemoryRouter>);
}

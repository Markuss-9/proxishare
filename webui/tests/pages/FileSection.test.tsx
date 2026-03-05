import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import FileSection from '@/components/FileSection';
import type { FileEnriched, FileId } from '@/store';

describe('FileSection', () => {
  const mockOnRemoveFiles = vi.fn();
  const mockOnPreview = vi.fn();

  const createMockFile = (name: string): FileEnriched => ({
    file: new File(['test'], name, { type: 'image/png' }),
    url: `blob:${name}`,
    id: name as FileId,
  });

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.clearAllMocks();
  });

  it('renders empty state when no files', () => {
    render(
      <FileSection
        files={null}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );
    expect(screen.getByText(/no files selected/i)).toBeInTheDocument();
  });

  it('renders file count and Select button when files exist', () => {
    const files = [createMockFile('test1.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );
    expect(screen.getByText('1 file')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /select/i })).toBeInTheDocument();
  });

  it('enters selection mode when Select button is clicked', () => {
    const files = [createMockFile('test1.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );

    fireEvent.click(screen.getByRole('button', { name: /select/i }));

    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument();
  });

  it('selects all files when All button is clicked in selection mode', () => {
    const files = [createMockFile('test1.png'), createMockFile('test2.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );

    fireEvent.click(screen.getByRole('button', { name: /select/i }));
    fireEvent.click(screen.getByRole('button', { name: /all/i }));

    const checkmarks = screen.getAllByRole('img', { hidden: true });
    expect(checkmarks).toHaveLength(2);
  });

  it('exits selection mode when Cancel button is clicked', () => {
    const files = [createMockFile('test1.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );

    fireEvent.click(screen.getByRole('button', { name: /select/i }));
    fireEvent.click(screen.getByRole('button', { name: /cancel/i }));

    expect(screen.getByRole('button', { name: /select/i })).toBeInTheDocument();
  });

  it('shows delete button when files are selected in selection mode', () => {
    const files = [createMockFile('test1.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );

    fireEvent.click(screen.getByRole('button', { name: /select/i }));

    const items = screen.getAllByText(/\.png$/);
    fireEvent.click(items[0]);

    expect(
      screen.getByRole('button', { name: /delete \(1\)/i })
    ).toBeInTheDocument();
  });

  it('calls onRemoveFiles when delete button is clicked', () => {
    const files = [createMockFile('test1.png')];
    render(
      <FileSection
        files={files}
        onRemoveFiles={mockOnRemoveFiles}
        onPreview={mockOnPreview}
      />
    );

    fireEvent.click(screen.getByRole('button', { name: /select/i }));
    const items = screen.getAllByText(/\.png$/);
    fireEvent.click(items[0]);
    fireEvent.click(screen.getByRole('button', { name: /delete/i }));

    expect(mockOnRemoveFiles).toHaveBeenCalledWith(['test1.png']);
  });
});

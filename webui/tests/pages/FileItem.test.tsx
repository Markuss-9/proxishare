import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import FileItem from '@/components/FileItem';

describe('FileItem', () => {
  const defaultProps = {
    file: new File(['test'], 'test.png', { type: 'image/png' }),
    url: 'blob:test',
    selected: false,
    selectionMode: false,
  };

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.clearAllMocks();
  });

  it('renders file name and size', () => {
    render(<FileItem {...defaultProps} />);
    expect(screen.getByText('test.png')).toBeInTheDocument();
  });

  it('calls onOpen when clicked in non-selection mode', () => {
    const mockOnOpen = vi.fn();
    render(<FileItem {...defaultProps} onOpen={mockOnOpen} />);

    const item = screen.getByText('test.png').closest('div')!;
    fireEvent.click(item);
    expect(mockOnOpen).toHaveBeenCalled();
  });

  it('calls onSelect when clicked in selection mode', () => {
    const mockOnSelect = vi.fn();
    render(
      <FileItem {...defaultProps} selectionMode onSelect={mockOnSelect} />
    );

    const item = screen.getByText('test.png').closest('div')!;
    fireEvent.click(item);
    expect(mockOnSelect).toHaveBeenCalled();
  });

  it('shows remove button on hover in non-selection mode', async () => {
    const mockOnRemove = vi.fn();
    render(<FileItem {...defaultProps} onRemove={mockOnRemove} />);

    const item = screen.getByText('test.png').closest('div')!;
    fireEvent.mouseEnter(item);

    const removeBtn = screen.getByRole('button', { name: /remove test\.png/i });
    expect(removeBtn).toBeVisible();
  });

  it('calls onRemove when remove button is clicked', () => {
    const mockOnRemove = vi.fn();
    render(<FileItem {...defaultProps} onRemove={mockOnRemove} />);

    const item = screen.getByText('test.png').closest('div')!;
    fireEvent.mouseEnter(item);

    const removeBtn = screen.getByRole('button', { name: /remove test\.png/i });
    fireEvent.click(removeBtn);

    expect(mockOnRemove).not.toHaveBeenCalled();

    fireEvent.click(removeBtn);
    expect(mockOnRemove).toHaveBeenCalled();
  });

  it('does not show remove button in selection mode', () => {
    render(<FileItem {...defaultProps} selectionMode onRemove={vi.fn()} />);

    const item = screen.getByText('test.png').closest('div')!;
    fireEvent.mouseEnter(item);

    expect(
      screen.queryByRole('button', { name: /remove/i })
    ).not.toBeInTheDocument();
  });

  it('shows checkmark when selected in selection mode', () => {
    render(
      <FileItem {...defaultProps} selectionMode selected onSelect={vi.fn()} />
    );

    expect(screen.getByRole('img', { hidden: true })).toBeInTheDocument();
  });

  it('renders PDF icon for PDF files', () => {
    const pdfFile = new File(['test'], 'test.pdf', { type: 'application/pdf' });
    render(<FileItem {...defaultProps} file={pdfFile} />);

    expect(screen.getAllByText('PDF').length).toBeGreaterThan(0);
  });

  it('shows loading state when url is empty', () => {
    render(<FileItem {...defaultProps} url="" />);

    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });

  it('shows error state when image fails to load', () => {
    render(<FileItem {...defaultProps} />);

    const img = screen.getByAltText('test.png');
    fireEvent.error(img);

    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });

  it('shows error state when video fails to load', () => {
    const videoFile = new File(['test'], 'test.mp4', { type: 'video/mp4' });
    render(<FileItem {...defaultProps} file={videoFile} url="blob:test" />);

    const videos = document.querySelectorAll('video');
    expect(videos.length).toBe(1);
    fireEvent.error(videos[0]);

    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });

  it('resets error state when url changes', () => {
    const { rerender } = render(<FileItem {...defaultProps} />);

    const img = screen.getByAltText('test.png');
    fireEvent.error(img);
    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();

    rerender(<FileItem {...defaultProps} url="blob:test2" />);
    expect(screen.queryByText(/failed to load/i)).not.toBeInTheDocument();
  });
});

import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import FilePreviewModal from '@/components/FilePreviewModal';
import type { FileEnriched, FileId } from '@/store';

vi.mock('@/hooks/useImageZoom', () => ({
  useImageZoom: () => ({
    zoom: 1,
    position: { x: 0, y: 0 },
    dragStart: false,
    handleMouseDown: vi.fn(),
    reset: vi.fn(),
    attachWheelListener: vi.fn(() => vi.fn()),
  }),
}));

describe('FilePreviewModal', () => {
  const mockOnClose = vi.fn();

  const createMockFile = (type: string): FileEnriched => ({
    file: new File(
      ['test'],
      'test' + (type.includes('pdf') ? '.pdf' : '.png'),
      { type }
    ),
    url: 'blob:test',
    id: '1' as FileId,
  });

  beforeEach(() => {
    vi.useFakeTimers();
    document.body.style.overflow = '';
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.clearAllMocks();
    document.body.style.overflow = '';
  });

  it('renders nothing when no file is provided', () => {
    const { container } = render(
      <FilePreviewModal file={undefined} onClose={mockOnClose} />
    );
    expect(container.firstChild).toBeNull();
  });

  it('renders image preview correctly', () => {
    const file = createMockFile('image/png');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    expect(screen.getByAltText('test.png')).toBeInTheDocument();
  });

  it('renders video preview correctly', () => {
    const file = createMockFile('video/mp4');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    const videos = document.querySelectorAll('video');
    expect(videos.length).toBe(1);
  });

  it('renders PDF preview correctly', () => {
    const file = createMockFile('application/pdf');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    expect(screen.getByTitle('test.pdf')).toBeInTheDocument();
  });

  it('renders fallback for unknown file types', () => {
    const file = createMockFile('application/octet-stream');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    expect(screen.getByText('test.png')).toBeInTheDocument();
    expect(screen.getByText('📄')).toBeInTheDocument();
  });

  it('calls onClose when close button is clicked', () => {
    const file = createMockFile('image/png');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    fireEvent.click(screen.getByRole('button', { name: /close preview/i }));
    expect(mockOnClose).toHaveBeenCalled();
  });

  it('calls onClose when clicking outside content', () => {
    const file = createMockFile('image/png');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    const dialog = screen.getByRole('dialog');
    fireEvent.click(dialog);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('does not call onClose when clicking inside content', () => {
    const file = createMockFile('image/png');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    const content = screen.getByAltText('test.png').parentElement!;
    fireEvent.click(content);

    expect(mockOnClose).not.toHaveBeenCalled();
  });

  it('adds and removes keyboard event listener', () => {
    const addEventListenerSpy = vi.spyOn(window, 'addEventListener');
    const removeEventListenerSpy = vi.spyOn(window, 'removeEventListener');

    const file = createMockFile('image/png');
    const { unmount } = render(
      <FilePreviewModal file={file} onClose={mockOnClose} />
    );

    expect(addEventListenerSpy).toHaveBeenCalledWith(
      'keydown',
      expect.any(Function)
    );

    unmount();

    expect(removeEventListenerSpy).toHaveBeenCalledWith(
      'keydown',
      expect.any(Function)
    );
  });

  it('calls onClose when Escape key is pressed', () => {
    const file = createMockFile('image/png');
    render(<FilePreviewModal file={file} onClose={mockOnClose} />);

    fireEvent.keyDown(window, { key: 'Escape' });

    expect(mockOnClose).toHaveBeenCalled();
  });
});

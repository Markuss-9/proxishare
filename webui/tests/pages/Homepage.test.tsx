import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Homepage from '@/pages/Homepage';
import * as store from '@/store';
import * as client from '@/client';

vi.mock('@/hooks/useServerStatus', () => ({
  useServerStatus: () => ({
    status: 'connected',
    checkConnection: vi.fn(),
  }),
}));

describe('Homepage', () => {
  const mockSetMode = vi.fn();
  const mockSetUploading = vi.fn();
  const mockAddFiles = vi.fn();
  const mockRemoveFiles = vi.fn();
  const mockClearFiles = vi.fn();
  const mockUpdateFileProgress = vi.fn();

  beforeEach(() => {
    vi.spyOn(client.LocalServer, 'post').mockResolvedValue({ data: 'ok' });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  const getMockStore = (overrides = {}) => ({
    files: [],
    setFiles: vi.fn(),
    addFiles: mockAddFiles,
    removeFiles: mockRemoveFiles,
    clearFiles: mockClearFiles,
    updateFileProgress: mockUpdateFileProgress,
    mode: 'media',
    setMode: mockSetMode,
    uploading: false,
    setUploading: mockSetUploading,
    ...overrides,
  });

  const getFileInput = () => screen.getByLabelText(/(select|choose)\s*files?/i);

  it('renders file input and disabled Share button initially', () => {
    vi.spyOn(store, 'useMediaStore').mockReturnValue(getMockStore() as any);
    render(<Homepage />);
    const fileInput = getFileInput();

    const shareButton = screen.getByRole('button', {
      name: /share/i,
    });

    expect(fileInput).toBeInTheDocument();
    expect(shareButton).toBeDisabled();
  });

  it('calls addFiles when a file is selected', () => {
    vi.spyOn(store, 'useMediaStore').mockReturnValue(getMockStore() as any);

    render(<Homepage />);
    const fileInput = getFileInput() as HTMLInputElement;

    const file = new File(['hello'], 'hello.png', { type: 'image/png' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    expect(mockAddFiles).toHaveBeenCalled();
    expect(mockAddFiles).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          file: file,
        }),
      ])
    );
  });

  it('appends files when selecting additional files', () => {
    const file1 = new File(['a'], 'a.png', { type: 'image/png' });
    const file2 = new File(['b'], 'b.png', { type: 'image/png' });

    vi.spyOn(store, 'useMediaStore').mockReturnValue(
      getMockStore({ files: [{ file: file1, url: 'blob:a', id: '1' }] }) as any
    );

    render(<Homepage />);
    const fileInput = getFileInput() as HTMLInputElement;
    fireEvent.change(fileInput, {
      target: { files: [file2] },
    });

    expect(mockAddFiles).toHaveBeenCalled();
    const calledWith = mockAddFiles.mock.calls[0][0];
    expect(calledWith).toHaveLength(1);
    expect(calledWith[0].file).toBe(file2);
  });

  it('selects and removes multiple files when in selection mode', () => {
    const a = new File(['a'], 'a.png', { type: 'image/png' });
    const b = new File(['b'], 'b.png', { type: 'image/png' });
    const c = new File(['c'], 'c.png', { type: 'image/png' });

    vi.spyOn(store, 'useMediaStore').mockReturnValue(
      getMockStore({
        files: [
          { file: a, url: 'blob:a', id: '1' },
          { file: b, url: 'blob:b', id: '2' },
          { file: c, url: 'blob:c', id: '3' },
        ],
      }) as any
    );

    render(<Homepage />);

    const selectBtn = screen.getByRole('button', {
      name: /Select/i,
    });
    fireEvent.click(selectBtn);

    const itemA = screen.getByText(/a.png/i);
    const itemC = screen.getByText(/c.png/i);
    fireEvent.click(itemA);
    fireEvent.click(itemC);

    const removeBtn = screen.getByRole('button', { name: /Delete/i });
    fireEvent.click(removeBtn);

    expect(mockRemoveFiles).toHaveBeenCalledWith(['1', '3']);
  });

  it('uploads file when Share button is clicked', async () => {
    const file = new File(['data'], 'data.png', { type: 'image/png' });

    vi.spyOn(store, 'useMediaStore').mockReturnValue(
      getMockStore({ files: [{ file, url: 'blob:1', id: '1' }] }) as any
    );

    vi.useFakeTimers();

    render(<Homepage />);

    const shareButton = screen.getByRole('button', {
      name: /Share/i,
    });
    fireEvent.click(shareButton);

    expect(mockSetUploading).toHaveBeenCalledWith(true);
    expect(client.LocalServer.post).toHaveBeenCalled();

    await act(async () => {
      await Promise.resolve();
    });

    vi.runAllTimers();

    expect(mockSetUploading).toHaveBeenCalledWith(false);

    vi.useRealTimers();
  });
});

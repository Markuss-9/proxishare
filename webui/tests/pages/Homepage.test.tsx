import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Homepage from '@/pages/Homepage';
import * as store from '@/store';
import * as client from '@/client';

describe('Homepage', () => {
  // Mock Zustand store
  const mockSetFiles = vi.fn();
  const mockSetMode = vi.fn();
  const mockSetUploading = vi.fn();

  beforeEach(() => {
    vi.spyOn(client.LocalServer, 'post').mockResolvedValue({ data: 'ok' });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  // helper to find the file input label (matches "Select file", "Choose Files", etc.)
  const getFileInput = () => screen.getByLabelText(/(select|choose)\s*files?/i);

  const applyUpdater = (updater: any, prev: any) => {
    if (typeof updater === 'function') return updater(prev);
    // direct value (array/object) — return as-is
    return updater;
  };

  it('renders file input and disabled Share button initially', () => {
    render(<Homepage />);
    const fileInput = getFileInput();

    const shareButton = screen.getByRole('button', {
      name: /share/i,
    });

    expect(fileInput).toBeInTheDocument();
    expect(shareButton).toBeDisabled();
  });

  it('calls setFiles when a file is selected', () => {
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);
    const fileInput = getFileInput() as HTMLInputElement;

    const file = new File(['hello'], 'hello.png', { type: 'image/png' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    expect(mockSetFiles).toHaveBeenCalled();
    expect(mockSetFiles).toHaveBeenCalledWith(
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

    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [{ file: file1, url: 'blob:a', id: '1' }],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);
    const fileInput = getFileInput() as HTMLInputElement;
    fireEvent.change(fileInput, {
      target: { files: [file2] },
    });

    expect(mockSetFiles).toHaveBeenCalled();
    const updater = mockSetFiles.mock.calls[0][0];
    expect(typeof updater === 'function' || typeof updater === 'object').toBe(
      true
    );

    const prev = [{ file: file1, url: 'blob:a', id: '1' }];
    const result = applyUpdater(updater, prev);

    expect(Array.isArray(result)).toBe(true);
    expect(result.length).toBe(2);
    expect(result[0].file).toBe(file1);
    expect(result[1].file).toBe(file2);
  });

  it('selects and removes multiple files when in selection mode', () => {
    const a = new File(['a'], 'a.png', { type: 'image/png' });
    const b = new File(['b'], 'b.png', { type: 'image/png' });
    const c = new File(['c'], 'c.png', { type: 'image/png' });

    vi.restoreAllMocks();
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [
        { file: a, url: 'blob:a', id: '1' },
        { file: b, url: 'blob:b', id: '2' },
        { file: c, url: 'blob:c', id: '3' },
      ],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);

    // enter selection mode via the selection/choose button (not by clicking file input)
    const selectBtn = screen.getByRole('button', {
      name: /Select/i,
    });
    fireEvent.click(selectBtn);

    // click two items (by name)
    const itemA = screen.getByText(/a.png/i);
    const itemC = screen.getByText(/c.png/i);
    fireEvent.click(itemA);
    fireEvent.click(itemC);

    // click the "Remove selected" action (not the global Clear)
    const removeBtn = screen.getByRole('button', { name: /Delete/i });
    fireEvent.click(removeBtn);

    expect(mockSetFiles).toHaveBeenCalled();
    const updater = mockSetFiles.mock.calls[0][0];
    const prev = [
      { file: a, url: 'blob:a', id: '1' },
      { file: b, url: 'blob:b', id: '2' },
      { file: c, url: 'blob:c', id: '3' },
    ];
    const result = applyUpdater(updater, prev);

    expect(Array.isArray(result)).toBe(true);
    expect(result.length).toBe(1);
    expect(result[0].file).toBe(b);
  });

  it('uploads file when Share button is clicked', async () => {
    const file = new File(['data'], 'data.png', { type: 'image/png' });

    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [{ file }],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    // use fake timers to control the setTimeout in finally for setUploading(false)
    vi.useFakeTimers();

    render(<Homepage />);

    const shareButton = screen.getByRole('button', {
      name: /Share/i,
    });
    fireEvent.click(shareButton);

    expect(mockSetUploading).toHaveBeenCalledWith(true);
    expect(client.LocalServer.post).toHaveBeenCalled();

    // wait for the async operations to complete (LocalServer.post)
    await act(async () => {
      await Promise.resolve();
    });

    vi.runAllTimers();

    expect(mockSetUploading).toHaveBeenCalledWith(false);

    vi.useRealTimers();
  });
});

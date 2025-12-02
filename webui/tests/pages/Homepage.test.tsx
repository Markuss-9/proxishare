import { render, screen, fireEvent, waitFor } from '@testing-library/react';
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
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    // Mock LocalServer.post
    vi.spyOn(client.LocalServer, 'post').mockResolvedValue({ data: 'ok' });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('renders file input and disabled Share button initially', () => {
    render(<Homepage />);
    const fileInput = screen.getByLabelText(/file/i); // fallback

    const shareButton = screen.getByRole('button', {
      name: /share on local network/i,
    });

    expect(fileInput).toBeInTheDocument();
    expect(shareButton).toBeDisabled();
  });

  it('calls setFiles when a file is selected', () => {
    render(<Homepage />);
    const fileInput = screen.getByLabelText(/file/i) as HTMLInputElement;

    const file = new File(['hello'], 'hello.png', { type: 'image/png' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    expect(mockSetFiles).toHaveBeenCalled();
    // setFiles is called with an updater function (append logic)
    expect(typeof mockSetFiles.mock.calls[0][0]).toBe('function');
  });

  it('appends files when selecting additional files', () => {
    const file1 = new File(['a'], 'a.png', { type: 'image/png' });
    const file2 = new File(['b'], 'b.png', { type: 'image/png' });

    // initial store has file1
    vi.restoreAllMocks();
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [file1],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);
    const fileInput = screen.getByLabelText(/file/i) as HTMLInputElement;
    fireEvent.change(fileInput, { target: { files: [file2] } });

    expect(mockSetFiles).toHaveBeenCalled();
    // extract updater and apply it to prev state to see outcome
    const updater = mockSetFiles.mock.calls[0][0];
    expect(typeof updater).toBe('function');
    const result = updater([file1]);
    expect(result).toEqual([file1, file2]);
  });

  it('selects and removes multiple files when in selection mode', () => {
    const a = new File(['a'], 'a.png', { type: 'image/png' });
    const b = new File(['b'], 'b.png', { type: 'image/png' });
    const c = new File(['c'], 'c.png', { type: 'image/png' });

    vi.restoreAllMocks();
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [a, b, c],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);

    // enter selection mode
    const selectBtn = screen.getByRole('button', { name: /select/i });
    fireEvent.click(selectBtn);

    // click two items (by name)
    const itemA = screen.getByText(/a.png/i);
    const itemC = screen.getByText(/c.png/i);
    fireEvent.click(itemA);
    fireEvent.click(itemC);

    // remove selected
    const removeBtn = screen.getByRole('button', { name: /remove selected/i });
    fireEvent.click(removeBtn);

    expect(mockSetFiles).toHaveBeenCalled();
    const updater = mockSetFiles.mock.calls[0][0];
    const result = updater([a, b, c]);
    // after removing a and c, only b remains
    expect(result).toEqual([b]);
  });

  it('uploads file when Share button is clicked', async () => {
    const file = new File(['data'], 'data.png', { type: 'image/png' });

    // Mock Zustand to include selected file
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      files: [file],
      setFiles: mockSetFiles,
      mode: 'media',
      setMode: mockSetMode,
      uploading: false,
      setUploading: mockSetUploading,
    } as any);

    render(<Homepage />);

    const shareButton = screen.getByRole('button', {
      name: /share on local network/i,
    });
    fireEvent.click(shareButton);

    await waitFor(() => expect(mockSetUploading).toHaveBeenCalledWith(true));
    await waitFor(() => expect(client.LocalServer.post).toHaveBeenCalled());
    await waitFor(() => expect(mockSetUploading).toHaveBeenCalledWith(false));
  });
});

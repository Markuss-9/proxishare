import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Homepage from '@/pages/Homepage';
import * as store from '@/store';
import * as client from '@/client';

describe('Homepage', () => {
  // Mock Zustand store
  const mockSetFile = vi.fn();
  const mockSetUploading = vi.fn();

  beforeEach(() => {
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      file: null,
      setFile: mockSetFile,
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

  it('calls setFile when a file is selected', () => {
    render(<Homepage />);
    const fileInput = screen.getByLabelText(/file/i) as HTMLInputElement;

    const file = new File(['hello'], 'hello.png', { type: 'image/png' });
    fireEvent.change(fileInput, { target: { files: [file] } });

    expect(mockSetFile).toHaveBeenCalledWith(file);
  });

  it('uploads file when Share button is clicked', async () => {
    const file = new File(['data'], 'data.png', { type: 'image/png' });

    // Mock Zustand to include selected file
    vi.spyOn(store, 'useMediaStore').mockReturnValue({
      file,
      setFile: mockSetFile,
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

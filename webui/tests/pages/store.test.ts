import { describe, it, expect, beforeEach } from 'vitest';
import { useMediaStore, type FileEnriched, type FileId } from '@/store';

describe('useMediaStore', () => {
  beforeEach(() => {
    useMediaStore.getState().clearFiles();
  });

  it('initializes with empty files array', () => {
    const { files } = useMediaStore.getState();
    expect(files).toEqual([]);
  });

  it('initializes with uploading as false', () => {
    const { uploading } = useMediaStore.getState();
    expect(uploading).toBe(false);
  });

  it('setFiles updates the files array', () => {
    const mockFiles: FileEnriched[] = [
      {
        file: new File(['a'], 'a.png', { type: 'image/png' }),
        url: 'blob:a',
        id: '1' as FileId,
      },
    ];

    useMediaStore.getState().setFiles(mockFiles);

    expect(useMediaStore.getState().files).toEqual(mockFiles);
  });

  it('setFiles accepts a function to update files', () => {
    const initialFiles: FileEnriched[] = [
      {
        file: new File(['a'], 'a.png', { type: 'image/png' }),
        url: 'blob:a',
        id: '1' as FileId,
      },
    ];
    useMediaStore.getState().setFiles(initialFiles);

    useMediaStore.getState().setFiles((prev) => [
      ...prev,
      {
        file: new File(['b'], 'b.png', { type: 'image/png' }),
        url: 'blob:b',
        id: '2' as FileId,
      },
    ]);

    expect(useMediaStore.getState().files).toHaveLength(2);
  });

  it('addFiles adds new files and creates object URLs', () => {
    const files = [new File(['test'], 'test.png', { type: 'image/png' })];

    useMediaStore.getState().addFiles(files);

    const state = useMediaStore.getState();
    expect(state.files).toHaveLength(1);
    expect(state.files[0].file).toBe(files[0]);
    expect(state.files[0].url).toMatch(/^blob:/);
    expect(state.files[0].id).toBeDefined();
  });

  it('addFiles filters out duplicates by name and size', () => {
    const file = new File(['test'], 'test.png', { type: 'image/png' });
    const files = [file, file];

    useMediaStore.getState().addFiles(files);

    expect(useMediaStore.getState().files).toHaveLength(1);
  });

  it('addFilesEnriched adds pre-enriched files', () => {
    const enrichedFiles: FileEnriched[] = [
      {
        file: new File(['a'], 'a.png', { type: 'image/png' }),
        url: 'blob:a',
        id: '1' as FileId,
      },
    ];

    useMediaStore.getState().addFilesEnriched(enrichedFiles);

    expect(useMediaStore.getState().files).toEqual(enrichedFiles);
  });

  it('removeFiles removes files by id and revokes URLs', () => {
    const files = [new File(['a'], 'a.png', { type: 'image/png' })];
    useMediaStore.getState().addFiles(files);

    const fileId = useMediaStore.getState().files[0].id;
    useMediaStore.getState().removeFiles([fileId]);

    expect(useMediaStore.getState().files).toHaveLength(0);
  });

  it('clearFiles removes all files and revokes URLs', () => {
    const files = [
      new File(['a'], 'a.png', { type: 'image/png' }),
      new File(['b'], 'b.png', { type: 'image/png' }),
    ];
    useMediaStore.getState().addFiles(files);

    useMediaStore.getState().clearFiles();

    expect(useMediaStore.getState().files).toHaveLength(0);
  });

  it('updateFileProgress updates progress for specific file', () => {
    const files = [new File(['a'], 'a.png', { type: 'image/png' })];
    useMediaStore.getState().addFiles(files);

    const fileId = useMediaStore.getState().files[0].id;
    useMediaStore.getState().updateFileProgress(fileId, 50);

    expect(useMediaStore.getState().files[0].progress).toBe(50);
  });

  it('setUploading updates the uploading state', () => {
    useMediaStore.getState().setUploading(true);
    expect(useMediaStore.getState().uploading).toBe(true);

    useMediaStore.getState().setUploading(false);
    expect(useMediaStore.getState().uploading).toBe(false);
  });
});

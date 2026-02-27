import { create } from 'zustand';

export type FileId = string;
export interface FileEnriched {
  file: File;
  url: string;
  id: FileId;
  progress?: number;
}

export type ModeOptions = 'media' | 'all' | 'folder';

const revokeAllUrls = (files: FileEnriched[]) => {
  files.forEach((f) => URL.revokeObjectURL(f.url));
};

type MediaState = {
  files: FileEnriched[];
  setFiles: (
    files: FileEnriched[] | ((prev: FileEnriched[]) => FileEnriched[])
  ) => void;
  addFiles: (newFiles: FileEnriched[]) => void;
  removeFiles: (ids: FileId[]) => void;
  clearFiles: () => void;
  updateFileProgress: (id: FileId, progress: number) => void;
  mode: ModeOptions;
  setMode: (m: ModeOptions) => void;
  uploading: boolean;
  setUploading: (state: boolean) => void;
};

export const useMediaStore = create<MediaState>((set) => ({
  files: [],
  setFiles: (files) =>
    set((state) => {
      const newFiles = typeof files === 'function' ? files(state.files) : files;
      return { files: newFiles };
    }),
  addFiles: (newFiles) =>
    set((state) => ({ files: [...state.files, ...newFiles] })),
  removeFiles: (ids) =>
    set((state) => {
      const toRemove = state.files.filter((f) => ids.includes(f.id));
      toRemove.forEach((f) => URL.revokeObjectURL(f.url));
      return { files: state.files.filter((f) => !ids.includes(f.id)) };
    }),
  clearFiles: () =>
    set((state) => {
      revokeAllUrls(state.files);
      return { files: [] };
    }),
  updateFileProgress: (id, progress) =>
    set((state) => ({
      files: state.files.map((f) => (f.id === id ? { ...f, progress } : f)),
    })),
  mode: 'media',
  setMode: (m) => set({ mode: m }),
  uploading: false,
  setUploading: (state) => set({ uploading: state }),
}));

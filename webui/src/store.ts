import { create } from 'zustand';

export type FileId = string;
export interface FileEnriched {
  file: File;
  url: string;
  id: FileId;
}

export type ModeOptions = 'media' | 'all' | 'folder';

type MediaState = {
  files: FileEnriched[];
  setFiles: (files: FileEnriched[]) => void;
  mode: ModeOptions;
  setMode: (m: ModeOptions) => void;
  uploading: boolean;
  setUploading: (state: boolean) => void;
};

export const useMediaStore = create<MediaState>((set) => ({
  files: [],
  setFiles: (files) => set({ files }),
  mode: 'media',
  setMode: (m) => set({ mode: m }),
  uploading: false,
  setUploading: (state) => set({ uploading: state }),
}));

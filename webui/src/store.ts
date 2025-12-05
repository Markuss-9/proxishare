import { create } from 'zustand';

export type FileId = string;
export interface FileEnriched {
  file: File;
  url: string;
  id: FileId;
}

type MediaState = {
  // allow multiple file selection
  files: FileEnriched[];
  setFiles: (files: FileEnriched[]) => void;
  // mode: media (images/videos) or generic files
  mode: 'media' | 'files';
  setMode: (m: 'media' | 'files') => void;
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

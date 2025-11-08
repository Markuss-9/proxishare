import { create } from 'zustand';

type MediaState = {
  file: File | null;
  setFile: (file: File | null) => void;
  uploading: boolean;
  setUploading: (state: boolean) => void;
};

export const useMediaStore = create<MediaState>((set) => ({
  file: null,
  setFile: (file) => set({ file }),
  uploading: false,
  setUploading: (state) => set({ uploading: state }),
}));

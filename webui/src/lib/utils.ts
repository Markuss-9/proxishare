import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const isImage = (type: string) => type.startsWith('image/');
export const isVideo = (type: string) => type.startsWith('video/');
export const isPdf = (type: string) => type === 'application/pdf';

export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
  if (bytes < 1024 * 1024 * 1024)
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} GB`;
}

export function partition<T>(
  array: T[],
  predicate: (item: T) => boolean
): [T[], T[]] {
  return array.reduce<[T[], T[]]>(
    ([pass, fail], element) => {
      if (predicate(element)) {
        pass.push(element);
      } else {
        fail.push(element);
      }
      return [pass, fail];
    },
    [[], []]
  );
}

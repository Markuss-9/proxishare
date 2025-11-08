import { useState } from 'react';
import { useMediaStore } from '../store.ts';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { LocalServer } from '@/client.ts';

export default function Homepage() {
  const { file, setFile, uploading, setUploading } = useMediaStore();
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<Error>();

  const handleSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (f) setFile(f);
  };

  const handleShare = async () => {
    if (!file) return;
    setUploading(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await LocalServer.post('/upload', formData);
      console.log('handleShare completed', res);

      setProgress(100);
    } catch (error) {
      console.error(error);
      setError(error as Error);
    } finally {
      setUploading(false);
      setTimeout(() => setProgress(0), 1500);
    }
  };

  return (
    <div className="flex h-screen items-center justify-center bg-gray-50">
      <Card className="w-full max-w-sm shadow-md">
        <CardHeader>
          <CardTitle className="text-xl font-semibold">
            Local Media Share
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <input type="file" accept="image/*,video/*" onChange={handleSelect} />
          {file && <p className="text-sm text-gray-500">{file.name}</p>}

          {uploading ? (
            <Progress value={progress} className="w-full" />
          ) : (
            <Button onClick={handleShare} disabled={!file}>
              Share on Local Network
            </Button>
          )}
          {error && <div>{error.message}</div>}
        </CardContent>
      </Card>
    </div>
  );
}

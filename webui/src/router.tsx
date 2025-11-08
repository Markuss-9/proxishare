import { createBrowserRouter } from 'react-router';
import { RouterProvider } from 'react-router/dom';
import Homepage from './pages/homepage.tsx';
import { isRouteErrorResponse, useRouteError } from 'react-router';

const router = createBrowserRouter(
  [
    {
      path: '/',
      children: [
        { index: true, path: '', element: <Homepage /> },
        { path: 'other', element: <Other /> },
        { path: '*', element: <NotFound /> },
      ],
      ErrorBoundary,
    },
  ],
  {
    basename: 'webui',
  }
);

function Other() {
  return <div>other</div>;
}

function NotFound() {
  return <div>Route not found</div>;
}

export function ErrorBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    return (
      <div>
        <h1>
          {error.status} {error.statusText}
        </h1>
        <p>{error.data}</p>
      </div>
    );
  } else if (error instanceof Error) {
    return (
      <div>
        <h1>Error</h1>
        <p>{error.message}</p>
        <p>The stack trace is:</p>
        <pre>{error.stack}</pre>
      </div>
    );
  } else {
    return <h1>Unknown Error</h1>;
  }
}

export default function Router() {
  console.log('router');
  return <RouterProvider router={router} />;
}

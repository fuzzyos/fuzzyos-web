import { authkitMiddleware } from '@workos-inc/authkit-nextjs';
import { NextRequest, NextFetchEvent } from 'next/server';

const authMiddleware = authkitMiddleware({
  // Explicitly set redirect URI from environment variable
  redirectUri: process.env.WORKOS_REDIRECT_URI,
  // Configure middleware authentication
  middlewareAuth: {
    enabled: true,
    unauthenticatedPaths: ['/', '/privacy', '/terms', '/api/debug-headers'],
  },
  // Debug logging
  debug: process.env.NODE_ENV === 'development',
});

export default async function middleware(request: NextRequest, event: NextFetchEvent) {
  // Fix the request URL to use X-Forwarded-Host instead of pod hostname
  const forwardedHost = request.headers.get('x-forwarded-host');
  const forwardedProto = request.headers.get('x-forwarded-proto') || 'https';

  if (forwardedHost) {
    // Create a new URL with the correct host
    const url = new URL(request.url);
    const fixedUrl = `${forwardedProto}://${forwardedHost}${url.pathname}${url.search}`;

    // Create a new request with the fixed URL
    const fixedRequest = new NextRequest(fixedUrl, {
      headers: request.headers,
      method: request.method,
    });

    // Pass the fixed request to WorkOS middleware
    return authMiddleware(fixedRequest, event);
  }

  // If no forwarded host, use the original request
  return authMiddleware(request, event);
}

export const config = {
  // Match all routes except static files
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - images (public images folder)
     * - assets (public assets folder)
     * - install.sh / install.ps1 (public install scripts)
     */
    '/((?!_next/static|_next/image|favicon.ico|images|assets|install\.sh|install\.ps1).*)',
  ],
};

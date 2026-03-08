import { handleAuth } from '@workos-inc/authkit-nextjs';
import { NextRequest } from 'next/server';

// Wrap handleAuth to add debug logging
const authHandler = handleAuth({
  returnPathname: '/',
});

export async function GET(request: NextRequest) {
  // Fix request URL to use X-Forwarded-Host instead of pod hostname
  const forwardedHost = request.headers.get('x-forwarded-host');
  const forwardedProto = request.headers.get('x-forwarded-proto') || 'https';

  // Debug: Log request information
  console.log('=== Auth Callback Debug ===');
  console.log('Original Request URL:', request.url);
  console.log('Host Header:', request.headers.get('host'));
  console.log('X-Forwarded-Host:', forwardedHost);
  console.log('X-Forwarded-Proto:', forwardedProto);

  let fixedRequest = request;

  if (forwardedHost) {
    // Create a new URL with the correct host
    const url = new URL(request.url);
    const fixedUrl = `${forwardedProto}://${forwardedHost}${url.pathname}${url.search}`;

    console.log('Fixed Request URL:', fixedUrl);

    // Create a new request with the fixed URL
    fixedRequest = new NextRequest(fixedUrl, {
      headers: request.headers,
      method: request.method,
    });
  }

  console.log('WORKOS_REDIRECT_URI:', process.env.WORKOS_REDIRECT_URI);
  console.log('NEXT_PUBLIC_APP_URL:', process.env.NEXT_PUBLIC_APP_URL);
  console.log('========================');

  // Call WorkOS AuthKit handler with fixed request
  return authHandler(fixedRequest);
}

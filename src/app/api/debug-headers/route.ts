import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  // Get all headers
  const headers: Record<string, string> = {};
  request.headers.forEach((value, key) => {
    headers[key] = value;
  });

  // Get environment variables (without sensitive data)
  const envVars = {
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_WORKOS_REDIRECT_URI: process.env.NEXT_PUBLIC_WORKOS_REDIRECT_URI,
    WORKOS_REDIRECT_URI: process.env.WORKOS_REDIRECT_URI,
    NEXTAUTH_URL: process.env.NEXTAUTH_URL,
    NODE_ENV: process.env.NODE_ENV,
    // Mask sensitive values
    WORKOS_API_KEY: process.env.WORKOS_API_KEY ? '***SET***' : 'NOT_SET',
    WORKOS_CLIENT_ID: process.env.WORKOS_CLIENT_ID ? '***SET***' : 'NOT_SET',
    WORKOS_COOKIE_PASSWORD: process.env.WORKOS_COOKIE_PASSWORD ? '***SET***' : 'NOT_SET',
  };

  // Get request URL info
  const requestInfo = {
    url: request.url,
    method: request.method,
    hostname: new URL(request.url).hostname,
    protocol: new URL(request.url).protocol,
    pathname: new URL(request.url).pathname,
  };

  return NextResponse.json({
    headers,
    envVars,
    requestInfo,
    timestamp: new Date().toISOString(),
  }, {
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

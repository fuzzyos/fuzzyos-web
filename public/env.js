// Runtime environment variables injected by docker-entrypoint.sh
window.__ENV__ = {
  NEXT_PUBLIC_WORKOS_REDIRECT_URI: '__NEXT_PUBLIC_WORKOS_REDIRECT_URI__'.startsWith('__') ? undefined : '__NEXT_PUBLIC_WORKOS_REDIRECT_URI__',
  NEXT_PUBLIC_API_URL: '__NEXT_PUBLIC_API_URL__'.startsWith('__') ? undefined : '__NEXT_PUBLIC_API_URL__',
  NEXT_PUBLIC_APP_URL: '__NEXT_PUBLIC_APP_URL__'.startsWith('__') ? undefined : '__NEXT_PUBLIC_APP_URL__'
};

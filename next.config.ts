import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',
  transpilePackages: ['@workos-inc/authkit-nextjs'],
};

export default nextConfig;

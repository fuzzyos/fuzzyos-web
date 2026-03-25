import type { Metadata } from "next";
import Script from "next/script";
import { Theme } from "@radix-ui/themes";
import "@radix-ui/themes/styles.css";
import "./globals.css";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { AuthKitProvider } from "@workos-inc/authkit-nextjs/components";

export const metadata: Metadata = {
  title: "FuzzyOS - Minimal Terminal Coding Harness",
  description: "A minimal terminal coding harness. Adapt fuzzy to your workflows with Extensions, Skills, and Fuzzy Packages. Supports 20+ AI providers including Anthropic, OpenAI, and Google.",
  manifest: '/site.webmanifest',
  icons: {
    icon: [
      { url: '/assets/images/logo_text.svg', type: 'image/svg+xml' },
      { url: '/favicon.ico', sizes: 'any' },
    ],
    apple: { url: '/assets/images/logo_text.svg', type: 'image/svg+xml' },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <Script src="/env.js" strategy="beforeInteractive" />
      </head>
      <body>
        <AuthKitProvider>
          <Theme accentColor="purple" grayColor="slate" radius="medium" scaling="100%">
            <div className="min-h-screen flex flex-col">
              <Header />
              <main className="flex-1">
                {children}
              </main>
              <Footer />
            </div>
          </Theme>
        </AuthKitProvider>
      </body>
    </html>
  );
}

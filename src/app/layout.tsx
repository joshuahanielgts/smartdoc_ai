import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { cn } from '@/lib/utils';
import { Toaster } from '@/components/ui/toaster';
import { ThemeProvider } from '@/components/theme-provider';

const fontSans = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
});

export const metadata: Metadata = {
  title: 'LucidDrive AI - Drive Safe, Arrive Safe',
  description: 'LucidDrive AI is an advanced driver assistance system that uses your webcam to monitor fatigue levels in real-time, providing AI-powered alerts and safety tips to prevent accidents.',
  keywords: ['driver safety', 'fatigue detection', 'AI assistant', 'road safety', 'anti-sleep alarm', 'driver monitoring'],
  authors: [{ name: 'LucidDrive AI Team' }],
  creator: 'LucidDrive AI',
  publisher: 'LucidDrive AI',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={cn('min-h-screen bg-background font-sans antialiased', fontSans.variable)}>
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          {children}
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  );
}

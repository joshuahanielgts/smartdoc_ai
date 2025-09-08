import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Logo } from '@/components/icons';

export function DashboardHeader() {
  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b bg-card/80 px-4 backdrop-blur-sm md:px-8">
      <div className="flex items-center gap-3">
        <Logo className="h-8 w-8 text-primary" />
        <h1 className="text-xl font-bold tracking-tight text-foreground">DriveSafe AI</h1>
      </div>
      <Avatar>
        <AvatarImage src="https://picsum.photos/100/100" alt="User" data-ai-hint="person face" />
        <AvatarFallback>U</AvatarFallback>
      </Avatar>
    </header>
  );
}

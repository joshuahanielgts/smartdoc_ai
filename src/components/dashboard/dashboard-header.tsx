"use client";

import { Play, Square, Siren, LogOut, User } from "lucide-react";
import { Button } from "@/components/ui/button";
import { NotificationCenter } from "@/components/dashboard/notification-center";
import type { Alert, AlertContext } from "@/lib/types";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { signOut } from "@/lib/actions/auth";
import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { User as SupabaseUser } from "@supabase/supabase-js";

type DashboardHeaderProps = {
  isMonitoring: boolean;
  onStart: () => void;
  onStop: () => void;
  alerts: Alert[];
  getAlertContext: (alertId: string) => AlertContext | undefined;
};

export function DashboardHeader({
  isMonitoring,
  onStart,
  onStop,
  alerts,
  getAlertContext,
}: DashboardHeaderProps) {
  const [user, setUser] = useState<SupabaseUser | null>(null);

  useEffect(() => {
    const supabase = createClient();

    // Get initial user
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleSosClick = () => {
    window.location.href = "tel:+919667745648";
  };

  const handleSignOut = async () => {
    await signOut();
  };

  const getUserInitials = () => {
    if (!user) return "U";
    if (user.user_metadata?.full_name) {
      const names = user.user_metadata.full_name.split(" ");
      return names
        .map((n: string) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2);
    }
    return user.email?.charAt(0).toUpperCase() || "U";
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-white/10 bg-transparent px-4 backdrop-blur-sm md:px-8">
      <div className="flex items-center gap-3">
        <h1 className="text-xl font-bold text-foreground">LucidDrive AI</h1>
      </div>
      <div className="flex items-center gap-4">
        {!isMonitoring ? (
          <Button
            size="sm"
            onClick={onStart}
            className="bg-primary hover:bg-primary/90 text-primary-foreground"
          >
            <Play className="mr-2 h-4 w-4" /> Start Monitoring
          </Button>
        ) : (
          <Button size="sm" onClick={onStop} variant="destructive">
            <Square className="mr-2 h-4 w-4" /> Stop Monitoring
          </Button>
        )}
        <Button
          size="sm"
          variant="outline"
          onClick={handleSosClick}
          className="border-amber-500 text-amber-500 hover:bg-amber-500/10 hover:text-amber-400"
        >
          <Siren className="mr-2 h-4 w-4" />
          Trigger SOS
        </Button>
        <NotificationCenter alerts={alerts} getAlertContext={getAlertContext} />

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="relative h-10 w-10 rounded-full">
              <Avatar className="h-10 w-10">
                <AvatarImage
                  src={user?.user_metadata?.avatar_url}
                  alt={user?.email || "User"}
                />
                <AvatarFallback className="bg-primary text-primary-foreground">
                  {getUserInitials()}
                </AvatarFallback>
              </Avatar>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-56" align="end" forceMount>
            <DropdownMenuLabel className="font-normal">
              <div className="flex flex-col space-y-1">
                <p className="text-sm font-medium leading-none">
                  {user?.user_metadata?.full_name || "User"}
                </p>
                <p className="text-xs leading-none text-muted-foreground">
                  {user?.email}
                </p>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={handleSignOut}
              className="cursor-pointer"
            >
              <LogOut className="mr-2 h-4 w-4" />
              <span>Sign out</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}

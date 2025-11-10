import Link from "next/link";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AuthCodeError() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-background to-blue-950/20 p-4">
      <Card className="border-white/10 bg-card/50 backdrop-blur-xl max-w-md">
        <CardHeader>
          <CardTitle>Authentication Error</CardTitle>
          <CardDescription>
            Sorry, we couldn't complete your sign-in
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            There was a problem authenticating your account. Please try signing
            in again.
          </p>
        </CardContent>
        <CardFooter>
          <Button asChild className="w-full">
            <Link href="/login">Back to Login</Link>
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
}

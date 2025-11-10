# Troubleshooting Guide

Common issues and solutions for LucidDrive AI.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Development Server Issues](#development-server-issues)
- [Build Issues](#build-issues)
- [AI/API Issues](#aiapi-issues)
- [Webcam Issues](#webcam-issues)
- [Performance Issues](#performance-issues)
- [Browser Compatibility](#browser-compatibility)
- [Deployment Issues](#deployment-issues)

---

## Installation Issues

### `npm install` fails

**Problem**: Dependencies fail to install

**Solutions**:

1. **Clear npm cache**

   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Use correct Node version**

   ```bash
   node --version  # Should be 20.x or higher
   ```

3. **Check npm registry**

   ```bash
   npm config get registry
   # Should be: https://registry.npmjs.org/
   ```

4. **Try different package manager**

   ```bash
   # Using yarn
   yarn install

   # Using pnpm
   pnpm install
   ```

### TypeScript errors during install

**Problem**: Type definition conflicts

**Solution**:

```bash
# Delete and reinstall
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

---

## Development Server Issues

### Port 9002 already in use

**Problem**: `EADDRINUSE: address already in use :::9002`

**Solutions**:

**Windows PowerShell**:

```powershell
# Find process using port 9002
netstat -ano | findstr :9002

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F

# Or change port in package.json
"dev": "next dev --turbopack -p 3000"
```

**Mac/Linux**:

```bash
# Find and kill process
lsof -ti:9002 | xargs kill -9

# Or use different port
npm run dev -- -p 3000
```

### Hot reload not working

**Problem**: Changes don't reflect automatically

**Solutions**:

1. **Restart dev server**

   ```bash
   # Stop with Ctrl+C, then
   npm run dev
   ```

2. **Clear Next.js cache**

   ```bash
   rm -rf .next
   npm run dev
   ```

3. **Check file watchers limit (Linux)**
   ```bash
   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

### "Module not found" errors

**Problem**: Import paths not resolving

**Solutions**:

1. **Check alias configuration**

   - Verify `tsconfig.json` has correct paths
   - Ensure imports use `@/` prefix

2. **Restart TypeScript server**

   - VS Code: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"

3. **Reinstall dependencies**
   ```bash
   rm -rf node_modules .next
   npm install
   ```

---

## Build Issues

### Build fails with TypeScript errors

**Problem**: `npm run build` fails

**Solutions**:

1. **Check for errors**

   ```bash
   npm run typecheck
   ```

2. **Common fixes**:

   ```typescript
   // Add type assertions
   const value = something as SomeType;

   // Use optional chaining
   object?.property?.method?.();

   // Provide default values
   const val = maybeUndefined ?? defaultValue;
   ```

3. **Temporarily ignore (not recommended)**
   ```typescript
   // @ts-ignore
   problematicLine();
   ```

### Build succeeds but app crashes

**Problem**: Runtime errors in production

**Solutions**:

1. **Check environment variables**

   - Ensure all required variables are set
   - Use `NEXT_PUBLIC_` prefix for client-side vars

2. **Test production build locally**

   ```bash
   npm run build
   npm run start
   ```

3. **Check server logs**
   - Look for error messages
   - Verify API endpoints work

### Bundle size too large

**Problem**: Slow loading times

**Solutions**:

1. **Analyze bundle**

   ```bash
   npm install -D @next/bundle-analyzer
   ```

   Add to `next.config.ts`:

   ```typescript
   const withBundleAnalyzer = require("@next/bundle-analyzer")({
     enabled: process.env.ANALYZE === "true",
   });

   module.exports = withBundleAnalyzer(nextConfig);
   ```

   ```bash
   ANALYZE=true npm run build
   ```

2. **Use dynamic imports**

   ```typescript
   const Component = dynamic(() => import("@/components/Heavy"));
   ```

3. **Optimize images**
   - Use Next.js Image component
   - Compress images before importing

---

## AI/API Issues

### "Invalid API key" error

**Problem**: Google AI API key not working

**Solutions**:

1. **Verify API key**

   - Check `.env` file exists
   - Ensure variable name: `GOOGLE_GENAI_API_KEY`
   - No spaces or quotes around key

2. **Get new API key**

   - Visit [Google AI Studio](https://ai.google.dev/)
   - Create new API key
   - Update `.env` file

3. **Restart development server**
   ```bash
   # After updating .env
   npm run dev
   ```

### AI responses are slow

**Problem**: Long wait times for AI features

**Solutions**:

1. **Check API quota**

   - Visit Google Cloud Console
   - Review usage limits

2. **Optimize prompts**

   - Make prompts more concise
   - Reduce unnecessary context

3. **Add timeout handling**
   ```typescript
   const timeout = setTimeout(() => {
     console.error("Request timeout");
   }, 10000);
   ```

### "Failed to fetch" errors

**Problem**: Network errors calling AI APIs

**Solutions**:

1. **Check internet connection**
2. **Verify API endpoint**
3. **Check CORS settings**
4. **Review firewall/proxy settings**

---

## Webcam Issues

### Webcam permission denied

**Problem**: Browser doesn't allow webcam access

**Solutions**:

1. **Check browser permissions**

   - Click lock icon in address bar
   - Allow camera access
   - Refresh page

2. **Use HTTPS**

   - Webcam requires secure context
   - Use `localhost` or HTTPS in production

3. **Try different browser**
   - Chrome/Edge (recommended)
   - Firefox
   - Safari

### Webcam not detected

**Problem**: No camera found

**Solutions**:

1. **Check hardware**

   - Verify webcam is connected
   - Test in another app (Zoom, etc.)

2. **Check permissions**

   - Windows: Settings → Privacy → Camera
   - Mac: System Preferences → Security → Camera

3. **Update drivers** (Windows)

### Poor webcam quality

**Problem**: Blurry or low-quality feed

**Solutions**:

1. **Adjust lighting**

   - Use good lighting
   - Avoid backlighting

2. **Check webcam settings**
   ```typescript
   // In webcam-feed.tsx, adjust constraints
   const stream = await navigator.mediaDevices.getUserMedia({
     video: {
       width: { ideal: 1280 },
       height: { ideal: 720 },
       facingMode: "user",
     },
   });
   ```

---

## Performance Issues

### Slow page load

**Problem**: Long initial load time

**Solutions**:

1. **Enable production mode**

   ```bash
   npm run build
   npm run start
   ```

2. **Optimize images**

   - Use Next.js Image component
   - Compress images
   - Use appropriate formats (WebP)

3. **Code splitting**
   ```typescript
   const DynamicComponent = dynamic(() => import("@/components/Heavy"), {
     ssr: false,
   });
   ```

### High memory usage

**Problem**: Browser uses too much RAM

**Solutions**:

1. **Reduce history data points**

   ```typescript
   // In use-driver-monitoring.ts
   const MAX_HISTORY = 30; // Reduce from 50
   ```

2. **Clear old data**

   ```typescript
   // Implement data cleanup
   useEffect(() => {
     const cleanup = setInterval(() => {
       // Clear old alerts/history
     }, 60000);
     return () => clearInterval(cleanup);
   }, []);
   ```

3. **Close unused tabs**

### Chart rendering issues

**Problem**: Recharts not displaying correctly

**Solutions**:

1. **Check data format**

   ```typescript
   // Ensure proper data structure
   const data = history.map((point) => ({
     time: new Date(point.time).toLocaleTimeString(),
     dri: point.dri,
   }));
   ```

2. **Set explicit dimensions**
   ```typescript
   <ResponsiveContainer width="100%" height={300}>
     <LineChart data={data}>{/* ... */}</LineChart>
   </ResponsiveContainer>
   ```

---

## Browser Compatibility

### Voice warnings not working

**Problem**: Speech synthesis doesn't work

**Solutions**:

1. **Check browser support**

   ```typescript
   if ("speechSynthesis" in window) {
     // Supported
   } else {
     // Show text alert instead
   }
   ```

2. **Test voice manually**

   ```javascript
   // In browser console
   speechSynthesis.speak(new SpeechSynthesisUtterance("Test"));
   ```

3. **Fallback to text**
   - Display visual alerts
   - Use notification API

### Styling issues in Safari

**Problem**: CSS not rendering correctly

**Solutions**:

1. **Check CSS variables**

   - Ensure proper HSL format
   - Test in Safari

2. **Add vendor prefixes**
   ```css
   .element {
     -webkit-backdrop-filter: blur(10px);
     backdrop-filter: blur(10px);
   }
   ```

---

## Deployment Issues

### Build fails on Vercel/Firebase

**Problem**: Production build errors

**Solutions**:

1. **Test build locally**

   ```bash
   npm run build
   ```

2. **Check environment variables**

   - Verify all vars are set in platform
   - Check variable names (case-sensitive)

3. **Review build logs**
   - Look for specific error messages
   - Check dependencies installation

### App crashes after deployment

**Problem**: Runtime errors in production

**Solutions**:

1. **Check server logs**
2. **Verify API keys are set**
3. **Test with production build locally**
   ```bash
   npm run build && npm run start
   ```

---

## Getting Help

If you're still experiencing issues:

1. **Check existing issues** on GitHub
2. **Search documentation** for keywords
3. **Enable verbose logging**
   ```typescript
   console.log("Debug info:", data);
   ```
4. **Create a new issue** with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, browser, Node version)
   - Error messages/screenshots

---

## Common Error Messages

### "Cannot find module '@/...'"

- **Cause**: TypeScript path aliases not configured
- **Fix**: Check `tsconfig.json` paths configuration

### "Hydration failed"

- **Cause**: Server/client HTML mismatch
- **Fix**: Ensure consistent rendering, use `suppressHydrationWarning`

### "localStorage is not defined"

- **Cause**: Accessing browser APIs during SSR
- **Fix**: Use `useEffect` or check `typeof window !== 'undefined'`

### "Maximum call stack size exceeded"

- **Cause**: Infinite loop or recursion
- **Fix**: Review recent code changes, add guards

---

**Still need help? Open an issue on GitHub! 🙋‍♂️**

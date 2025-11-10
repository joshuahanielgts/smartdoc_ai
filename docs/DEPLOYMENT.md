# Deployment Guide

This guide covers deploying LucidDrive AI to various platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Firebase App Hosting](#firebase-app-hosting)
- [Vercel](#vercel)
- [Docker](#docker)
- [Environment Variables](#environment-variables)
- [Post-Deployment](#post-deployment)

---

## Prerequisites

Before deploying, ensure you have:

1. ✅ Google AI API key configured
2. ✅ All dependencies installed (`npm install`)
3. ✅ Production build passes (`npm run build`)
4. ✅ No TypeScript errors (`npm run typecheck`)
5. ✅ No linting errors (`npm run lint`)

---

## Firebase App Hosting

### Setup

1. **Install Firebase CLI**

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**

   ```bash
   firebase login
   ```

3. **Initialize Firebase (if not done)**

   ```bash
   firebase init apphosting
   ```

4. **Configure apphosting.yaml**

   The project already includes `apphosting.yaml`:

   ```yaml
   runConfig:
     maxInstances: 1 # Increase for production
   ```

5. **Set Environment Variables**
   ```bash
   firebase apphosting:secrets:set GOOGLE_GENAI_API_KEY
   ```

### Deploy

```bash
# Deploy to Firebase
firebase deploy --only apphosting

# Deploy with specific project
firebase deploy --only apphosting --project your-project-id
```

### Post-Deployment

1. Check logs: `firebase apphosting:logs`
2. Monitor in Firebase Console
3. Set up custom domain (optional)

---

## Vercel

### Method 1: GitHub Integration (Recommended)

1. **Push to GitHub**

   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Import to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Add New Project"
   - Import your GitHub repository
   - Configure environment variables
   - Deploy!

### Method 2: Vercel CLI

1. **Install Vercel CLI**

   ```bash
   npm install -g vercel
   ```

2. **Login**

   ```bash
   vercel login
   ```

3. **Deploy**

   ```bash
   # First deployment
   vercel

   # Production deployment
   vercel --prod
   ```

### Environment Variables in Vercel

1. Go to Project Settings
2. Navigate to "Environment Variables"
3. Add:
   - `GOOGLE_GENAI_API_KEY`
   - Any other Firebase variables

### Build Configuration

Vercel should auto-detect Next.js. If needed:

- **Build Command**: `npm run build`
- **Output Directory**: `.next`
- **Install Command**: `npm install`
- **Development Command**: `npm run dev`

---

## Docker

### Dockerfile

Create `Dockerfile` in project root:

```dockerfile
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1

RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 9002

ENV PORT=9002
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### Docker Compose

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  luciddrive:
    build: .
    ports:
      - "9002:9002"
    environment:
      - GOOGLE_GENAI_API_KEY=${GOOGLE_GENAI_API_KEY}
    restart: unless-stopped
```

### Build and Run

```bash
# Build image
docker build -t luciddrive-ai .

# Run container
docker run -p 9002:9002 \
  -e GOOGLE_GENAI_API_KEY=your_key_here \
  luciddrive-ai

# Or use docker-compose
docker-compose up -d
```

---

## Environment Variables

### Required Variables

```env
GOOGLE_GENAI_API_KEY=your_google_ai_api_key_here
```

### Optional Variables

```env
# Firebase (if using Firebase features)
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id

# Analytics (optional)
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX

# Sentry (optional)
SENTRY_DSN=your_sentry_dsn
```

### Setting Variables by Platform

**Vercel:**

- Project Settings → Environment Variables

**Firebase:**

```bash
firebase apphosting:secrets:set VARIABLE_NAME
```

**Docker:**

- Use `.env` file or pass with `-e` flag

---

## Post-Deployment

### Verify Deployment

1. **Test the Application**

   - Open deployed URL
   - Test webcam monitoring
   - Verify AI features work
   - Check voice warnings
   - Test dark mode

2. **Check Console for Errors**

   - Open browser DevTools
   - Look for API errors
   - Verify network requests

3. **Monitor Performance**
   - Check loading times
   - Verify API response times
   - Monitor memory usage

### Custom Domain Setup

**Vercel:**

1. Go to Project Settings → Domains
2. Add your custom domain
3. Update DNS records as instructed

**Firebase:**

1. Firebase Console → App Hosting
2. Add custom domain
3. Verify ownership
4. Update DNS

### SSL Certificate

Both Vercel and Firebase automatically provision SSL certificates.

### Performance Optimization

1. **Enable CDN**

   - Vercel Edge Network (automatic)
   - Firebase CDN (automatic)

2. **Image Optimization**

   - Already configured with Next.js Image component
   - Supports multiple image sources

3. **Caching**
   - Static assets cached automatically
   - API routes cached per configuration

---

## Monitoring

### Vercel

- **Analytics**: Built-in Web Analytics
- **Logs**: View in Vercel Dashboard
- **Performance**: Vercel Speed Insights

### Firebase

- **Logs**: Firebase Console → App Hosting → Logs
- **Monitoring**: Cloud Monitoring integration
- **Alerts**: Set up in Cloud Console

### Recommended Tools

- **Sentry**: Error tracking
- **LogRocket**: Session replay
- **Google Analytics**: User analytics
- **Uptime Robot**: Uptime monitoring

---

## Rollback

### Vercel

```bash
# List deployments
vercel ls

# Rollback to previous
vercel rollback [deployment-url]
```

### Firebase

```bash
# List versions
firebase apphosting:rollouts:list

# Rollback
firebase apphosting:rollback
```

---

## Troubleshooting

### Build Fails

1. Check build logs
2. Verify all dependencies installed
3. Run `npm run build` locally
4. Check TypeScript errors: `npm run typecheck`

### Environment Variables Not Working

1. Verify variable names (case-sensitive)
2. Restart deployment after adding variables
3. Check if variables need `NEXT_PUBLIC_` prefix

### API Errors

1. Verify Google AI API key is valid
2. Check API key has proper permissions
3. Review API quota limits
4. Check server logs for details

### Performance Issues

1. Enable production mode
2. Check image optimization
3. Review bundle size: `npm run build`
4. Consider increasing server resources

---

## Security Checklist

- [ ] Environment variables not committed to Git
- [ ] API keys stored securely
- [ ] HTTPS enabled (automatic)
- [ ] CORS configured properly
- [ ] Rate limiting configured (if needed)
- [ ] Security headers configured
- [ ] Dependencies updated regularly

---

## Next Steps

After successful deployment:

1. ✅ Set up monitoring
2. ✅ Configure custom domain
3. ✅ Enable analytics
4. ✅ Set up error tracking
5. ✅ Create backup strategy
6. ✅ Document deployment process
7. ✅ Train team on deployment

---

**Happy Deploying! 🚀**

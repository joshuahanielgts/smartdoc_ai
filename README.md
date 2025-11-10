# 🚗 LucidDrive AI

> **Drive Safe, Arrive Safe** - An advanced AI-powered driver monitoring system that detects fatigue in real-time and prevents accidents.

![React](https://img.shields.io/badge/React-18.3.1-blue)
![Vite](https://img.shields.io/badge/Vite-6.0-646CFF)
![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue)
![Firebase Genkit](https://img.shields.io/badge/Genkit-1.14.1-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Available Scripts](#available-scripts)
- [AI Flows](#ai-flows)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**LucidDrive AI** is an intelligent driver assistance system that uses webcam-based monitoring to detect signs of driver fatigue and drowsiness. By leveraging AI and real-time analysis, it provides instant alerts, personalized safety tips, and comprehensive session summaries to help drivers stay alert and safe on the road.

### Key Capabilities

- **Real-time Fatigue Detection**: Monitors driver behavior through webcam
- **Driver Risk Index (DRI)**: Calculates risk levels based on fatigue indicators
- **Smart Alerts**: AI-powered voice warnings using Web Speech API
- **Personalized Safety Tips**: Context-aware recommendations powered by Google Gemini AI
- **Session Analytics**: Comprehensive driving session summaries and insights
- **Risk Zone Prediction**: Identifies high-risk zones and accident-prone areas
- **Emergency SOS**: Quick access to emergency services when needed

---

## ✨ Features

### 🎥 Webcam Monitoring

- Real-time driver face detection
- Eye closure and yawning analysis
- Human presence verification

### 📊 Driver Risk Index (DRI)

- Dynamic risk calculation (0-100 scale)
- Visual DRI meter with color-coded warnings
- Historical DRI tracking and visualization

### 🚨 Real-time Alerts

- Intelligent alert system with cooldown periods
- Visual and audible warnings
- Context-aware alert messages

### 🎙️ Voice Assistant

- AI-generated voice warnings using Google Gemini
- Natural language alerts
- Web Speech API integration

### 📈 Analytics Dashboard

- Live DRI meter
- Historical trend charts using Recharts
- Alert logs with timestamps
- Session summaries

### 🤖 AI-Powered Features

- Personalized safety tips based on driving patterns
- Daily session summaries with key insights
- Predictive risk zone analysis
- Accident-prone zone identification

### 🎨 Modern UI/UX

- Dark mode with theme toggle
- Responsive design for all devices
- Glass-morphism effects
- 3D car visualization using Spline
- Smooth animations and transitions

---

## 🛠️ Tech Stack

### **Frontend Framework**

- **Next.js 15.3.3** - React framework with App Router
- **React 18.3.1** - UI library
- **TypeScript 5** - Type-safe JavaScript

### **Styling & UI**

- **Tailwind CSS 3.4.1** - Utility-first CSS framework
- **Radix UI** - Accessible component primitives
- **shadcn/ui** - Re-usable component collection
- **next-themes** - Dark mode support
- **Lucide React** - Beautiful icon library
- **Tailwind Animate** - Animation utilities

### **AI & Machine Learning**

- **Firebase Genkit 1.14.1** - AI orchestration framework
- **Google AI (Gemini 2.5 Flash)** - Large language model
- **@genkit-ai/googleai** - Google AI integration
- **@genkit-ai/next** - Next.js integration for Genkit

### **Data Visualization**

- **Recharts 2.15.1** - Charting library
- **Spline Viewer** - 3D visualization

### **Forms & Validation**

- **React Hook Form 7.54.2** - Form management
- **Zod 3.24.2** - Schema validation
- **@hookform/resolvers** - Resolver integration

### **Utilities**

- **date-fns 3.6.0** - Date manipulation
- **clsx & tailwind-merge** - Conditional styling
- **class-variance-authority** - Component variants
- **embla-carousel-react** - Carousel component

### **Development Tools**

- **Turbopack** - Fast bundler for Next.js
- **genkit-cli** - Genkit development tools
- **ESLint** - Code linting
- **PostCSS** - CSS processing

### **Deployment**

- **Firebase App Hosting** - Cloud deployment platform

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** 20.x or higher
- **npm** or **yarn** or **pnpm**
- **Google AI API Key** ([Get one here](https://ai.google.dev/))
- **Webcam** (for real-time monitoring)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/joshuahanielgts/lucid-drive.ai.git
   cd lucid-drive.ai
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Set up environment variables**

   Create a `.env` file in the root directory:

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` and add your Google AI API key:

   ```env
   GOOGLE_GENAI_API_KEY=your_google_ai_api_key_here
   ```

4. **Run the development server**

   ```bash
   npm run dev
   ```

5. **Open your browser**

   Navigate to [http://localhost:9002](http://localhost:9002)

### First-Time Setup

When you first run the application:

1. **Allow webcam access** when prompted by your browser
2. **Click "Start Monitoring"** to begin the driver monitoring session
3. The system will simulate fatigue detection patterns for demo purposes
4. **Click "Stop Monitoring"** to end the session and view a summary

---

## 📁 Project Structure

```
lucid-drive.ai/
├── docs/
│   └── blueprint.md              # Project design document
├── src/
│   ├── ai/
│   │   ├── genkit.ts             # Genkit AI configuration
│   │   ├── dev.ts                # Development server for Genkit
│   │   └── flows/                # AI flow definitions
│   │       ├── generate-daily-session-summaries.ts
│   │       ├── generate-personalized-safety-tips.ts
│   │       ├── generate-speech.ts
│   │       ├── get-accident-prone-zones.ts
│   │       ├── predict-high-risk-zones.ts
│   │       ├── provide-voice-assistant-warnings.ts
│   │       └── trigger-sos-alert.ts
│   ├── app/
│   │   ├── layout.tsx            # Root layout with theme provider
│   │   ├── page.tsx              # Main dashboard page
│   │   └── globals.css           # Global styles
│   ├── components/
│   │   ├── dashboard/            # Dashboard-specific components
│   │   │   ├── accident-prone-zones.tsx
│   │   │   ├── alert-log.tsx
│   │   │   ├── dashboard-header.tsx
│   │   │   ├── dri-history-chart.tsx
│   │   │   ├── dri-meter.tsx
│   │   │   ├── notification-center.tsx
│   │   │   ├── risk-zone-forecast.tsx
│   │   │   ├── safety-tips.tsx
│   │   │   ├── session-summary.tsx
│   │   │   └── webcam-feed.tsx
│   │   ├── ui/                   # shadcn/ui components
│   │   ├── icons.tsx             # Custom icon components
│   │   ├── theme-provider.tsx    # Theme context provider
│   │   └── theme-toggle.tsx      # Dark mode toggle
│   ├── hooks/
│   │   ├── use-driver-monitoring.ts  # Main monitoring logic
│   │   ├── use-mobile.tsx        # Mobile detection hook
│   │   └── use-toast.ts          # Toast notification hook
│   └── lib/
│       ├── actions.ts            # Server actions for AI flows
│       ├── types.ts              # TypeScript type definitions
│       └── utils.ts              # Utility functions
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
├── apphosting.yaml               # Firebase App Hosting config
├── components.json               # shadcn/ui configuration
├── next.config.ts                # Next.js configuration
├── package.json                  # Dependencies and scripts
├── postcss.config.mjs            # PostCSS configuration
├── tailwind.config.ts            # Tailwind CSS configuration
├── tsconfig.json                 # TypeScript configuration
└── README.md                     # This file
```

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Required: Google AI API Key
GOOGLE_GENAI_API_KEY=your_google_ai_api_key_here

# Optional: Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### Customizing DRI Thresholds

Edit `src/hooks/use-driver-monitoring.ts` to adjust monitoring parameters:

```typescript
const DRI_HIGH_THRESHOLD = 70; // Alert threshold
const SIMULATION_INTERVAL = 2000; // Update interval (ms)
const ALERT_COOLDOWN = 10000; // Time between alerts (ms)
const MAX_HISTORY = 50; // History data points
```

### Theme Customization

Modify `src/app/globals.css` to customize colors:

```css
:root {
  --background: 224 71.4% 4.1%;
  --foreground: 210 20% 98%;
  --primary: 223.5 83.8% 32.2%;
  /* Add more custom colors */
}
```

---

## 📜 Available Scripts

### Development

```bash
# Start Next.js development server with Turbopack
npm run dev

# Start Genkit development UI
npm run genkit:dev

# Start Genkit with watch mode
npm run genkit:watch
```

### Production

```bash
# Build for production
npm run build

# Start production server
npm run start
```

### Quality Checks

```bash
# Run ESLint
npm run lint

# Type check without emitting files
npm run typecheck
```

---

## 🤖 AI Flows

LucidDrive AI uses Firebase Genkit to orchestrate several AI-powered flows:

### 1. **Voice Assistant Warnings**

- **File**: `src/ai/flows/provide-voice-assistant-warnings.ts`
- **Purpose**: Generates contextual voice warnings based on DRI
- **Input**: Current DRI value
- **Output**: Natural language warning message

### 2. **Personalized Safety Tips**

- **File**: `src/ai/flows/generate-personalized-safety-tips.ts`
- **Purpose**: Creates personalized safety recommendations
- **Input**: DRI history, alert frequency
- **Output**: Tailored safety tips

### 3. **Daily Session Summaries**

- **File**: `src/ai/flows/generate-daily-session-summaries.ts`
- **Purpose**: Generates comprehensive session reports
- **Input**: Max DRI, average DRI, alert frequency, safety tips
- **Output**: Human-readable summary paragraph

### 4. **Speech Generation**

- **File**: `src/ai/flows/generate-speech.ts`
- **Purpose**: Converts text to speech (if implemented)
- **Input**: Text string
- **Output**: Audio data

### 5. **High Risk Zone Prediction**

- **File**: `src/ai/flows/predict-high-risk-zones.ts`
- **Purpose**: Predicts high-risk driving zones
- **Input**: Latitude, longitude
- **Output**: Emergency services nearby

### 6. **Accident Prone Zones**

- **File**: `src/ai/flows/get-accident-prone-zones.ts`
- **Purpose**: Identifies accident-prone areas
- **Input**: Latitude, longitude
- **Output**: List of high-risk zones

### 7. **SOS Alert Trigger**

- **File**: `src/ai/flows/trigger-sos-alert.ts`
- **Purpose**: Sends emergency alerts
- **Input**: Driver ID, location
- **Output**: Alert confirmation

---

## 🎨 Design System

### Color Palette

- **Primary (Midnight Blue)**: `#2C3E50` - Focus and safety
- **Background (Dark Gray)**: `#34495E` - Minimal distraction
- **Accent (Sky Blue)**: `#3498DB` - Interactive elements
- **Success (Green)**: Low DRI indicators
- **Warning (Yellow)**: Medium DRI indicators
- **Danger (Red)**: High DRI alerts

### Typography

- **Font Family**: Inter (sans-serif)
- **Headings**: Inter with various weights
- **Body Text**: Inter Regular
- **Code**: Monospace

### Components

All UI components follow the shadcn/ui design system with Radix UI primitives for accessibility.

---

## 🚢 Deployment

### Firebase App Hosting

This project is configured for Firebase App Hosting deployment:

1. **Install Firebase CLI**

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**

   ```bash
   firebase login
   ```

3. **Initialize Firebase**

   ```bash
   firebase init apphosting
   ```

4. **Deploy**
   ```bash
   firebase deploy
   ```

### Vercel Deployment

Alternatively, deploy to Vercel:

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel
```

### Environment Variables

Don't forget to add your environment variables in your deployment platform's settings!

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Code Style

- Follow the existing TypeScript/React patterns
- Use ESLint and Prettier for formatting
- Write meaningful commit messages
- Add comments for complex logic

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Google Gemini AI** - For powerful AI capabilities
- **Firebase Genkit** - For AI orchestration
- **shadcn/ui** - For beautiful UI components
- **Radix UI** - For accessible primitives
- **Next.js Team** - For the amazing framework
- **Vercel** - For hosting and infrastructure

---

## 📞 Support

For support, please:

- Open an issue on GitHub
- Contact: joshuahanielgts@gmail.com
- Check the [documentation](docs/blueprint.md)

---

## 🗺️ Roadmap

- [ ] Integrate real MediaPipe for actual face detection
- [ ] Add user authentication and profiles
- [ ] Implement data persistence with Firebase
- [ ] Mobile app (React Native)
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Integration with vehicle systems
- [ ] Cloud-based trip history
- [ ] Social features (share safety tips)
- [ ] Insurance integration

---

**Made with ❤️ by the LucidDrive AI Team**

**Drive Safe, Arrive Safe** 🚗💨

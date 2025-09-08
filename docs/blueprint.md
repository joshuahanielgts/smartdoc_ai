# **App Name**: DriveSafe AI

## Core Features:

- Webcam Monitoring: Use MediaPipe to monitor driver's face for signs of fatigue (eye closure, yawning).
- Driver Risk Index (DRI) Calculation: Compute a DRI based on fatigue signs detected by the webcam. DRI increases with fatigue.
- Real-time Alerts: Send instant alerts (visual/audible) when the DRI exceeds a threshold, indicating drowsiness.
- Driver Dashboard: Display live DRI meter, recent history graph, and alert logs.
- Personalized Safety Tips: Use Gemini API to generate personalized safety tips based on stored driving data (DRI history, alerts).
- Daily Session Summaries: Generate daily session summaries using Gemini, including key stats (max DRI, alert frequency) and safety advice.
- Voice Assistant Warnings: Use Web Speech API to speak out warnings when drowsiness is detected. The LLM will act as a tool, intelligently and proactively deciding when to say phrases like 'Please take a break'.

## Style Guidelines:

- Primary color: Midnight Blue (#2C3E50) to convey a sense of focus and safety.
- Background color: Dark Gray (#34495E) to minimize distraction and eye strain.
- Accent color: Sky Blue (#3498DB) for interactive elements and alerts.
- Body and headline font: 'Inter', a sans-serif font, for readability and a modern, neutral look.
- Use simple, clear icons to represent different data points and alerts.
- Dashboard should have a clear, intuitive layout, with key data points prominently displayed.
- Use subtle animations to provide feedback and guide the user's attention.
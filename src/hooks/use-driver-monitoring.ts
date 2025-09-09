'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { getVoiceWarning, getSafetyTips } from '@/lib/actions';
import type { DriHistoryPoint, Alert, AlertContext } from '@/lib/types';

const DRI_HIGH_THRESHOLD = 70;
const SIMULATION_INTERVAL = 1500; // 1.5 seconds for faster reaction in demo
const ALERT_COOLDOWN = 10000; // 10 seconds
const MAX_HISTORY = 50;

// This object will hold the state of our simulation
const simState = {
  // Simulates if the driver's eyes are closed (drowsy)
  isDrowsy: false,
  // A counter to control when the driver becomes drowsy or wakes up
  drowsinessCounter: 0,
  // How many ticks until the state changes
  ticksUntilChange: 10,
};

export function useDriverMonitoring(isMonitoring: boolean) {
  const [dri, setDri] = useState(0);
  const [isHumanPresent, setIsHumanPresent] = useState(true);
  const [history, setHistory] = useState<DriHistoryPoint[]>([{ time: Date.now(), dri: 0 }]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const alertContextMap = useRef(new Map<string, AlertContext>());
  const lastAlertTimestamp = useRef<number>(0);
  const intervalIdRef = useRef<NodeJS.Timeout | null>(null);

  const speak = (text: string) => {
    if ('speechSynthesis' in window && text) {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 0.9;
      utterance.pitch = 0.9;
      window.speechSynthesis.speak(utterance);
    }
  };

  const handleHighDri = useCallback(async (currentDri: number, currentHistory: DriHistoryPoint[]) => {
    const now = Date.now();
    if (now - lastAlertTimestamp.current < ALERT_COOLDOWN) {
      return;
    }
    lastAlertTimestamp.current = now;

    const alertId = `alert-${now}`;
    const newAlert: Alert = { id: alertId, time: now, message: 'Fatigue detected', dri: currentDri };
    setAlerts(prev => [newAlert, ...prev]);

    try {
      const driHistoryStr = currentHistory.map(p => p.dri).join(',');
      const safetyTipsResult = await getSafetyTips(driHistoryStr, alerts.length + 1);
      const safetyTips = safetyTipsResult || 'Stay alert and drive safe.';
      
      alertContextMap.current.set(alertId, {
        history: currentHistory,
        safetyTip: safetyTips.split('\n')[0],
      });

      const warning = await getVoiceWarning(currentDri);
      speak(warning);

    } catch (error) {
      console.error('Failed to get voice warning or safety tips:', error);
      speak('High risk detected. Please take a break now.');
    }
  }, [alerts.length]);

  const runSimulation = useCallback(() => {
    // For the demo, we will always assume the human is present.
    // This avoids the "No human present" bug during your presentation.
    setIsHumanPresent(true);

    simState.drowsinessCounter++;

    // Check if it's time to toggle the drowsiness state
    if (simState.drowsinessCounter >= simState.ticksUntilChange) {
      simState.isDrowsy = !simState.isDrowsy;
      simState.drowsinessCounter = 0;
      // Randomize the next change time to feel more natural
      simState.ticksUntilChange = simState.isDrowsy ? 5 : 10; // Be drowsy for a shorter time
    }

    setDri(prevDri => {
      let newDri;
      if (simState.isDrowsy) {
        // EYES CLOSED: DRI increases sharply towards a high value
        newDri = prevDri + (20 + Math.random() * 10);
        newDri = Math.min(newDri, 85 + Math.random() * 10); // Cap near 95
      } else {
        // EYES OPEN: DRI decreases sharply towards a low value
        newDri = prevDri - (30 + Math.random() * 10);
        newDri = Math.max(newDri, 5 + Math.random() * 10); // Floor near 5
      }
      
      const finalDri = Math.max(0, Math.min(100, Math.round(newDri)));

      let updatedHistory: DriHistoryPoint[] = [];
      setHistory(prevHistory => {
        // Ensure history doesn't grow indefinitely
        const newHistory = [...prevHistory, { time: Date.now(), dri: finalDri }];
        if (newHistory.length > MAX_HISTORY) {
          updatedHistory = newHistory.slice(newHistory.length - MAX_HISTORY);
        } else {
          updatedHistory = newHistory;
        }
        return updatedHistory;
      });

      if (finalDri > DRI_HIGH_THRESHOLD) {
          handleHighDri(finalDri, updatedHistory);
      }
      
      return finalDri;
    });
  }, [handleHighDri]);

  const startMonitoring = useCallback(() => {
    if (intervalIdRef.current) return;
    
    // Reset simulation state
    simState.isDrowsy = false;
    simState.drowsinessCounter = 0;
    simState.ticksUntilChange = 10; // Start with a longer period of being alert
    
    // Reset UI state
    setDri(0);
    setHistory([{ time: Date.now(), dri: 0 }]);
    setAlerts([]);
    alertContextMap.current.clear();
    setIsHumanPresent(true);
    lastAlertTimestamp.current = 0;
    
    // Start the simulation loop
    intervalIdRef.current = setInterval(runSimulation, SIMULATION_INTERVAL);
  }, [runSimulation]);

  const stopMonitoring = useCallback(() => {
    if (intervalIdRef.current) {
      clearInterval(intervalIdRef.current);
      intervalIdRef.current = null;
    }
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
    }
  }, []);
  
  const getAlertContext = useCallback((alertId: string) => {
    return alertContextMap.current.get(alertId);
  }, []);

  useEffect(() => {
    if (isMonitoring) {
        startMonitoring();
    } else {
      stopMonitoring();
    }
    // Cleanup on unmount
    return stopMonitoring;
  }, [isMonitoring, startMonitoring, stopMonitoring]);

  return { dri, history, alerts, isHumanPresent, startMonitoring, stopMonitoring, getAlertContext };
}

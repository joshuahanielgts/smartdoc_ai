'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { getVoiceWarning, getSafetyTips } from '@/lib/actions';
import type { DriHistoryPoint, Alert, AlertContext } from '@/lib/types';

const DRI_HIGH_THRESHOLD = 70;
const SIMULATION_INTERVAL = 2000; // 2 seconds
const ALERT_COOLDOWN = 10000; // 10 seconds
const MAX_HISTORY = 50;

// This object will hold the state of our simulation
const simState = {
  // Simulates if the driver's eyes are closed (drowsy)
  isDrowsy: false,
  // A counter to control when the driver becomes drowsy or wakes up
  drowsinessCounter: 0,
  // How many ticks until the state changes
  ticksUntilChange: 8, // Start with a longer alert period
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
    setIsHumanPresent(true); // For demo, always assume user is present.
    simState.drowsinessCounter++;

    if (simState.drowsinessCounter >= simState.ticksUntilChange) {
      simState.isDrowsy = !simState.isDrowsy;
      simState.drowsinessCounter = 0;
      // Be drowsy for a shorter time (e.g., 3 ticks = 6s)
      // Be alert for a longer time (e.g., 8 ticks = 16s)
      simState.ticksUntilChange = simState.isDrowsy ? 3 : 8; 
    }

    let newDri;
    if (simState.isDrowsy) {
      // EYES CLOSED: Set DRI to a high value directly
      newDri = 80 + Math.floor(Math.random() * 15); // e.g., 80-94
    } else {
      // EYES OPEN: Set DRI to a low value directly
      newDri = 5 + Math.floor(Math.random() * 15); // e.g., 5-19
    }
    
    setDri(newDri);

    let updatedHistory: DriHistoryPoint[] = [];
    setHistory(prevHistory => {
      const newHistory = [...prevHistory, { time: Date.now(), dri: newDri }];
      if (newHistory.length > MAX_HISTORY) {
        updatedHistory = newHistory.slice(newHistory.length - MAX_HISTORY);
      } else {
        updatedHistory = newHistory;
      }
      return updatedHistory;
    });

    if (newDri > DRI_HIGH_THRESHOLD) {
        handleHighDri(newDri, updatedHistory);
    }

  }, [handleHighDri]);

  const startMonitoring = useCallback(() => {
    if (intervalIdRef.current) return;
    
    // Reset simulation state
    simState.isDrowsy = false;
    simState.drowsinessCounter = 0;
    simState.ticksUntilChange = 8;
    
    // Reset UI state
    setDri(0);
    setHistory([{ time: Date.now(), dri: 0 }]);
    setAlerts([]);
    alertContextMap.current.clear();
    setIsHumanPresent(true);
    lastAlertTimestamp.current = 0;
    
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
    return stopMonitoring; // Cleanup on unmount
  }, [stopMonitoring]);

  return { dri, history, alerts, isHumanPresent, startMonitoring, stopMonitoring, getAlertContext };
}

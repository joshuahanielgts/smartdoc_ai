'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { getVoiceWarning } from '@/lib/actions';
import type { DriHistoryPoint, Alert } from '@/lib/types';

const DRI_THRESHOLD = 70;
const SIMULATION_INTERVAL = 1500; // 1.5 seconds
const ALERT_COOLDOWN = 30000; // 30 seconds
const MAX_HISTORY = 50;

// State to simulate drowsiness behavior
const simState = {
  isDrowsy: false,
  drowsinessChance: 0.1,
  wakeUpChance: 0.2,
};

export function useDriverMonitoring(isMonitoring: boolean) {
  const [dri, setDri] = useState(0);
  const [history, setHistory] = useState<DriHistoryPoint[]>([{ time: Date.now(), dri: 0 }]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const lastAlertTimestamp = useRef<number>(0);
  const intervalIdRef = useRef<NodeJS.Timeout | null>(null);

  const speak = (text: string) => {
    if ('speechSynthesis' in window && text) {
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 0.9;
      utterance.pitch = 0.9;
      window.speechSynthesis.speak(utterance);
    }
  };

  const handleHighDri = async (currentDri: number) => {
    const now = Date.now();
    if (now - lastAlertTimestamp.current < ALERT_COOLDOWN) {
      return;
    }
    lastAlertTimestamp.current = now;

    const alertId = `alert-${now}`;
    setAlerts((prev) => [{ id: alertId, time: now, message: `High drowsiness detected.`, dri: currentDri }, ...prev]);
    
    try {
      const warning = await getVoiceWarning(currentDri);
      speak(warning);
    } catch (error) {
      console.error('Failed to get voice warning:', error);
      speak('High risk detected. Please be careful.');
    }
  };

  const runSimulation = useCallback(() => {
    setDri(prevDri => {
      let newDri = prevDri;

      // Decide if the driver is getting drowsy or waking up
      if (!simState.isDrowsy && Math.random() < simState.drowsinessChance) {
        simState.isDrowsy = true;
      } else if (simState.isDrowsy && Math.random() < simState.wakeUpChance) {
        simState.isDrowsy = false;
      }

      // Adjust DRI based on drowsiness state
      if (simState.isDrowsy) {
        // If drowsy, DRI climbs. This simulates eyes closing more.
        const increase = Math.random() * 15;
        newDri += increase;
      } else {
        // If not drowsy, DRI falls. This simulates eyes are open and alert.
        const decrease = Math.random() * 10;
        newDri -= decrease;
      }
      
      // Clamp DRI between 0 and 100
      newDri = Math.max(0, Math.min(100, newDri));
      const finalDri = Math.round(newDri);

      setHistory((prevHistory) => {
          const newHistory = [...prevHistory, { time: Date.now(), dri: finalDri }];
          if (newHistory.length > MAX_HISTORY) {
              return newHistory.slice(newHistory.length - MAX_HISTORY);
          }
          return newHistory;
      });

      if (finalDri > DRI_THRESHOLD) {
          handleHighDri(finalDri);
      }
      
      return finalDri;
    });
  }, []);

  const startMonitoring = useCallback(() => {
    if (intervalIdRef.current) return;
    simState.isDrowsy = false; // Reset simulation state
    setHistory([{ time: Date.now(), dri: 0 }]);
    setAlerts([]);
    setDri(0);
    intervalIdRef.current = setInterval(runSimulation, SIMULATION_INTERVAL);
  }, [runSimulation]);

  const stopMonitoring = useCallback(() => {
    if (intervalIdRef.current) {
      clearInterval(intervalIdRef.current);
      intervalIdRef.current = null;
    }
  }, []);

  useEffect(() => {
    if (!isMonitoring) {
      stopMonitoring();
    }
  }, [isMonitoring, stopMonitoring]);

  return { dri, history, alerts, startMonitoring, stopMonitoring };
}

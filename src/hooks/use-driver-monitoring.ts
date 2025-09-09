'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { getVoiceWarning, getSafetyTips } from '@/lib/actions';
import type { DriHistoryPoint, Alert, AlertContext } from '@/lib/types';

const DRI_THRESHOLD = 70;
const SIMULATION_INTERVAL = 2000; // 2 seconds
const ALERT_COOLDOWN = 15000; // 15 seconds
const MAX_HISTORY = 50;

const simState = {
  isDrowsy: false,
  drowsinessChance: 0.1,
  wakeUpChance: 0.3,
};

export function useDriverMonitoring(isMonitoring: boolean) {
  const [dri, setDri] = useState(0);
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
      const safetyTips = await getSafetyTips(driHistoryStr, alerts.length + 1);
      
      alertContextMap.current.set(alertId, {
        history: currentHistory,
        safetyTip: safetyTips.split('\n')[0] || 'Stay alert and drive safe.',
      });

      const warning = await getVoiceWarning(currentDri);
      speak(warning);

    } catch (error) {
      console.error('Failed to get voice warning or safety tips:', error);
      speak('High risk detected. Please take a break now.');
    }
  }, [alerts.length]);

  const runSimulation = useCallback(() => {
    if (!simState.isDrowsy && Math.random() < simState.drowsinessChance) {
      simState.isDrowsy = true;
    } else if (simState.isDrowsy && Math.random() < simState.wakeUpChance) {
      simState.isDrowsy = false;
    }

    setDri(prevDri => {
      let newDri;
      if (simState.isDrowsy) {
        newDri = 75 + Math.random() * 20;
      } else {
        newDri = 5 + Math.random() * 20;
      }
      
      newDri = Math.max(0, Math.min(100, newDri));
      const finalDri = Math.round(newDri);

      let updatedHistory: DriHistoryPoint[] = [];
      setHistory(prevHistory => {
        updatedHistory = [...prevHistory, { time: Date.now(), dri: finalDri }];
        if (updatedHistory.length > MAX_HISTORY) {
          return updatedHistory.slice(updatedHistory.length - MAX_HISTORY);
        }
        return updatedHistory;
      });

      if (finalDri > DRI_THRESHOLD) {
          handleHighDri(finalDri, updatedHistory);
      }
      
      return finalDri;
    });
  }, [handleHighDri]);

  const startMonitoring = useCallback(() => {
    if (intervalIdRef.current) return;
    simState.isDrowsy = false;
    setHistory([{ time: Date.now(), dri: 0 }]);
    setAlerts([]);
    alertContextMap.current.clear();
    setDri(0);
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
    if (isMonitoring) {
        startMonitoring();
    } else {
      stopMonitoring();
    }
    return stopMonitoring;
  }, [isMonitoring, startMonitoring, stopMonitoring]);

  return { dri, history, alerts, startMonitoring, stopMonitoring, getAlertContext };
}

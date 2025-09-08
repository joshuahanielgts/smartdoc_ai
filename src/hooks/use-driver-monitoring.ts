'use client';

import { useState, useEffect, useRef } from 'react';
import { useToast } from '@/hooks/use-toast';
import { getVoiceWarning } from '@/lib/actions';
import type { DriHistoryPoint, Alert } from '@/lib/types';

const DRI_THRESHOLD = 70;
const SIMULATION_INTERVAL = 3000; // 3 seconds
const ALERT_COOLDOWN = 30000; // 30 seconds
const MAX_HISTORY = 50;

// Simplified levels
const LOW_RISK = 25;
const MODERATE_RISK = 50;
const HIGH_RISK = 80;

const riskLevels = [LOW_RISK, MODERATE_RISK, HIGH_RISK];

export function useDriverMonitoring() {
  const [dri, setDri] = useState(LOW_RISK);
  const [history, setHistory] = useState<DriHistoryPoint[]>([{ time: Date.now(), dri: LOW_RISK }]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const lastAlertTimestamp = useRef<number>(0);
  const { toast } = useToast();

  useEffect(() => {
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

      const message = `High drowsiness detected! DRI: ${currentDri}. Please take a break.`;
      const alertId = `alert-${now}`;

      setAlerts((prev) => [{ id: alertId, time: now, message: `High drowsiness detected.`, dri: currentDri }, ...prev]);
      
      toast({
        variant: 'destructive',
        title: 'Drowsiness Alert!',
        description: `Your DRI is ${currentDri}. Please consider pulling over.`,
      });
      
      try {
        const warning = await getVoiceWarning(currentDri);
        speak(warning);
      } catch (error) {
        console.error("Failed to get voice warning:", error);
        speak("High risk detected. Please be careful.");
      }
    };

    const intervalId = setInterval(() => {
      // jump between levels
      const newDri = riskLevels[Math.floor(Math.random() * riskLevels.length)];
        
      setDri(newDri);

      setHistory((prevHistory) => {
        const newHistory = [...prevHistory, { time: Date.now(), dri: newDri }];
        if (newHistory.length > MAX_HISTORY) {
          return newHistory.slice(newHistory.length - MAX_HISTORY);
        }
        return newHistory;
      });

      if (newDri > DRI_THRESHOLD) {
        handleHighDri(newDri);
      }

    }, SIMULATION_INTERVAL);

    return () => clearInterval(intervalId);
  }, [toast]);

  return { dri, history, alerts };
}

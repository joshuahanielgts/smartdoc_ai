'use client';

import { useState, useEffect, useRef } from 'react';
import { useToast } from '@/hooks/use-toast';
import { getVoiceWarning } from '@/lib/actions';
import type { DriHistoryPoint, Alert } from '@/lib/types';

const DRI_THRESHOLD = 70;
const SIMULATION_INTERVAL = 3000; // 3 seconds
const ALERT_COOLDOWN = 30000; // 30 seconds
const MAX_HISTORY = 50;

export function useDriverMonitoring() {
  const [dri, setDri] = useState(25);
  const [history, setHistory] = useState<DriHistoryPoint[]>([{ time: Date.now(), dri: 25 }]);
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
      setDri((prevDri) => {
        let change = (Math.random() - 0.4) * 10;
        if (prevDri > 60) {
            change = (Math.random() - 0.3) * 15; // More likely to increase
        }
        const newDri = Math.min(100, Math.max(0, Math.round(prevDri + change)));
        
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

        return newDri;
      });
    }, SIMULATION_INTERVAL);

    return () => clearInterval(intervalId);
  }, [toast]);

  return { dri, history, alerts };
}

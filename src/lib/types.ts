export type DriHistoryPoint = {
  time: number;
  dri: number;
};

export type Alert = {
  id: string;
  time: number;
  message: string;
  dri: number;
};

export type AlertContext = {
  history: DriHistoryPoint[];
  safetyTip: string;
};

export type EmergencyService = {
  name: string;
  type: 'Hospital' | 'Police Station';
  address: string;
  phone: string;
  mapsUrl: string;
};

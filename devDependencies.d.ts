/// <reference types="node" />

declare module 'wav' {
  import { Transform } from 'stream';

  export class Writer extends Transform {
    constructor(options?: WriterOptions);
  }

  export interface WriterOptions {
    channels?: number;
    sampleRate?: number;
    bitDepth?: number;
    format?: 'lpcm' | 'alaw' | 'ulaw';
    endianness?: 'LE' | 'BE';
  }

  export class Reader extends Transform {
    constructor(options?: any);
    on(event: 'format', listener: (format: any) => void): this;
    on(event: string, listener: (...args: any[]) => void): this;
  }
}

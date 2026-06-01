import posthog from 'posthog-js';

const POSTHOG_KEY = import.meta.env.VITE_POSTHOG_KEY || 'phc_mock';
const POSTHOG_HOST = import.meta.env.VITE_POSTHOG_HOST || 'https://app.posthog.com';

export const initPostHog = () => {
  if (POSTHOG_KEY === 'phc_mock') {
    console.log('[Mock Analytics] PostHog initialized');
    return;
  }
  posthog.init(POSTHOG_KEY, {
    api_host: POSTHOG_HOST,
    capture_pageview: false,
  });
};

export const trackWebEvent = (event: string, properties: any = {}) => {
  if (POSTHOG_KEY === 'phc_mock') {
    console.log(`[Mock Analytics] Web Event Tracked: ${event}`, properties);
    return;
  }
  posthog.capture(event, properties);
};

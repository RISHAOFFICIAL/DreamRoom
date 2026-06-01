import { PostHog } from 'posthog-node';
import dotenv from 'dotenv';

dotenv.config();

const client = new PostHog(
  process.env.POSTHOG_API_KEY || 'phc_mock',
  { host: 'https://app.posthog.com' }
);

export const trackEvent = (userId: string, event: string, properties: any = {}) => {
  if (!process.env.POSTHOG_API_KEY) {
    console.log(`[Mock Analytics] Tracked: ${event}`, { userId, ...properties });
    return;
  }
  client.capture({
    distinctId: userId,
    event,
    properties,
  });
};

export const shutdownAnalytics = async () => {
  client.shutdown();
};

/**
 * Unleash Feature Flag Configuration
 * 
 * This file demonstrates how to integrate Unleash feature flags
 * into the React application for controlled feature rollouts.
 */

export interface UnleashConfig {
  url: string;
  clientKey: string;
  environment: string;
  appName: string;
}

// Environment-specific Unleash configuration
export const unleashConfig: UnleashConfig = {
  url: process.env.REACT_APP_UNLEASH_URL || 'http://localhost:4242/api',
  clientKey: process.env.REACT_APP_UNLEASH_CLIENT_KEY || 'default:development.unleash-insecure-frontend-api-token',
  environment: process.env.NODE_ENV || 'development',
  appName: 'frankenstein-frontend',
};

// Feature flag names (centralized for consistency)
export const FeatureFlags = {
  // UI/UX Features
  DARK_MODE: 'dark-mode-toggle',
  NEW_DASHBOARD: 'new-dashboard-design',
  ADVANCED_FILTERS: 'advanced-product-filters',
  
  // Business Features  
  PREMIUM_FEATURES: 'premium-user-features',
  BETA_CHECKOUT: 'beta-checkout-flow',
  SOCIAL_LOGIN: 'social-login-enabled',
  
  // A/B Testing
  BUTTON_COLOR_TEST: 'button-color-ab-test',
  LANDING_PAGE_VARIANT: 'landing-page-variant',
  
  // Performance Features
  LAZY_LOADING: 'component-lazy-loading',
  VIRTUAL_SCROLLING: 'virtual-list-scrolling',
  
  // Experimental Features
  AI_RECOMMENDATIONS: 'ai-product-recommendations',
  REAL_TIME_NOTIFICATIONS: 'real-time-push-notifications',
} as const;

// User context for targeting
export interface UserContext {
  userId: string;
  email?: string;
  userRole?: 'user' | 'admin' | 'premium';
  country?: string;
  registrationDate?: Date;
  isPremium?: boolean;
}

// Feature flag variants (for A/B testing)
export interface FeatureVariant {
  name: string;
  payload?: {
    type: 'string' | 'number' | 'json';
    value: string;
  };
}

// Example usage in components:
/*
import { useFlag, useVariant } from '@unleash/proxy-client-react';
import { FeatureFlags } from './lib/unleash-config';

function MyComponent() {
  const darkModeEnabled = useFlag(FeatureFlags.DARK_MODE);
  const buttonVariant = useVariant(FeatureFlags.BUTTON_COLOR_TEST);
  
  return (
    <div className={darkModeEnabled ? 'dark-theme' : 'light-theme'}>
      <button 
        style={{ 
          backgroundColor: buttonVariant.payload?.value || 'blue' 
        }}
      >
        Click me!
      </button>
    </div>
  );
}
*/

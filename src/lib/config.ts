// Runtime configuration from Cloud Run environment variables
const getRuntimeConfig = () => {
  if (typeof window !== 'undefined' && (window as any).__CONFIG__) {
    return (window as any).__CONFIG__;
  }
  return {};
};

const runtimeConfig = getRuntimeConfig();

export const appConfig = {
  apiBaseUrl:
    runtimeConfig.apiBaseUrl ||
    process.env.VITE_API_BASE_URL?.replace(/\/$/, '') ||
    'http://localhost:8080/api',
  backendBaseUrl:
    runtimeConfig.backendBaseUrl ||
    process.env.VITE_BACKEND_BASE_URL?.replace(/\/$/, '') ||
    (process.env.VITE_API_BASE_URL?.replace(/\/$/, '') ?? 'http://localhost:8080/api').replace(
      /\/api$/,
      ''
    ),
  paymentMode: runtimeConfig.paymentMode || process.env.VITE_PAYMENT_MODE || 'fake',
  razorpayKeyId:
    runtimeConfig.razorpayKeyId || process.env.VITE_RAZORPAY_KEY_ID || 'rzp_test_key',
  enableQaTools: runtimeConfig.enableQaTools || process.env.VITE_ENABLE_QA_TOOLS === 'true'
} as const;

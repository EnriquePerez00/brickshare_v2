/**
 * Contratos de Edge Functions (Supabase).
 * Usado por web e iOS para invocar las mismas funciones.
 */

/** create-subscription-intent */
export interface CreateSubscriptionIntentBody {
  plan: string;
  userId: string;
  priceId: string;
}

/** change-subscription */
export interface ChangeSubscriptionBody {
  userId: string;
  plan?: string;
  priceId?: string;
}

/** correos-logistics */
export type CorreosLogisticsAction =
  | 'return_preregister'
  | string; // otras acciones según uso (ej. cancel, get_label)
export interface CorreosLogisticsBody {
  action: CorreosLogisticsAction;
  p_envios_id?: string;
  [key: string]: unknown;
}

/** correos-pudo */
export interface CorreosPudoBody {
  lat: number;
  lng: number;
  radius?: number;
}

/** add-lego-set */
export interface AddLegoSetBody {
  set_ref: string;
  action: 'preview' | 'add' | string;
}

/** process-assignment-payment */
export interface ProcessAssignmentPaymentBody {
  envio_id: string;
  [key: string]: unknown;
}

/** submit-donation */
export interface SubmitDonationBody {
  amount: number;
  email?: string;
  message?: string;
  [key: string]: unknown;
}

/** fetch-lego-data */
export interface FetchLegoDataBody {
  set_number: string;
}

/** send-email (interno) */
export interface SendEmailBody {
  to: string;
  subject: string;
  html: string;
  from?: string;
}

/** delete-user */
// Sin body; usa JWT del cliente.

export const EDGE_FUNCTIONS = {
  CREATE_SUBSCRIPTION_INTENT: 'create-subscription-intent',
  CHANGE_SUBSCRIPTION: 'change-subscription',
  CREATE_CHECKOUT_SESSION: 'create-checkout-session',
  CORREOS_LOGISTICS: 'correos-logistics',
  CORREOS_PUDO: 'correos-pudo',
  ADD_LEGO_SET: 'add-lego-set',
  PROCESS_ASSIGNMENT_PAYMENT: 'process-assignment-payment',
  SUBMIT_DONATION: 'submit-donation',
  FETCH_LEGO_DATA: 'fetch-lego-data',
  SEND_EMAIL: 'send-email',
  DELETE_USER: 'delete-user',
} as const;

/**
 * Contratos de Edge Functions (Supabase).
 * Usado por web e iOS para invocar las mismas funciones.
 */
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
};

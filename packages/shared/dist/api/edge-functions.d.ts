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
export type CorreosLogisticsAction = 'return_preregister' | string;
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
export declare const EDGE_FUNCTIONS: {
    readonly CREATE_SUBSCRIPTION_INTENT: "create-subscription-intent";
    readonly CHANGE_SUBSCRIPTION: "change-subscription";
    readonly CREATE_CHECKOUT_SESSION: "create-checkout-session";
    readonly CORREOS_LOGISTICS: "correos-logistics";
    readonly CORREOS_PUDO: "correos-pudo";
    readonly ADD_LEGO_SET: "add-lego-set";
    readonly PROCESS_ASSIGNMENT_PAYMENT: "process-assignment-payment";
    readonly SUBMIT_DONATION: "submit-donation";
    readonly FETCH_LEGO_DATA: "fetch-lego-data";
    readonly SEND_EMAIL: "send-email";
    readonly DELETE_USER: "delete-user";
};
//# sourceMappingURL=edge-functions.d.ts.map
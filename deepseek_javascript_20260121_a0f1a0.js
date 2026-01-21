// Log payment events to analytics
function trackPaymentEvent(event, properties) {
    // Send to Supabase for analytics
    supabase
        .from('analytics_events')
        .insert({
            event_name: `payment_${event}`,
            properties: properties,
            user_id: currentUser?.id,
            created_at: new Date().toISOString()
        })
        .then(({ error }) => {
            if (error) console.error('Analytics error:', error);
        });
}

// Use in payment flow
trackPaymentEvent('initiated', { amount: 289.99 });
trackPaymentEvent('completed', { chargeId: result.chargeId });
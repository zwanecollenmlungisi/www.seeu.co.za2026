// Updated frontend payment processing
async function processPaymentOnServer(token, amountInCents) {
    const serverEndpoint = `https://${SUPABASE_URL}/functions/v1/process-yoco-payment`;
    
    // Get user's JWT token for authentication
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
        throw new Error('Not authenticated');
    }

    const payload = {
        token: token,
        amountInCents: amountInCents,
        userId: currentUser.id,
        userEmail: currentProfile.email
    };

    const response = await fetch(serverEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
        },
        body: JSON.stringify(payload)
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Payment failed');
    }

    return await response.json();
}
async function processPaymentOnServer(token, amountInCents) {
    // Get the JWT token from the current Supabase session
    const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
    if (sessionError || !sessionData.session) {
        throw new Error('Not authenticated');
    }
    const jwt = sessionData.session.access_token;

    const serverEndpoint = 'https://your-project-ref.supabase.co/functions/v1/process-yoco-payment';
    const payload = {
        token: token,
        amountInCents: amountInCents,
        currency: 'ZAR',
        userId: currentUser.id
    };

    const response = await fetch(serverEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${jwt}`,
        },
        body: JSON.stringify(payload)
    });

    if (!response.ok) {
        const errorText = await response.text();
        console.error('Server error:', errorText);
        throw new Error('Server error occurred');
    }

    return await response.json();
}
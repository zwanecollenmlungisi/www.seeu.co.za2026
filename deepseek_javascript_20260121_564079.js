// ==================== YOCO PAYMENT INTEGRATION ====================
// Replace these with your TEST keys during development, and LIVE keys for production.
const YOCO_PUBLIC_KEY = 'pk_test_your_test_public_key_here'; // From Yoco Portal > Selling Online > Payment Gateway[citation:8]
let yocoSDK = null;

// Initialize the Yoco SDK when the payment screen loads
function initializeYocoSDK() {
    if (typeof YocoSDK !== 'undefined') {
        yocoSDK = new YocoSDK(YOCO_PUBLIC_KEY);
        const cardElement = yocoSDK.createCardElement({
            element: '#yoco-card-element',
            layout: 'vertical',
            currency: 'ZAR',
            amountInCents: 28999, // R289.99 in cents
            required: true,
            onValid: (valid) => {
                // Enable/disable pay button based on card validity
                document.getElementById('yocoPaymentBtn').disabled = !valid;
            }
        });
        window.yocoCardElement = cardElement; // Make it accessible
    } else {
        console.error('Yoco SDK failed to load.');
        showToast('Payment system is currently unavailable.', 'error');
    }
}

// Main function to process the payment
async function processYocoPayment() {
    const btn = document.getElementById('yocoPaymentBtn');
    const cardName = document.getElementById('cardName').value.trim();
    
    // Basic validation
    if (!cardName) {
        showToast('Please enter the cardholder name.', 'error');
        return;
    }
    if (!window.yocoCardElement) {
        showToast('Payment form not ready. Please refresh.', 'error');
        return;
    }

    // Disable button and show loading state
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';

    try {
        // 1. Create a token with Yoco (This happens on the client side)
        const result = await window.yocoCardElement.tokenize({
            cardHolder: cardName,
        });

        if (result.error) {
            // Handle errors from Yoco SDK (e.g., invalid card)
            throw new Error(`Card Error: ${result.error.message}`);
        }

        // 2. Send the token to YOUR BACKEND for secure processing
        const paymentResult = await processPaymentOnServer(result.token, 28999);
        
        if (paymentResult.success) {
            // 3. On success, update user profile and show success screen
            await supabase
                .from('profiles')
                .update({ 
                    payment_status: 'paid',
                    payment_date: new Date().toISOString(),
                    subscription_end: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()
                })
                .eq('id', currentUser.id);
            
            showToast('Payment successful! Welcome to See U Premium!', 'success');
            showScreen('paymentSuccessScreen');
        } else {
            throw new Error(paymentResult.message || 'Payment failed on server.');
        }

    } catch (error) {
        console.error('Payment processing error:', error);
        showToast(`Payment failed: ${error.message}`, 'error');
        // Re-enable the button
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-lock"></i> Pay R289.99 Now';
    }
}

// **CRITICAL: This is a placeholder for your server-side code.**
// You must implement this endpoint on a secure server (e.g., using Node.js, Python, etc.).
async function processPaymentOnServer(token, amountInCents) {
    // This function should NOT be in your frontend code in production.
    // It's shown here to illustrate the flow.
    console.warn('SERVER-SIDE PROCESSING SIMULATION. IMPLEMENT A SECURE SERVER ENDPOINT.');
    
    // Simulate a server call
    const serverEndpoint = 'https://your-backend-server.com/process-payment'; // Your real endpoint
    const payload = {
        token: token,
        amountInCents: amountInCents,
        currency: 'ZAR',
        customerEmail: currentProfile.email
    };

    // In reality, you would do:
    // const response = await fetch(serverEndpoint, {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify(payload)
    // });
    // return await response.json();

    // For now, simulate a successful response after a delay
    return new Promise(resolve => {
        setTimeout(() => {
            resolve({ success: true, message: 'Charged successfully' });
        }, 1500);
    });
}
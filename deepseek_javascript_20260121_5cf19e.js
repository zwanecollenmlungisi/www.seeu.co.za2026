async function processYocoPayment() {
    const btn = document.getElementById('yocoPaymentBtn');
    const cardName = document.getElementById('cardName').value.trim();
    
    // Validation
    if (!cardName) {
        showToast('Please enter the cardholder name.', 'error');
        return;
    }

    // Show loading
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';

    try {
        // 1. Tokenize card with Yoco
        const result = await window.yocoCardElement.tokenize({
            cardHolder: cardName,
        });

        if (result.error) {
            throw new Error(`Card Error: ${result.error.message}`);
        }

        // 2. Process payment via Supabase Edge Function
        const paymentResult = await processPaymentOnServer(result.token, 28999);
        
        if (paymentResult.success) {
            // 3. Update local state
            currentProfile.payment_status = 'paid';
            currentProfile.subscription_end = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();
            
            // 4. Show success
            showToast('Payment successful! Welcome to See U Premium!', 'success');
            
            // 5. Redirect to success screen
            setTimeout(() => {
                showScreen('paymentSuccessScreen');
            }, 1500);
            
            // 6. Refresh user data
            await loadProfileData();
        } else {
            throw new Error(paymentResult.message || 'Payment failed');
        }

    } catch (error) {
        console.error('Payment error:', error);
        showToast(`Payment failed: ${error.message}`, 'error');
        
        // Re-enable button
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-lock"></i> Pay R289.99 Now';
    }
}

// Helper function to load profile data
async function loadProfileData() {
    const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', currentUser.id)
        .single();
    
    if (!error && data) {
        currentProfile = data;
        if (currentProfile.payment_status === 'paid') {
            // Update UI to show premium status
            document.querySelectorAll('.premium-badge').forEach(el => {
                el.style.display = 'inline-flex';
            });
        }
    }
}
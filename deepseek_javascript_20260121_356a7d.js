// Add this to your initialization
function isTestMode() {
    return YOCO_PUBLIC_KEY.includes('pk_test_');
}

// Update payment screen to show test mode warning
function showYocoPaymentScreen() {
    showScreen('yocoPaymentScreen');
    
    if (isTestMode()) {
        // Add test mode banner
        const paymentCard = document.querySelector('#yocoPaymentScreen .auth-card');
        const testBanner = document.createElement('div');
        testBanner.className = 'secure-payment-notice';
        testBanner.style.background = 'rgba(245, 158, 11, 0.1)';
        testBanner.style.borderColor = 'rgba(245, 158, 11, 0.2)';
        testBanner.innerHTML = `
            <div class="header">
                <i class="fas fa-vial"></i>
                <span>TEST MODE</span>
            </div>
            <p>Using test payment gateway. No real money will be charged.</p>
            <p style="margin-top: 0.5rem; font-size: 0.8rem;">
                <strong>Test Card:</strong> 4000 0000 0000 0001 | <strong>Expiry:</strong> Any future date | <strong>CVC:</strong> 123
            </p>
        `;
        paymentCard.insertBefore(testBanner, paymentCard.firstChild);
    }
    
    initializeYocoSDK();
}
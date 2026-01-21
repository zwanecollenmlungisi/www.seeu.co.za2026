function renderPaymentStatus() {
    if (!currentProfile) return '';
    
    if (currentProfile.payment_status === 'paid') {
        const endDate = new Date(currentProfile.subscription_end);
        const daysLeft = Math.ceil((endDate - new Date()) / (1000 * 60 * 60 * 24));
        
        return `
            <div class="premium-badge">
                <i class="fas fa-crown"></i> Premium Member
                <span style="font-size: 0.8rem; margin-left: 0.5rem;">
                    (${daysLeft} days remaining)
                </span>
            </div>
            <div style="margin-top: 0.5rem; color: var(--gray-400); font-size: 0.9rem;">
                Next payment: ${endDate.toLocaleDateString('en-ZA')}
            </div>
        `;
    } else {
        return `
            <button class="btn" onclick="showScreen('yocoPaymentScreen')" style="width: auto; margin-top: 0.5rem;">
                <i class="fas fa-lock"></i> Upgrade to Premium (R289.99/year)
            </button>
        `;
    }
}
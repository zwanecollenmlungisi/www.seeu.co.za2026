async function processPaymentWithRetry(token, amountInCents, maxRetries = 3) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await processPaymentOnServer(token, amountInCents);
        } catch (error) {
            console.error(`Payment attempt ${attempt} failed:`, error);
            
            if (attempt === maxRetries) {
                throw error;
            }
            
            // Wait before retry (exponential backoff)
            await new Promise(resolve => 
                setTimeout(resolve, Math.pow(2, attempt) * 1000)
            );
            
            showToast(`Retrying payment... (${attempt}/${maxRetries})`, 'warning');
        }
    }
}

// Update main payment function to use retry
// Replace: const paymentResult = await processPaymentOnServer(result.token, 28999);
// With: const paymentResult = await processPaymentWithRetry(result.token, 28999, 3);
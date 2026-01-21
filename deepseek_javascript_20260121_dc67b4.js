// Node.js (Express) server-side example - DO NOT RUN IN BROWSER
const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.json());

const YOCO_SECRET_KEY = 'sk_live_your_secret_key_here'; // From Yoco Portal[citation:8]

app.post('/process-payment', async (req, res) => {
    try {
        const { token, amountInCents, currency, customerEmail } = req.body;

        const response = await axios.post(
            'https://payments.yoco.com/api/charges',
            {
                token: token,
                amountInCents: amountInCents,
                currency: currency,
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + YOCO_SECRET_KEY
                }
            }
        );

        if (response.data.status === 'successful') {
            // 1. Save the successful charge ID to your database
            // 2. Update the user's profile to "paid"
            res.json({ success: true, chargeId: response.data.id });
        } else {
            res.status(400).json({ success: false, message: 'Payment unsuccessful' });
        }
    } catch (error) {
        console.error('Server charge error:', error.response?.data || error.message);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});
require('dotenv').config({ path: require('path').resolve(__dirname, '..', '.env') });
const crypto = require('crypto');
// Use global fetch available in Node 18+

const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
const port = process.env.PORT || 4000;
const url = `http://localhost:${port}/api/payment/webhook`;

if (!webhookSecret) {
  console.error('RAZORPAY_WEBHOOK_SECRET not set in backend .env');
  process.exit(2);
}

// Minimal payment.captured payload structure (Razorpay sends many fields)
const payload = {
  entity: 'event',
  account_id: 'acc_test',
  event: 'payment.captured',
  payload: {
    payment: {
      entity: {
        id: `pay_test_${Date.now()}`,
        entity: 'payment',
        amount: 100,
        currency: 'INR',
        status: 'captured',
        order_id: 'order_RwFj5AAjvOMRmL',
        created_at: Math.floor(Date.now() / 1000)
      }
    }
  }
};

const raw = JSON.stringify(payload);
const signature = crypto.createHmac('sha256', webhookSecret).update(raw).digest('hex');

(async () => {
  try {
    console.log('Sending webhook to', url);
    const resp = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-razorpay-signature': signature
      },
      body: raw
    });

    const text = await resp.text();
    console.log('Status:', resp.status);
    console.log('Body:', text);
  } catch (err) {
    console.error('Error sending webhook:', err);
    process.exit(3);
  }
})();

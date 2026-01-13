// Test script to validate Razorpay API keys by creating a test order
require('dotenv').config({ path: require('path').resolve(__dirname, '..', '.env') });
const Razorpay = require('razorpay');

const keyId = process.env.RAZORPAY_KEY_ID;
const keySecret = process.env.RAZORPAY_KEY_SECRET;

if (!keyId || !keySecret) {
  console.error('RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET not set. Copy .env.example -> .env and fill values.');
  process.exit(2);
}

const rzp = new Razorpay({ key_id: keyId, key_secret: keySecret });

(async () => {
  try {
    console.log('Attempting to create a small test order using provided Razorpay keys...');
    const order = await rzp.orders.create({
      amount: 100, // 1.00 INR (amount in paise)
      currency: 'INR',
      receipt: `test_rcpt_${Date.now()}`,
      payment_capture: 1
    });

    console.log('Success: created order:');
    console.log(JSON.stringify(order, null, 2));
    process.exit(0);
  } catch (err) {
    console.error('Razorpay API error:');
    if (err && err.error) console.error(JSON.stringify(err.error, null, 2));
    else console.error(err);
    process.exit(3);
  }
})();

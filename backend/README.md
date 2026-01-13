# Karma Shop Payments Backend

This backend provides secure Razorpay integration for the Karma Shop app.

## Overview
- Node.js + Express backend
- MongoDB (Mongoose) for order persistence
- Uses `razorpay` official SDK for server-side order creation
- Webhook handler verifies signature using `RAZORPAY_WEBHOOK_SECRET`

## Endpoints
- POST `/api/payment/create-order`
  - Body: `{ items, amount, currency, customer }` (amount in paise)
  - Returns Razorpay order id and saved DB order id

- POST `/api/payment/verify-payment`
  - Body: `{ razorpay_order_id, razorpay_payment_id, razorpay_signature, order_db_id }`
  - Verifies signature server-side and marks order PAID or FAILED

- POST `/api/payment/webhook`
  - Razorpay webhook endpoint (use raw body). Verifies webhook signature and updates order status.

## Environment
Copy `.env.example` -> `.env` and fill values:

- `PORT` (default 4000)
- `MONGODB_URI` (e.g., mongodb+srv://...)
- `RAZORPAY_KEY_ID` (from Razorpay dashboard)
- `RAZORPAY_KEY_SECRET` (from Razorpay dashboard) — never store this in frontend
- `RAZORPAY_WEBHOOK_SECRET` (set in Razorpay dashboard webhook settings)

## Razorpay Dashboard Setup
1. Login to Razorpay dashboard and create/use your account.
2. From Developers -> API Keys: generate `Key ID` and `Key Secret`.
3. From Settings -> Webhooks: add an endpoint `https://<your-host>/api/payment/webhook`.
   - Set the webhook secret (used as `RAZORPAY_WEBHOOK_SECRET`).
   - Select events: `payment.captured`, `order.paid`, `payment.failed`.
4. Use `Key ID` (publishable) in frontend; `Key Secret` and `Webhook Secret` only on server.

## Security & Best Practices
- Never expose `RAZORPAY_KEY_SECRET` or `RAZORPAY_WEBHOOK_SECRET` in the client.
- Use HTTPS in production and validate webhook signatures.
- Use idempotency checks on order creation to prevent duplicates.
- Verify amount on webhook against your database record before marking PAID.

## Run locally

```bash
cd backend
npm install
cp .env.example .env # fill values
npm run dev
```


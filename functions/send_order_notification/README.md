Serverless Send Order Notification
=================================

This folder contains a minimal serverless function that sends an order notification email using Resend.

Environment variables
- `RESEND_API_KEY` (required) — your Resend API key (get it from https://resend.com)
- `FROM_EMAIL` (optional) — sender email (must be verified in Resend, or use onboarding@resend.dev for testing)
- `FROM_NAME` (optional) — sender display name
- `ADMIN_EMAIL` (optional) — where to send order notifications (defaults to contactkarmagully@gmail.com)

Deploy to Vercel
---------------

1. Install dependencies locally:

   ```bash
   cd functions/send_order_notification
   npm install
   ```

2. Deploy to Vercel (requires `vercel` CLI):

   ```bash
   vercel --prod
   ```

3. Set environment variables in Vercel dashboard or with CLI:

   ```bash
   vercel env add RESEND_API_KEY production
   vercel env add FROM_EMAIL production
   vercel env add ADMIN_EMAIL production
   ```

4. Use the deployed function URL as `serverlessEndpoint` in `lib/services/notification_service.dart`.

Deploy to Netlify
-----------------

1. Install dependencies and push to a git repo.
2. Add the project in Netlify and set `functions` folder path to `functions`.
3. Set environment variables in Netlify UI: `SENDGRID_API_KEY`, `FROM_EMAIL`, `ADMIN_EMAIL`.
4. Deploy. The function URL will be available in Netlify functions section; use it as `serverlessEndpoint`.

Security note
-------------
Keep `RESEND_API_KEY` secret in your serverless provider. Do not embed it in the client app.

Testing
-------
Use `curl` to POST an order payload:

```bash
curl -X POST https://<your-function-url> -H "Content-Type: application/json" -d '{"order": {"id": "test-1", "customerName": "Alice", "customerEmail": "a@e.com", "totalAmount": 99.9, "items": []}}'
```

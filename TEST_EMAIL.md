# Email Not Working - Quick Fix Steps

## Most Likely Problem: Missing Vercel Environment Variables

### CRITICAL STEPS (Do These First):

1. **Go to Vercel Dashboard**:
   - Visit: https://vercel.com/dashboard
   - Click on your **karmagully** project
   - Click **Settings** → **Environment Variables**

2. **Add These Environment Variables** (if missing):
   ```
   RESEND_API_KEY = re_CYmQCeaV_EveNE3zJEH7xtFHNPh4c2Mnp
   FROM_EMAIL = onboarding@resend.dev
   FROM_NAME = KarmaGully
   ADMIN_EMAIL = karmagully0@gmail.com
   ```

3. **Redeploy** (IMPORTANT!):
   - After adding environment variables, go to **Deployments** tab
   - Click the 3 dots on the latest deployment
   - Click **Redeploy**
   - OR just push a small change to GitHub (Vercel auto-deploys)

### Test the API Endpoint Directly

Open this URL in your browser or use PowerShell:

**PowerShell Command:**
```powershell
$body = @{
    order = @{
        id = "test-123"
        customerName = "Test User"
        customerEmail = "karmagully0@gmail.com"
        customerPhone = "1234567890"
        totalAmount = 100
        items = @(
            @{
                product = @{
                    name = "Test Product"
                    price = 100
                }
                quantity = 1
            }
        )
        shippingAddress = "123 Test St"
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://karmagully.vercel.app/api/send_order_notification" -Method Post -Body $body -ContentType "application/json"
```

**Expected Response:**
- Success: `{"success":true}`
- Error: Will show what's wrong (e.g., "Resend API key not configured")

### Check App Logs

When you place an order in the app, check the console for:
```
NotificationService: serverless endpoint accepted the notification
```

Or error messages like:
```
NotificationService: serverless returned 500 ...
```

### Verify Resend API Key Works

1. Go to: https://resend.com/api-tokens
2. Make sure your API key `re_CYmQCeaV_EveNE3zJEH7xtFHNPh4c2Mnp` is there and active
3. If not, create a new one and update it in Vercel

### Quick Checklist:

- [ ] Vercel environment variables are set (especially `RESEND_API_KEY`)
- [ ] Latest code is deployed to Vercel (check Deployments tab)
- [ ] Resend API key is valid and active
- [ ] You've redeployed after adding environment variables
- [ ] Test API endpoint returns success

---

## If Still Not Working:

Share with me:
1. The response from the PowerShell test command
2. The app console logs when placing an order
3. Screenshot of Vercel environment variables (hide the API key value)

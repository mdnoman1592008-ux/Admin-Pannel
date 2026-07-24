# Authentication email function

Deploy the Resend sender without exposing its key to Flutter:

```bash
supabase secrets set RESEND_API_KEY="<your Resend key>"
supabase secrets set RESEND_FROM_EMAIL="Ether Cinema <auth@your-verified-domain.com>"
supabase functions deploy send-auth-email
```

`send-auth-email` sends welcome and sign-in notification emails through Resend.
Password-reset and verification links are issued by Firebase Auth because Firebase owns the credential reset tokens. Enable Email/Password in Firebase Authentication and configure its email action settings.

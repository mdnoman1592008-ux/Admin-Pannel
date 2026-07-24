import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders });

  try {
    const { event, email, name } = await request.json();
    if (!['welcome', 'login_alert'].includes(event) || typeof email !== 'string' || !email.includes('@')) {
      return Response.json({ error: 'Invalid email event.' }, { status: 400, headers: corsHeaders });
    }

    const apiKey = Deno.env.get('RESEND_API_KEY');
    const from = Deno.env.get('RESEND_FROM_EMAIL');
    if (!apiKey || !from) {
      return Response.json({ error: 'Email service is not configured.' }, { status: 503, headers: corsHeaders });
    }

    const subject = event === 'welcome' ? 'Welcome to Ether Cinema' : 'New sign-in to Ether Cinema';
    const safeName = typeof name === 'string' && name.trim() ? name.trim() : 'there';
    const html = event === 'welcome'
      ? `<h1>Welcome, ${safeName}!</h1><p>Your Ether Cinema account is ready.</p>`
      : `<h1>New sign-in detected</h1><p>Hello ${safeName}, your Ether Cinema account was just signed in to. If this was not you, reset your password immediately.</p>`;

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from, to: [email], subject, html }),
    });
    if (!response.ok) throw new Error(await response.text());
    return Response.json({ delivered: true }, { headers: corsHeaders });
  } catch (error) {
    console.error(error);
    return Response.json({ error: 'Unable to deliver email.' }, { status: 500, headers: corsHeaders });
  }
});

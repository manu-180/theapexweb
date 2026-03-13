import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// --- CORS RESTRINGIDO ---
const ALLOWED_ORIGINS = [
  'https://www.theapexweb.com',
  'https://theapexweb.com',
];

function getCorsHeaders(req: Request): Record<string, string> {
  const origin = req.headers.get('origin') || '';
  const allowed = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allowed,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Vary': 'Origin',
  };
}

// --- RATE LIMIT (in-memory, per-instance) ---
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_MAX = 5;
const RATE_LIMIT_WINDOW_MS = 60_000;

function checkRateLimit(ip: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(ip);
  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS });
    return true;
  }
  entry.count++;
  return entry.count <= RATE_LIMIT_MAX;
}

// --- VALIDACIÓN ---
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function sanitizeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}

function validateContactPayload(body: unknown): { name: string; email: string; message: string } {
  if (!body || typeof body !== 'object') throw new Error('Payload inválido');
  const { name, email, message } = body as Record<string, unknown>;

  if (typeof name !== 'string' || name.trim().length < 2)
    throw new Error('Nombre inválido (mínimo 2 caracteres)');
  if (typeof email !== 'string' || !EMAIL_REGEX.test(email))
    throw new Error('Email inválido');
  if (typeof message !== 'string' || message.trim().length < 10)
    throw new Error('Mensaje demasiado corto (mínimo 10 caracteres)');

  return {
    name: sanitizeHtml(name.trim()),
    email: email.trim().toLowerCase(),
    message: sanitizeHtml(message.trim()),
  };
}

// --- CONFIGURACIÓN ---
const ADMIN_EMAIL = "manunv97@gmail.com";
const SENDER_EMAIL = "Manuel Navarro <soporte@assistify.lat>";

// --- BRANDING ---
const COLOR_BG = "#0f172a";
const COLOR_CARD = "#1e293b";
const COLOR_ACCENT = "#22d3ee";
const COLOR_TEXT_MAIN = "#f8fafc";
const COLOR_TEXT_MUTED = "#94a3b8";
const ICON_ARROW_UP = "https://img.icons8.com/ios-filled/50/22d3ee/collapse-arrow.png";
const ICON_ENVELOPE = "https://img.icons8.com/ios-filled/100/22d3ee/open-envelope.png";

const generateUserHtml = (name: string, message: string) => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: ${COLOR_BG}; margin: 0; padding: 0;">
  <div style="max-width: 600px; margin: 0 auto; background-color: ${COLOR_BG};">
    
    <div style="padding: 40px 20px; text-align: center;">
      <table align="center" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td style="padding-right: 10px; vertical-align: middle;">
            <img src="${ICON_ARROW_UP}" alt="^" width="24" height="24" style="display: block; border: 0;">
          </td>
          <td style="vertical-align: middle;">
            <h1 style="margin: 0; color: ${COLOR_TEXT_MAIN}; font-size: 28px; letter-spacing: 4px; font-weight: 800; line-height: 28px;">
              APEX
            </h1>
          </td>
        </tr>
      </table>
    </div>

    <div style="background-color: ${COLOR_CARD}; margin: 0 20px; padding: 40px; border-radius: 16px; border: 1px solid #334155; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
      
      <div style="text-align: center; margin-bottom: 30px;">
        <img src="${ICON_ENVELOPE}" alt="Mensaje" width="80" height="80" style="margin-bottom: 20px; display: block; margin-left: auto; margin-right: auto; border: 0;">

        <h2 style="margin: 0; color: ${COLOR_TEXT_MAIN}; font-size: 24px; font-weight: 700;">¡Mensaje Recibido!</h2>
        <p style="margin: 10px 0 0 0; color: ${COLOR_ACCENT}; font-size: 16px;">Hola ${name}, gracias por contactarme.</p>
      </div>

      <p style="color: ${COLOR_TEXT_MUTED}; font-size: 16px; line-height: 1.6; text-align: center; margin-bottom: 30px;">
        He recibido tu consulta correctamente. Analizaré tu propuesta y te responderé personalmente dentro de las próximas 24 horas.
      </p>

      <div style="background-color: ${COLOR_BG}; border-left: 4px solid ${COLOR_ACCENT}; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
        <p style="margin: 0 0 5px 0; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; color: ${COLOR_TEXT_MUTED};">Tu Mensaje:</p>
        <p style="margin: 0; color: ${COLOR_TEXT_MAIN}; font-style: italic; font-size: 15px;">"${message}"</p>
      </div>

      <div style="text-align: center;">
        <a href="https://theapexweb.com" style="display: inline-block; padding: 14px 32px; background-color: ${COLOR_ACCENT}; color: ${COLOR_BG}; text-decoration: none; border-radius: 50px; font-weight: 700; font-size: 14px;">
          Volver al Portfolio
        </a>
      </div>

    </div>

    <div style="padding: 40px 20px; text-align: center;">
      <p style="margin: 0; color: ${COLOR_TEXT_MUTED}; font-size: 12px;">
        Manuel Navarro - Full Stack Developer<br>
        Expert en Flutter & Supabase
      </p>
    </div>

  </div>
</body>
</html>
`;

const generateAdminHtml = (name: string, email: string, message: string) => `
<!DOCTYPE html>
<html>
<body style="font-family: 'Oxanium', monospace; background-color: #f0f2f5; padding: 40px 20px;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
    <div style="display: flex; align-items: center; margin-bottom: 30px;">
      <span style="font-size: 24px; margin-right: 15px;">📬</span>
      <h2 style="margin: 0; color: #1a1f36; font-size: 20px; letter-spacing: 0.5px;">Nuevo Lead Web</h2>
    </div>
    
    <div style="border-top: 1px solid #e6e9f0; padding-top: 25px;">
      <p style="margin: 0 0 15px 0; color: #4f566b; font-size: 14px;"><strong>Nombre:</strong> <span style="color: #1a1f36;">${name}</span></p>
      <p style="margin: 0 0 25px 0; color: #4f566b; font-size: 14px;"><strong>Email:</strong> <a href="mailto:${email}" style="color: #6366f1; text-decoration: none;">${email}</a></p>
      
      <div style="background-color: #f7f9fc; padding: 25px; border-radius: 8px; border: 1px solid #e6e9f0;">
        <p style="margin: 0 0 10px 0; color: #8792a2; font-size: 11px; font-weight: bold; text-transform: uppercase; letter-spacing: 1px;">Mensaje:</p>
        <p style="margin: 0; white-space: pre-wrap; color: #3c4257; line-height: 1.6; font-size: 15px;">${message}</p>
      </div>
    </div>

    <div style="margin-top: 35px; text-align: right;">
      <a href="mailto:${email}" style="background-color: #1a1f36; color: #ffffff; padding: 12px 25px; text-decoration: none; border-radius: 6px; font-size: 14px; font-weight: 600; display: inline-block;">Responder Ahora</a>
    </div>
  </div>
</body>
</html>
`;

serve(async (req) => {
  const cors = getCorsHeaders(req);

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Método no permitido' }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
      status: 405,
    });
  }

  try {
    const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';
    if (!checkRateLimit(clientIp)) {
      return new Response(JSON.stringify({ error: 'Demasiadas solicitudes. Intenta en un minuto.' }), {
        headers: { ...cors, 'Content-Type': 'application/json' },
        status: 429,
      });
    }

    const rawBody = await req.json();
    const { name, email, message } = validateContactPayload(rawBody);

    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    if (!resendApiKey) {
      console.error('RESEND_API_KEY not configured');
      throw new Error('Configuración de servidor incompleta');
    }

    const [userRes, adminRes] = await Promise.all([
      fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${resendApiKey}` },
        body: JSON.stringify({
          from: SENDER_EMAIL,
          to: [email],
          subject: `Recibimos tu mensaje, ${name.split(' ')[0]}`,
          html: generateUserHtml(name, message),
        })
      }),
      fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${resendApiKey}` },
        body: JSON.stringify({
          from: SENDER_EMAIL,
          to: [ADMIN_EMAIL],
          reply_to: email,
          subject: `🔔 Nuevo Contacto: ${name}`,
          html: generateAdminHtml(name, email, message),
        })
      })
    ]);

    if (!userRes.ok || !adminRes.ok) {
      const failedTarget = !userRes.ok ? 'cliente' : 'admin';
      const status = !userRes.ok ? userRes.status : adminRes.status;
      console.error(`Resend failed for ${failedTarget}: ${status}`);
      throw new Error(`Error al enviar email (${failedTarget})`);
    }

    return new Response(JSON.stringify({ success: true, message: 'Emails enviados' }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    const isValidation = error.message?.includes('inválido') || error.message?.includes('corto') || error.message?.includes('caracteres');
    const statusCode = isValidation ? 400 : 500;

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
      status: statusCode,
    });
  }
});

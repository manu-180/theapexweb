// Archivo: supabase/functions/send-booking-email/index.ts
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

function validateBookingPayload(body: unknown): { name: string; email: string; dateIso: string; hour: number } {
  if (!body || typeof body !== 'object') throw new Error('Payload inválido');
  const { name, email, dateIso, hour } = body as Record<string, unknown>;

  if (typeof email !== 'string' || !EMAIL_REGEX.test(email))
    throw new Error('Email inválido');
  if (typeof dateIso !== 'string' || isNaN(Date.parse(dateIso)))
    throw new Error('Fecha inválida');
  if (typeof hour !== 'number' || hour < 0 || hour > 23)
    throw new Error('Hora inválida');

  return {
    name: typeof name === 'string' && name.trim().length > 0 ? sanitizeHtml(name.trim()) : 'Futuro Cliente',
    email: email.trim().toLowerCase(),
    dateIso,
    hour,
  };
}

// --- CONFIGURACIÓN ---
const ADMIN_EMAIL = "manunv97@gmail.com";
const SENDER_EMAIL = "Manuel de APEX <soporte@assistify.lat>";

// --- BRANDING ---
const COLOR_BG = "#0f172a";
const COLOR_CARD = "#1e293b";
const COLOR_ACCENT = "#22d3ee";
const COLOR_TEXT_MAIN = "#f8fafc";
const COLOR_TEXT_MUTED = "#94a3b8";
const ICON_CALENDAR = "https://img.icons8.com/ios-filled/100/22d3ee/calendar-plus.png";
const ICON_APEX = "https://img.icons8.com/ios-filled/50/22d3ee/collapse-arrow.png";

const TZ = 'America/Argentina/Buenos_Aires';

const formatDate = (isoDate: string) => {
  const date = new Date(isoDate);
  return date.toLocaleDateString("es-AR", { weekday: 'long', day: 'numeric', month: 'long', timeZone: TZ });
};

const generateUserHtml = (name: string, date: string, hour: number) => `
<!DOCTYPE html>
<html>
<body style="font-family: 'Segoe UI', sans-serif; background-color: ${COLOR_BG}; margin: 0; padding: 0;">
  <div style="max-width: 600px; margin: 0 auto;">
    
    <div style="padding: 40px 20px; text-align: center;">
       <table align="center" border="0" cellpadding="0" cellspacing="0" style="margin: 0 auto;">
         <tr>
           <td style="vertical-align: middle; padding-right: 12px;">
             <img src="${ICON_APEX}" width="28" height="28" style="display: block; border: 0;">
           </td>
           <td style="vertical-align: middle;">
             <h1 style="margin: 0; color: ${COLOR_TEXT_MAIN}; letter-spacing: 4px; font-size: 28px; line-height: 1;">APEX</h1>
           </td>
         </tr>
       </table>
    </div>

    <div style="background-color: ${COLOR_CARD}; margin: 0 20px; padding: 40px; border-radius: 16px; border: 1px solid #334155; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
      
      <div style="text-align: center; margin-bottom: 30px;">
        <img src="${ICON_CALENDAR}" width="80" style="margin-bottom: 20px;">
        <h2 style="margin: 0; color: ${COLOR_TEXT_MAIN}; font-size: 24px;">¡Reunión Confirmada!</h2>
        <p style="margin: 10px 0 0 0; color: ${COLOR_ACCENT}; font-size: 16px;">Hola ${name}, ya tienes tu lugar reservado.</p>
      </div>

      <div style="background-color: ${COLOR_BG}; padding: 25px; border-radius: 12px; margin-bottom: 30px; border: 1px solid #334155;">
         <p style="margin: 0; color: ${COLOR_TEXT_MUTED}; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;">CUÁNDO:</p>
         <p style="margin: 5px 0 20px 0; color: ${COLOR_TEXT_MAIN}; font-size: 20px; font-weight: bold; text-transform: capitalize;">
            ${formatDate(date)} a las ${hour}:00 hs (Argentina)
         </p>
         
         <p style="margin: 0; color: ${COLOR_TEXT_MUTED}; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;">DÓNDE:</p>
         <p style="margin: 5px 0 0 0; color: ${COLOR_TEXT_MAIN}; font-size: 16px;">
            Reunión Virtual (Google Meet)
         </p>
      </div>

      <p style="color: ${COLOR_TEXT_MUTED}; text-align: center; font-size: 14px;">
        Te enviaré el enlace de la reunión poco antes de la hora programada. Si necesitas cancelar o reagendar, por favor avísame respondiendo este correo.
      </p>

    </div>
    
    <div style="text-align: center; padding: 30px;">
      <p style="color: ${COLOR_TEXT_MUTED}; font-size: 12px;">&copy; ${new Date().getFullYear()} Manuel Navarro - Full Stack Developer</p>
    </div>

  </div>
</body>
</html>
`;

const generateAdminHtml = (name: string, email: string, date: string, hour: number) => `
<!DOCTYPE html>
<html>
<body style="font-family: monospace; background-color: #f0f2f5; padding: 20px;">
  <div style="background-color: #fff; padding: 30px; border-radius: 8px;">
    <h2 style="color: #1a1f36;">📅 Nueva Reunión Agendada</h2>
    <p><strong>Cliente:</strong> ${name}</p>
    <p><strong>Email:</strong> ${email}</p>
    <p><strong>Fecha:</strong> ${formatDate(date)}</p>
    <p><strong>Hora:</strong> ${hour}:00 hs (Argentina)</p>
    <hr>
    <a href="mailto:${email}" style="color: #22d3ee; font-weight: bold;">Contactar al cliente</a>
  </div>
</body>
</html>
`;

serve(async (req) => {
  const cors = getCorsHeaders(req);

  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

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
    const { name, email, dateIso, hour } = validateBookingPayload(rawBody);

    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    if (!resendApiKey) {
      console.error('RESEND_API_KEY not configured');
      throw new Error('Configuración de servidor incompleta');
    }

    const userRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${resendApiKey}` },
      body: JSON.stringify({
        from: SENDER_EMAIL,
        to: [email],
        subject: `✅ Reunión Confirmada: ${formatDate(dateIso)} ${hour}hs`,
        html: generateUserHtml(name, dateIso, hour),
      })
    });

    if (!userRes.ok) {
      console.error(`Resend failed for client email: ${userRes.status}`);
      throw new Error('Error al enviar email de confirmación');
    }

    const adminRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${resendApiKey}` },
      body: JSON.stringify({
        from: SENDER_EMAIL,
        to: [ADMIN_EMAIL],
        subject: `📅 Cita Agendada: ${name || email}`,
        html: generateAdminHtml(name, email, dateIso, hour),
      })
    });

    if (!adminRes.ok) {
      console.error(`Resend failed for admin notification: ${adminRes.status}`);
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    const isValidation = error.message?.includes('inválid') || error.message?.includes('Payload');
    const statusCode = isValidation ? 400 : 500;

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
      status: statusCode,
    });
  }
});

// Archivo: supabase/functions/create_preference_manuel/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. Manejo de CORS (Indispensable para que funcione desde tu web)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. Leemos los datos que envía tu app Flutter
    const { title, unit_price, quantity = 1 } = await req.json()

    // 3. Llamamos a la API de MercadoPago
    const mpResponse = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // IMPORTANTE: Aquí lee el secreto que configuraremos en el paso de deploy
        'Authorization': `Bearer ${Deno.env.get('MP_ACCESS_TOKEN')}`, 
      },
      body: JSON.stringify({
        items: [
          {
            title: title,
            quantity: quantity,
            currency_id: 'ARS', // Peso Argentino
            unit_price: unit_price,
          },
        ],
        // URLs de retorno (puedes cambiarlas por las de tu web real cuando la tengas)
        back_urls: {
          success: "https://www.google.com", // Ejemplo
          failure: "https://www.google.com",
          pending: "https://www.google.com"
        },
        auto_return: "approved",
      }),
    })

    const mpData = await mpResponse.json()

    if (mpData.error) {
      console.error('Error MP:', mpData)
      throw new Error(mpData.message || 'Error creando preferencia en MercadoPago')
    }

    // 4. Devolvemos el link de pago (init_point) a tu app
    return new Response(JSON.stringify({ init_point: mpData.init_point }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
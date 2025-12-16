import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Parse the webhook payload
    const payload = await req.json()
    console.log('Webhook Payload:', JSON.stringify(payload))

    // Validates that this is an INSERT event from the database webhook
    if (payload.type !== 'INSERT' || !payload.record) {
      // If it's a direct browser call (setup/testing), we might handle it differently, 
      // but for DB webhook, 'record' is key.
      // If called directly via Postman for testing without webhook structure:
      if (payload.prompt) {
         // Allow direct testing
      } else {
         return new Response(JSON.stringify({ error: 'Invalid payload type' }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
          })
      }
    }

    const record = payload.record || payload // Handle both webhook and direct test
    
    // Only process if status is 'pending' to avoid loops
    if (record.status !== 'pending') {
       return new Response(JSON.stringify({ message: 'Skipping non-pending record' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    const SUNO_API_URL = 'https://api.sunoapi.org/api/v1/generate'
    const SUNO_TOKEN = Deno.env.get('SUNO_API_TOKEN')
    
    // Construct Callback URL (pointing to the suno-callback function)
    // Assuming standard Supabase URLs
    const projectUrl = Deno.env.get('SUPABASE_URL') ?? ''
    // Functions URL is typically project URL with /functions/v1/ replaced or appended
    // Actually Deno.env.get('SUPABASE_URL') usually is https://<ref>.supabase.co
    // Functions are at https://<ref>.supabase.co/functions/v1/<name>
    const callbackUrl = `${projectUrl}/functions/v1/suno-callback`

    console.log('Calling Suno API...')
    
    const body = {
      customMode: true,
      instrumental: record.instrumental ?? false,
      model: 'V4_5ALL', // As per user request example
      callBackUrl: callbackUrl,
      prompt: record.prompt,
      style: record.style,
      title: record.title ?? 'Unified Creation',
      // Map other fields
      tags: record.tags ? record.tags.join(',') : '', // Suno API might expect string? Adjust based on docs. User example "negativeTags" is string.
      // personaId: record.meta?.personaId, // Optional
      negativeTags: record.meta?.negativeTags ?? '',
      vocalGender: record.meta?.vocalGender,
      styleWeight: record.meta?.styleWeight,
      weirdnessConstraint: record.meta?.weirdnessConstraint,
      audioWeight: record.meta?.audioWeight,
    }

    console.log('Suno Request Body:', JSON.stringify(body))

    const sunoResponse = await fetch(SUNO_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SUNO_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    })

    const sunoData = await sunoResponse.json()
    console.log('Suno Response:', JSON.stringify(sunoData))

    if (!sunoResponse.ok || sunoData.code !== 200) {
      // Handle Error
      await supabaseClient
        .from('songs')
        .update({ 
          status: 'failed', 
          meta: { ...record.meta, error: sunoData } 
        })
        .eq('id', record.id)
        
      throw new Error(`Suno API Error: ${JSON.stringify(sunoData)}`)
    }

    // Success - Update record with Task ID
    const taskId = sunoData.data.taskId
    
    const { error: updateError } = await supabaseClient
        .from('songs')
        .update({ 
          status: 'processing', 
          task_id: taskId 
        })
        .eq('id', record.id)

    if (updateError) {
      console.error('Failed to update song record:', updateError)
      throw updateError
    }

    return new Response(JSON.stringify(sunoData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('Error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

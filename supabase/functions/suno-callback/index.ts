import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        const payload = await req.json()
        console.log('Callback Payload:', JSON.stringify(payload))

        // Validations
        // Suno callback structure typically: { id: "taskId", status: "completed", clips: [...] }
        // Or sometimes wrapped in { data: ... } depending on the exact proxy/wrapper used.
        // The user linked docs.sunoapi.org which is a wrapper. 
        // Usually it sends the task object.

        const taskId = payload.id || payload.taskId || payload.data?.taskId
        const status = payload.status || payload.data?.status

        if (!taskId) {
            return new Response(JSON.stringify({ error: 'No Task ID found' }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            })
        }

        if (status === 'completed' || status === 'complete') {
            const clips = payload.clips || payload.data?.clips || []

            if (clips.length > 0) {
                // Pick the first clip to update the main record
                const clip = clips[0]

                // Update the song record
                await supabaseClient
                    .from('songs')
                    .update({
                        status: 'completed',
                        audio_url: clip.audio_url,
                        image_url: clip.image_url ?? clip.image_large_url,
                        video_url: clip.video_url,
                        title: clip.title || undefined,
                        duration: clip.duration || undefined,
                        meta: {
                            ...payload, // Store full payload for debugging/extra data
                            full_clips: clips // Store all clips if multiple
                        }
                    })
                    .eq('task_id', taskId)
            } else {
                console.warn('Completed but no clips found')
                await supabaseClient
                    .from('songs')
                    .update({
                        status: 'failed',
                        meta: { error: 'No clips returned', payload }
                    })
                    .eq('task_id', taskId)
            }
        } else if (status === 'failed') {
            await supabaseClient
                .from('songs')
                .update({
                    status: 'failed',
                    meta: { payload }
                })
                .eq('task_id', taskId)
        } else {
            // 'processing' or 'submitted'
            // optionally update status
            await supabaseClient
                .from('songs')
                .update({
                    status: 'processing',
                    meta: { last_update: payload }
                })
                .eq('task_id', taskId)
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error) {
        console.error('Callback Error:', error)
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        })
    }
})

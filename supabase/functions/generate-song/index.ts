import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const url = new URL(req.url)
        const songId = url.searchParams.get('song_id')

        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

        // Try multiple possible key names - user reported using MUSIC_API_KEY
        const musicApiKey = Deno.env.get('MUSIC_API_KEY') || Deno.env.get('MUSICGPT_API_KEY') || Deno.env.get('MUSIC_GPT_API_KEY') || Deno.env.get('LALALS_API_KEY')

        if (!supabaseUrl || !supabaseKey) {
            throw new Error('Missing Supabase configuration')
        }

        const supabase = createClient(supabaseUrl, supabaseKey)

        /* =========================================================================
           1️⃣ WEBHOOK HANDLER
        ========================================================================= */
        if (songId) {
            console.log(`🎧 Webhook received for song: ${songId}`)

            let payload: any = {}
            const contentType = req.headers.get('content-type') || ''

            try {
                if (contentType.includes('application/json')) {
                    payload = await req.json()
                } else {
                    const formData = await req.formData()
                    formData.forEach((value, key) => (payload[key] = value))
                }
            } catch (e) {
                console.error('Error parsing webhook payload:', e)
                return new Response(JSON.stringify({ error: 'Invalid payload' }), {
                    status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                })
            }

            console.log('📦 Webhook payload:', JSON.stringify(payload))

            const status = payload.status || (payload.success ? 'completed' : 'failed')

            const audioUrl =
                payload.conversion_path ||
                payload.audio_url ||
                payload.output?.audio_url ||
                payload.url ||
                payload.result?.audio_url;

            const videoUrl =
                payload.conversion_path_wav ||
                payload.video_url ||
                payload.output?.video_url;

            const coverUrl =
                payload.album_cover_path ||
                payload.image_url;

            const lyrics =
                payload.lyrics ||
                payload.result?.lyrics;

            if (audioUrl) {
                console.log(`✅ Success! Updating song ${songId}`)

                const updateData: any = {
                    status: 'completed',
                    audio_url: audioUrl,
                    cover_url: coverUrl,
                    lyrics: lyrics,
                    updated_at: new Date().toISOString()
                }

                if (videoUrl) {
                    updateData.video_url = videoUrl
                }

                const { error } = await supabase
                    .from('songs')
                    .update(updateData)
                    .eq('id', songId)

                if (error) console.error('Supabase Update Error:', error)

                return new Response(JSON.stringify({ success: true }), {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                })

            } else if (payload.errors || payload.error || status === 'failed') {
                const errorMsg = payload.error || JSON.stringify(payload.errors) || 'Unknown error'
                console.log(`❌ Failed! Updating song ${songId} with error: ${errorMsg}`)

                await supabase
                    .from('songs')
                    .update({ status: 'failed' })
                    .eq('id', songId)

                return new Response(JSON.stringify({ success: true, warning: 'marked as failed' }), {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                })
            }

            return new Response(JSON.stringify({ success: true, message: 'no status change' }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            })
        }

        /* =========================================================================
           2️⃣ GENERATION REQUEST (Use MusicAI Endpoint)
           Reference: https://docs.musicgpt.com/api-documentation/conversions/musicai
        ========================================================================= */
        let body: any = {}
        const contentType = req.headers.get('content-type') || ''

        if (contentType.includes('multipart/form-data')) {
            const formData = await req.formData()
            formData.forEach((value, key) => {
                if (typeof value === 'string') {
                    body[key] = value
                }
            })
        } else {
            body = await req.json()
        }

        const { user_id, singer_id, idea, tags, is_instrumental } = body

        if (!musicApiKey) {
            console.error('API Key not found. Available env vars:', Object.keys(Deno.env.toObject()).filter(k => !k.includes('SERVICE_ROLE')))
            throw new Error('Server misconfiguration: Missing MusicGPT API Key. Please set MUSIC_API_KEY in Supabase Edge Function secrets.')
        }

        // Prepare Prompt & Style
        let prompt = idea || ''
        let style = 'Pop'
        if (tags) {
            try {
                const tagList = typeof tags === 'string' ? JSON.parse(tags) : tags
                if (Array.isArray(tagList) && tagList.length > 0) {
                    style = tagList.join(', ')
                }
            } catch (e) {
                style = String(tags)
            }
        }

        if (!prompt || prompt.trim() === '') {
            prompt = `A ${style} song`
        }

        // Ensure prompt is under 280 characters as per docs
        if (prompt.length > 280) {
            prompt = prompt.substring(0, 277) + '...'
        }

        // Create song record in DB first
        const { data: song, error: dbError } = await supabase
            .from('songs')
            .insert({
                user_id,
                singer_id,
                title: prompt.length > 50 ? prompt.substring(0, 50) + '...' : prompt,
                idea,
                tags: typeof tags === 'string' ? JSON.parse(tags) : tags,
                is_instrumental: is_instrumental === 'true' || is_instrumental === true,
                status: 'processing',
                emotion: 'Generating...',
                created_at: new Date().toISOString(),
            })
            .select()
            .single()

        if (dbError) {
            console.error('DB Insert Error:', dbError)
            throw dbError
        }

        const webhookUrl = `${url.origin}/functions/v1/generate-song?song_id=${song.id}`

        // Construct MusicAI JSON Payload
        // Per docs: https://docs.musicgpt.com/api-documentation/conversions/musicai
        // Authorization header should be just the API key (not "Bearer <key>")
        const musicAiPayload: any = {
            prompt: prompt,
            music_style: style,
            webhook_url: webhookUrl,
            lyrics: "",
            make_instrumental: is_instrumental === 'true' || is_instrumental === true,
        }

        console.log(`🚀 Calling MusicAI for song ${song.id}`)
        console.log(`📋 Payload:`, JSON.stringify(musicAiPayload))
        console.log(`🔑 API Key (first 8 chars):`, musicApiKey.substring(0, 8) + '...')

        const response = await fetch('https://api.musicgpt.com/api/public/v1/MusicAI', {
            method: 'POST',
            headers: {
                'Authorization': musicApiKey, // Per docs: just the key, no "Bearer" prefix
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(musicAiPayload)
        })

        const responseText = await response.text()
        console.log(`📡 MusicAI Response (${response.status}):`, responseText)

        if (!response.ok) {
            await supabase.from('songs').update({ status: 'failed' }).eq('id', song.id)
            throw new Error(`MusicAI API Error: ${response.status} - ${responseText}`)
        }

        return new Response(JSON.stringify(song), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })

    } catch (error: any) {
        console.error('Global Error:', error)
        return new Response(JSON.stringify({ error: error.message }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
    }
})

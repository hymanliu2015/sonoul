/* =========================================================================
   1️⃣ WEBHOOK HANDLER (UPDATED V2)
========================================================================= */
if (songId) {
    console.log(`🎧 Webhook received for song: ${songId}`)

    // Debug Auth Key
    const keyCheck = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    console.log(`🔑 Service Role Key Present: ${keyCheck ? 'YES' : 'NO'} (Length: ${keyCheck?.length || 0})`)

    let payload: any = {}
    const contentType = req.headers.get('content-type') || ''

    try {
        if (contentType.includes('application/json')) {
            payload = await req.json()
        } else if (contentType.includes('application/x-www-form-urlencoded')) {
            const formData = await req.formData()
            formData.forEach((value, key) => {
                payload[key] = value
            })
        }
    } catch (e) {
        console.error('Error parsing webhook body:', e)
        return new Response(JSON.stringify({ error: 'Invalid body' }), { status: 400 })
    }

    console.log('📦 Webhook Payload:', JSON.stringify(payload))

    const status = payload.status || payload.data?.status || 'completed' // Default to completed if missing?

    if (status !== 'completed') {
        // Update Loop
        const { error } = await supabase
            .from('songs')
            .update({
                status: status,
                audio_url: payload.audio_url || payload.data?.audio_url,
                video_url: payload.video_url || payload.data?.video_url,
                cover_url: payload.cover_url || payload.data?.image_url,
            })
            .eq('id', songId)
        if (error) console.error('Status update error:', error)
        return new Response(JSON.stringify({ success: true }), { headers: corsHeaders })
    }

    // Check if song exists
    const { data: existingSong, error: fetchError } = await supabase
        .from('songs')
        .select('*')
        .eq('id', songId)
        .maybeSingle()

    if (fetchError) {
        console.error('❌ DB Error fetching song:', fetchError)
        return new Response(JSON.stringify({ error: 'Database error ' + fetchError.message }), { status: 500 })
    }

    if (!existingSong) {
        console.error('❌ Song not found in DB. ID:', songId)
        return new Response(JSON.stringify({ error: 'Song not found' }), { status: 404 })
    }

    if (existingSong.status === 'completed') {
        console.log('⚠️ Song already completed! Creating NEW record.')
        const { error: insertError } = await supabase
            .from('songs')
            .insert({
                user_id: existingSong.user_id,
                singer_id: existingSong.singer_id,
                title: existingSong.title + ' (v2)',
                idea: existingSong.idea,
                prompt: existingSong.prompt,
                tags: existingSong.tags,
                is_instrumental: existingSong.is_instrumental,
                status: 'completed',
                audio_url: payload.audio_url || payload.data?.audio_url,
                video_url: payload.video_url || payload.data?.video_url,
                cover_url: payload.cover_url || payload.data?.image_url,
                duration: payload.duration || payload.data?.duration,
                model_used: payload.model_name || payload.data?.model_name,
                created_at: new Date().toISOString()
            })

        if (insertError) {
            console.error('Insert error:', insertError)
            throw insertError
        }
    } else {
        console.log('✅ First completion. Updating.')
        const { error } = await supabase
            .from('songs')
            .update({
                status: 'completed',
                audio_url: payload.audio_url || payload.data?.audio_url,
                video_url: payload.video_url || payload.data?.video_url,
                cover_url: payload.cover_url || payload.data?.image_url,
                duration: payload.duration || payload.data?.duration,
                model_used: payload.model_name || payload.data?.model_name,
                tags: payload.tags || payload.data?.tags,
            })
            .eq('id', songId)
        if (error) throw error
    }

    return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
}

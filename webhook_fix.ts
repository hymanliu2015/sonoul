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

            // Check if status is completed
            const status = payload.status || payload.data?.status
            if (status !== 'completed') {
                 // If failed or processing, just update the original
                 const { error } = await supabase
                    .from('songs')
                    .update({
                        status: status || 'failed',
                        audio_url: payload.audio_url || payload.data?.audio_url,
                        video_url: payload.video_url || payload.data?.video_url,
                        cover_url: payload.cover_url || payload.data?.image_url, // Map image_url to cover_url
                        duration: payload.duration || payload.data?.duration,
                        model_used: payload.model_name || payload.data?.model_name,
                        tags: payload.tags || payload.data?.tags,
                    })
                    .eq('id', songId)

                 if (error) throw error
                 return new Response(JSON.stringify({ success: true }), { headers: corsHeaders })
            }

            // If COMPLETED, check if the song is ALREADY completed
            const { data: existingSong, error: fetchError } = await supabase
                .from('songs')
                .select('*')
                .eq('id', songId)
                .single()

            if (fetchError) {
                console.error('Error fetching song:', fetchError)
                return new Response(JSON.stringify({ error: 'Song not found' }), { status: 404 })
            }

            if (existingSong.status === 'completed') {
                console.log('⚠️ Song already completed! Creating NEW record for 2nd generation.')
                
                // Create NEW record
                const { error: insertError } = await supabase
                    .from('songs')
                    .insert({
                        user_id: existingSong.user_id,
                        singer_id: existingSong.singer_id,
                        title: existingSong.title + ' (Safe)', // Differentiate title
                        idea: existingSong.idea,
                        prompt: existingSong.prompt,
                        tags: existingSong.tags,
                        is_instrumental: existingSong.is_instrumental,
                        status: 'completed',
                        // New Media
                        audio_url: payload.audio_url || payload.data?.audio_url,
                        video_url: payload.video_url || payload.data?.video_url,
                        cover_url: payload.cover_url || payload.data?.image_url,
                        duration: payload.duration || payload.data?.duration,
                        model_used: payload.model_name || payload.data?.model_name,
                        created_at: new Date().toISOString()
                    })

                 if (insertError) throw insertError
            } else {
                // First completion, update normally
                console.log('✅ First completion. Updating original record.')
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

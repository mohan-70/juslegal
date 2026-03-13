export default {
  async fetch(request, env) {
    const corsHeaders = {
      'Access-Control-Allow-Origin': 'https://juslegal-2196.web.app',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Only allow POST requests
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { 
        status: 405, 
        headers: corsHeaders 
      });
    }

    try {
      const body = await request.json();
      
      // Validate required fields
      if (!body || typeof body !== 'object') {
        return new Response('Invalid request body', { 
          status: 400, 
          headers: corsHeaders 
        });
      }

      const { service, prompt, category } = body;

      // Validate service parameter
      if (!service || typeof service !== 'string' || !['groq', 'openrouter'].includes(service)) {
        return new Response('Invalid or missing service parameter', { 
          status: 400, 
          headers: corsHeaders 
        });
      }

      // Validate prompt parameter
      if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
        return new Response('Invalid or missing prompt parameter', { 
          status: 400, 
          headers: corsHeaders 
        });
      }

      // Validate prompt length (prevent abuse)
      if (prompt.length > 10000) {
        return new Response('Prompt too long (max 10000 characters)', { 
          status: 400, 
          headers: corsHeaders 
        });
      }

      // Validate category parameter
      if (!category || typeof category !== 'string' || category.trim().length === 0) {
        return new Response('Invalid or missing category parameter', { 
          status: 400, 
          headers: corsHeaders 
        });
      }

      const SYSTEM_PROMPT = `You are JusLegal, an AI legal assistant specialized in Indian consumer law. For every query respond with: 1) Applicable law and section numbers 2) User's rights 3) Step-by-step action plan 4) Authority to contact 5) Timeline 6) Success probability 7) Whether they need a lawyer. End with: This is AI guidance, not legal advice.`;

      // Model selection logic based on service and input characteristics
      if (service === 'groq') {
        const inputLength = prompt.length;
        let model;
        
        // Choose model based on input length and complexity
        if (inputLength > 3000) {
          // Long legal descriptions - use model with higher TPM limit
          model = 'meta-llama/llama-4-scout-17b-16e-instruct';
        } else if (inputLength < 1000) {
          // Short/simple inputs - use higher quality model
          model = 'llama-3.3-70b-versatile';
        } else {
          // Medium length - use balanced model
          model = 'llama-3.1-8b-instant';
        }

        const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${env.GROQ_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: model,
            messages: [
              { role: 'system', content: SYSTEM_PROMPT },
              { role: 'user', content: `Category: ${category}\n\nProblem: ${prompt}` }
            ],
            temperature: 0.2,
            max_tokens: 1200,
            top_p: 0.2,
            response_format: { type: 'json_object' },
            stream: false
          }),
        });
        
        if (!res.ok) {
          const errorText = await res.text();
          return new Response(`Groq API error: ${res.status} ${errorText}`, { 
            status: res.status, 
            headers: corsHeaders 
          });
        }
        
        const data = await res.json();
        // Add model metadata to response
        data._model = model;
        data._provider = 'groq';
        return Response.json(data, { headers: corsHeaders });
      }

      if (service === 'openrouter') {
        // Use DeepSeek R1 for best reasoning quality as final fallback
        const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${env.OPENROUTER_API_KEY}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://juslegal-2196.web.app',
            'X-Title': 'JusLegal',
          },
          body: JSON.stringify({
            model: 'deepseek/deepseek-r1:free',
            messages: [
              { role: 'system', content: SYSTEM_PROMPT },
              { role: 'user', content: `Category: ${category}\n\nProblem: ${prompt}` }
            ],
            temperature: 0.2,
            max_tokens: 1200,
            top_p: 0.2,
            response_format: { type: 'json_object' },
            stream: false
          }),
        });
        
        if (!res.ok) {
          const errorText = await res.text();
          return new Response(`OpenRouter API error: ${res.status} ${errorText}`, { 
            status: res.status, 
            headers: corsHeaders 
          });
        }
        
        const data = await res.json();
        // Add model metadata to response
        data._model = 'deepseek/deepseek-r1:free';
        data._provider = 'openrouter';
        return Response.json(data, { headers: corsHeaders });
      }

      return new Response('Invalid service', { status: 400, headers: corsHeaders });
    } catch (error) {
      console.error('Worker error:', error);
      return new Response('Internal server error', { 
        status: 500, 
        headers: corsHeaders 
      });
    }
  }
}

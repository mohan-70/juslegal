const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// CORS configuration - restrict to your Firebase Hosting domain
const corsOptions = {
  origin: ['https://juslegal-2196.web.app', 'https://juslegal-2196.firebaseapp.com'],
  optionsSuccessStatus: 200
};

// Groq API Callable Function
exports.callGroq = functions.https.onCall(async (data, context) => {
  // Validate input
  if (!data.prompt || !data.category) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: prompt and category');
  }

  try {
    const apiKey = functions.config().groq.api_key;
    if (!apiKey) {
      throw new functions.https.HttpsError('internal', 'Groq API key not configured');
    }

    const response = await axios.post(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        model: 'llama-3.3-70b-versatile',
        messages: [
          {
            role: 'system',
            content: `You are a legal AI assistant for Indian law. Category: ${data.category}. Provide accurate, helpful legal information.`
          },
          {
            role: 'user',
            content: data.prompt
          }
        ],
        temperature: 0.2,
        max_tokens: 1200,
        top_p: 0.2,
        response_format: { type: 'json_object' },
        stream: false
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        }
      }
    );

    return {
      success: true,
      data: response.data,
      provider: 'groq'
    };

  } catch (error) {
    console.error('Groq API Error:', error);
    
    if (error.response) {
      const status = error.response.status;
      if (status === 429) {
        throw new functions.https.HttpsError('resource-exhausted', 'Rate limit exceeded. Please try again later.');
      } else if (status === 401) {
        throw new functions.https.HttpsError('permission-denied', 'Invalid API key');
      } else {
        throw new functions.https.HttpsError('internal', `API Error: ${error.response.data?.error?.message || 'Unknown error'}`);
      }
    } else if (error.request) {
      throw new functions.https.HttpsError('unavailable', 'Network error. Please check your connection.');
    } else {
      throw new functions.https.HttpsError('internal', 'Internal server error');
    }
  }
});

// OpenRouter API Callable Function
exports.callOpenRouter = functions.https.onCall(async (data, context) => {
  // Validate input
  if (!data.prompt || !data.category) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: prompt and category');
  }

  try {
    const apiKey = functions.config().openrouter.api_key;
    if (!apiKey) {
      throw new functions.https.HttpsError('internal', 'OpenRouter API key not configured');
    }

    const response = await axios.post(
      'https://openrouter.ai/api/v1/chat/completions',
      {
        model: 'meta-llama/llama-3.3-70b-instruct:free',
        messages: [
          {
            role: 'system',
            content: `You are a legal AI assistant for Indian law. Category: ${data.category}. Provide accurate, helpful legal information.`
          },
          {
            role: 'user',
            content: data.prompt
          }
        ],
        temperature: 0.2,
        max_tokens: 1200,
        top_p: 0.2,
        response_format: { type: 'json_object' },
        stream: false
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://juslegal-2196.web.app',
          'X-Title': 'JusLegal'
        }
      }
    );

    return {
      success: true,
      data: response.data,
      provider: 'openrouter'
    };

  } catch (error) {
    console.error('OpenRouter API Error:', error);
    
    if (error.response) {
      const status = error.response.status;
      if (status === 429) {
        throw new functions.https.HttpsError('resource-exhausted', 'Rate limit exceeded. Please try again later.');
      } else if (status === 401) {
        throw new functions.https.HttpsError('permission-denied', 'Invalid API key');
      } else {
        throw new functions.https.HttpsError('internal', `API Error: ${error.response.data?.error?.message || 'Unknown error'}`);
      }
    } else if (error.request) {
      throw new functions.https.HttpsError('unavailable', 'Network error. Please check your connection.');
    } else {
      throw new functions.https.HttpsError('internal', 'Internal server error');
    }
  }
});

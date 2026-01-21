// Rate limiting in Edge Function (update index.ts)
const rateLimit = new Map();

// Add this at the beginning of Deno.serve handler
const userIp = req.headers.get('x-forwarded-for') || 'unknown';
const now = Date.now();
const windowMs = 60 * 1000; // 1 minute
const maxRequests = 5;

const userRequests = rateLimit.get(userIp) || [];
const recentRequests = userRequests.filter(time => now - time < windowMs);

if (recentRequests.length >= maxRequests) {
    return new Response(
        JSON.stringify({ success: false, message: 'Too many requests. Please try again later.' }),
        { status: 429, headers: corsHeaders }
    );
}

recentRequests.push(now);
rateLimit.set(userIp, recentRequests);
# Testing Guide for API and WebSocket Functionality

This document provides test cases to verify that API requests and WebSocket connections work correctly through the Caddy reverse proxy.

## Prerequisites

- QanoonHub deployed (locally or on Railway)
- Access to browser developer tools
- Optional: API testing tool (Postman, Thunder Client, curl)

## Testing API Requests

### 1. Test Authentication Endpoints

```bash
# Test login endpoint
curl -X POST http://localhost/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Expected: 200 OK with JWT token or 401 Unauthorized
```

### 2. Test API Endpoints

```bash
# Test cases endpoint (may require authentication)
curl http://localhost/api/cases

# Expected: 200 OK with data or 401 if authentication required
```

### 3. Test File Uploads

```bash
# Test upload endpoint
curl -X POST http://localhost/uploads/test.pdf

# Expected: Response based on your upload implementation
```

## Testing WebSocket Connections

### Method 1: Browser Developer Tools

1. **Open your application in browser**
   - Navigate to `http://localhost` (or your Railway URL)
   - Open Developer Tools (F12)
   - Go to the **Network** tab

2. **Filter for WebSocket connections**
   - Look for connections to `/socket.io/`
   - Check the connection status (should show `101 Switching Protocols`)

3. **Verify Socket.io connection**
   - In the Console tab, you should see Socket.io connection messages
   - No errors about failed WebSocket upgrades

### Method 2: Test with Socket.io Client Code

Add this to your browser console when the app is loaded:

```javascript
// Check Socket.io connection status
if (window.io) {
  console.log('Socket.io is loaded');
  
  // Monitor connection events
  const socket = io({
    query: { token: 'your-jwt-token' }
  });
  
  socket.on('connect', () => {
    console.log('✅ Socket.io connected:', socket.id);
  });
  
  socket.on('connect_error', (error) => {
    console.error('❌ Socket.io connection error:', error);
  });
  
  socket.on('disconnect', (reason) => {
    console.log('Socket.io disconnected:', reason);
  });
} else {
  console.error('Socket.io not found');
}
```

### Method 3: Monitor Network Traffic

**Look for these request patterns:**

1. **Initial HTTP polling request:**
   ```
   Request: GET /socket.io/?EIO=4&transport=polling&t=xxxxx
   Response: 200 OK
   ```

2. **WebSocket upgrade:**
   ```
   Request: GET /socket.io/?EIO=4&transport=websocket&sid=xxxxx
   Response: 101 Switching Protocols
   ```

3. **Active WebSocket connection:**
   - Status should show "Pending" or active WebSocket frames
   - Messages tab should show ping/pong frames

## Expected Behaviors

### ✅ Correct Setup

- **API Requests**: Return expected responses (200, 401, etc.)
- **WebSocket Upgrade**: Shows `101 Switching Protocols`
- **Socket.io Transport**: Successfully upgrades from polling to websocket
- **Real-time Features**: Chat messages appear instantly
- **No CORS Errors**: No browser console errors about CORS

### ❌ Common Issues

**Issue: WebSocket connection fails**
```
Symptoms: Socket.io stays on polling transport
Check: Caddy configuration for /socket.io/* route
Verify: WebSocket headers are forwarded correctly
```

**Issue: CORS errors on Socket.io**
```
Symptoms: Browser console shows CORS policy errors
Check: app.js Socket.io CORS configuration
Verify: CLIENT_URL environment variable matches frontend URL
```

**Issue: API requests return 502/504**
```
Symptoms: API calls timeout or fail
Check: Backend service is running
Verify: Caddy can reach backend:9000
```

## Docker Compose Testing

When testing locally with `docker-compose up`, check:

```bash
# View Caddy logs
docker-compose logs caddy

# View backend logs  
docker-compose logs backend

# View frontend logs
docker-compose logs frontend

# Follow all logs
docker-compose logs -f
```

## Railway Deployment Testing

After deploying to Railway:

1. **Check deployment logs**
   ```bash
   railway logs
   ```

2. **Test API endpoint**
   ```bash
   curl https://your-app.up.railway.app/api/cases
   ```

3. **Test WebSocket in browser**
   - Open your Railway URL
   - Open DevTools → Network → WS filter
   - Verify Socket.io connection established

## Troubleshooting Guide

### API Issues

| Problem | Solution |
|---------|----------|
| 404 on API routes | Verify `/api/*` route in Caddyfile |
| 502 Bad Gateway | Check backend service is running |
| CORS errors | Update CORS config in app.js |

### WebSocket Issues

| Problem | Solution |
|---------|----------|
| No WebSocket upgrade | Add `/socket.io/*` route to Caddyfile |
| Connection refused | Verify backend Socket.io is listening |
| Auth errors | Check JWT token in Socket.io handshake |
| Stays on polling | Verify Upgrade headers are forwarded |

## Production Checklist

Before going live, verify:

- [ ] API endpoints respond correctly
- [ ] WebSocket connections upgrade successfully
- [ ] Socket.io authentication works
- [ ] Real-time chat functionality works
- [ ] File uploads complete successfully
- [ ] CORS is properly configured for production domain
- [ ] HTTPS works correctly (if using custom domain)
- [ ] No console errors in browser
- [ ] Backend logs show successful Socket.io connections

## Additional Resources

- [Socket.io Client API](https://socket.io/docs/v4/client-api/)
- [Caddy Reverse Proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)
- [WebSocket Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)

# QanoonHub Deployment Guide

This guide covers deploying QanoonHub to Railway using Docker containers and Caddy as a reverse proxy/web server.

## Prerequisites

- [Railway Account](https://railway.app/) (free tier works)
- MongoDB database (Railway MongoDB addon or MongoDB Atlas)
- Docker installed locally (for testing)
- Git repository connected to Railway

## Deployment Options

### Option 1: Single Container Deployment (Recommended for Railway)

This approach builds and serves both frontend and backend in a single container, which is ideal for Railway's free tier.

**Files used:**
- `Dockerfile` - Multi-stage build
- `railway.toml` - Railway configuration

**Steps:**

1. **Create a new project on Railway**
   ```bash
   # Connect your GitHub repository to Railway via the dashboard
   # or use Railway CLI
   npm install -g @railway/cli
   railway login
   railway init
   ```

2. **Add MongoDB database**
   - In Railway dashboard, click "New" → "Database" → "Add MongoDB"
   - Or use MongoDB Atlas and add connection string as environment variable

3. **Configure environment variables**
   
   Go to your Railway project → Variables tab and add:
   ```
   MONGO_URI=mongodb://...
   MONGO_DBNAME=qanoonhub
   JWT_SECRET=your-secret-key-here
   SERVER_PORT=9000
   CLIENT_URL=${{RAILWAY_PUBLIC_DOMAIN}}
   NODE_ENV=production
   ```

   > **Note:** `${{RAILWAY_PUBLIC_DOMAIN}}` is automatically replaced by Railway with your app's URL

4. **Deploy**
   ```bash
   git add .
   git commit -m "Add Railway deployment configuration"
   git push
   ```

   Railway will automatically detect the `Dockerfile` and `railway.toml`, then build and deploy your application.

5. **Access your application**
   - Railway will provide a public URL (e.g., `https://your-app.up.railway.app`)
   - The frontend will be served at the root URL
   - API endpoints are available at `/api/*` and `/auth/*`

---

### Option 2: Multi-Container Deployment (Advanced)

This approach uses separate containers for frontend, backend, and Caddy reverse proxy. The frontend container also uses Caddy (for serving static files), while the main Caddy container acts as a reverse proxy.

**Files used:**
- `Dockerfile.backend` - Backend container
- `Dockerfile.frontend` - Frontend container (Caddy serving static files)
- `Caddyfile` - Reverse proxy configuration
- `docker-compose.yml` - Local orchestration

**Architecture:**
1. Frontend static files served by Caddy file server
2. Backend runs in separate Node.js container
3. Main Caddy instance acts as reverse proxy routing traffic
4. Better separation of concerns

**For Local Testing:**

1. **Create `.env` file in project root**
   ```env
   MONGO_URI=mongodb://localhost:27017/qanoonhub
   MONGO_DBNAME=qanoonhub
   JWT_SECRET=your-secret-key
   CLIENT_URL=http://localhost
   ```

2. **Run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - Frontend: `http://localhost`
   - Backend API: `http://localhost/api/*`
   - WebSocket: Automatically handled by Caddy

4. **Stop the application**
   ```bash
   docker-compose down
   ```

**For Railway Pro Plan (Multiple Services):**

Railway Pro supports multiple services. You can deploy:
1. Backend service using `Dockerfile.backend`
2. Frontend service using `Dockerfile.frontend`
3. Caddy service with custom Caddyfile

Each service needs its own Railway service configuration.

---

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `MONGO_URI` | MongoDB connection string | `mongodb+srv://user:pass@cluster.mongodb.net/` |
| `MONGO_DBNAME` | Database name | `qanoonhub` |
| `JWT_SECRET` | Secret key for JWT tokens | `your-super-secret-key-123` |
| `SERVER_PORT` | Backend server port | `9000` |
| `CLIENT_URL` | Frontend URL for CORS | `https://your-app.up.railway.app` |
| `NODE_ENV` | Environment mode | `production` |

---

## Testing Deployment Locally

Before deploying to Railway, test the Docker build locally:

### Single Container Test

```bash
# Build the image
docker build -t qanoonhub:latest .

# Run the container
docker run -p 9000:9000 \
  -e MONGO_URI="your-mongodb-uri" \
  -e MONGO_DBNAME="qanoonhub" \
  -e JWT_SECRET="your-secret" \
  -e CLIENT_URL="http://localhost:9000" \
  qanoonhub:latest

# Access at http://localhost:9000
```

### Multi-Container Test

```bash
# Make sure .env file exists with all required variables
docker-compose up --build

# Access at http://localhost
```

### WebSocket Connection Test

To verify Socket.io WebSocket connections work correctly:

**Using Browser DevTools:**
1. Open `http://localhost` in your browser
2. Open Developer Tools (F12) → Network tab → WS filter
3. Look for `/socket.io/` connection with status `101 Switching Protocols`
4. Check Console for Socket.io connection messages

**Using curl (for HTTP polling):**
```bash
# Test Socket.io polling endpoint
curl "http://localhost/socket.io/?EIO=4&transport=polling"

# Should return: 0{"sid":"...","upgrades":["websocket"],"pingInterval":...}
```

**From your frontend code:**
```javascript
const socket = io('http://localhost', {
  query: { token: 'your-jwt-token' }
});

socket.on('connect', () => {
  console.log('Connected:', socket.id);
});
```

> **Note:** See `TESTING.md` for comprehensive API and WebSocket testing guide.

---

## Important Notes

### WebSocket Support

The Caddyfile is configured to properly handle Socket.io WebSocket connections:
- Dedicated `/socket.io/*` route for Socket.io traffic
- Proper forwarding of `Connection` and `Upgrade` headers
- Supports both HTTP long-polling and WebSocket transports
- No additional configuration needed on the backend

### Socket.io CORS Configuration

The current `app.js` allows all origins for Socket.io:
```javascript
cors: {
  origin: "*",
}
```

**For production, update to:**
```javascript
cors: {
  origin: process.env.CLIENT_URL,
  credentials: true
}
```

### File Uploads

The `uploads/` directory is mounted as a volume in multi-container setup. For Railway single container:
- Files are stored in the container filesystem
- Consider using cloud storage (AWS S3, Cloudinary) for persistent file storage
- Railway volumes are available on Pro plan

### Database Migrations

To create an admin user after deployment:

```bash
# Using Railway CLI
railway run npm run create-admin

# Or connect to your Railway service shell and run:
npm run create-admin
```

---

## Troubleshooting

### Build Fails

**Issue:** Frontend build fails in Docker
```
Solution: Check that all frontend dependencies are in package.json
Ensure NODE_ENV is not set to 'production' during build stage
```

**Issue:** Backend can't connect to MongoDB
```
Solution: Verify MONGO_URI is correct in Railway variables
Check that MongoDB database allows connections from Railway IPs
For MongoDB Atlas, add 0.0.0.0/0 to IP whitelist
```

### Runtime Issues

**Issue:** API endpoints return 502/504
```
Solution: Check Railway logs for errors
Verify environment variables are set correctly
Ensure MongoDB is running and accessible
```

**Issue:** Socket.io connections fail
```
Solution: Check CORS configuration in app.js
Verify WebSocket support is enabled (should be automatic on Railway)
Check that CLIENT_URL matches your frontend domain
```

**Issue:** Frontend shows but API calls fail
```
Solution: Check that backend is running (Railway logs)
Verify API routes are correct (/api/*, /auth/*)
Check CORS settings in backend
```

### Logs

View logs in Railway:
```bash
# Using Railway CLI
railway logs

# Or view in Railway dashboard → Deployments → View Logs
```

---

## Deployment Checklist

- [ ] MongoDB connection string ready
- [ ] All environment variables configured in Railway
- [ ] Update Socket.io CORS from wildcard to specific domain
- [ ] Test Docker build locally
- [ ] Push code to connected Git repository
- [ ] Verify Railway deployment succeeds
- [ ] Test API endpoints
- [ ] Test WebSocket connections (chat feature)
- [ ] Create admin user
- [ ] Test file upload functionality
- [ ] Set up custom domain (optional)

---

## Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Docker Documentation](https://docs.docker.com/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)

---

## Support

For issues specific to:
- **Railway deployment**: Check [Railway Discord](https://discord.gg/railway)
- **Docker issues**: See [Docker Forums](https://forums.docker.com/)
- **Application bugs**: Create an issue in your repository

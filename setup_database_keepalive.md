# Database Keep-Alive Setup Guide

This guide explains how to keep your Railway PostgreSQL database always running and prevent it from going to sleep.

## Solutions Implemented

### 1. Database Connection Pooling
- **Connection Max Age**: 600 seconds (10 minutes)
- **Connection Health Checks**: Enabled
- **PostgreSQL Options**: Connection timeout and statement timeout configured

### 2. Middleware Keep-Alive
- **DatabaseKeepAliveMiddleware**: Pings the database on every request
- Automatically keeps connections alive during active usage
- Only activates for PostgreSQL (not SQLite)

### 3. Health Check Endpoint
- **Endpoint**: `/api/dashboard/health/`
- **Purpose**: External services can ping this endpoint to keep the database active
- **Access**: Public (no authentication required)

### 4. Keep-Alive Background Worker
- **Script**: `backend/keep_alive.py`
- **Function**: Periodically pings the database every 5 minutes
- **Usage**: Can be run as a background process or Railway worker

## Setup Instructions

### Option 1: Using Railway Worker (Recommended)

1. **Add a Worker Service in Railway:**
   - Go to your Railway project dashboard
   - Click "New" → "Empty Service"
   - Name it "database-keepalive"
   - Set the root directory to `backend`
   - Add the start command: `python keep_alive.py 5`
   - Railway will automatically restart it if it fails

2. **Environment Variables:**
   - The worker will use the same `DATABASE_URL` from your main service
   - No additional configuration needed

### Option 2: Using External Cron Service

You can use an external service like:
- **UptimeRobot** (Free): https://uptimerobot.com
- **Cron-job.org** (Free): https://cron-job.org
- **EasyCron** (Free tier available): https://www.easycron.com

**Setup:**
1. Create a new monitor/job
2. URL: `https://animalguardian-backend-production-b5a8.up.railway.app/api/dashboard/health/`
3. Interval: Every 5 minutes
4. Method: GET

### Option 3: Local Background Process

If you want to run the keep-alive script locally:

```bash
cd backend
python keep_alive.py 5
```

This will ping the database every 5 minutes. Press Ctrl+C to stop.

## Verification

### Test Health Endpoint
```bash
curl https://animalguardian-backend-production-b5a8.up.railway.app/api/dashboard/health/
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-01-16T10:30:00Z"
}
```

### Check Database Connection
The middleware will automatically ping the database on each request. You can verify this by:
1. Making any API request to your backend
2. Checking the logs for database connection activity

## Configuration

### Adjust Keep-Alive Interval

Edit `backend/keep_alive.py` and change the default interval:
```python
keep_alive_loop(interval=5)  # Change 5 to your desired minutes
```

Or pass it as a command-line argument:
```bash
python keep_alive.py 10  # Ping every 10 minutes
```

### Disable Middleware (if needed)

If you want to disable the middleware keep-alive, comment it out in `backend/animalguardian/settings.py`:
```python
MIDDLEWARE = [
    # ... other middleware ...
    # 'animalguardian.middleware.DatabaseKeepAliveMiddleware',  # Disabled
]
```

## Monitoring

### Railway Logs
Check your Railway service logs to see keep-alive activity:
```bash
railway logs --service animalguardian-backend
```

### Health Check Monitoring
You can set up monitoring for the health endpoint:
- **UptimeRobot**: Monitor the health endpoint
- **Railway Metrics**: Check service uptime
- **Custom Dashboard**: Query the health endpoint periodically

## Troubleshooting

### Database Still Going to Sleep

1. **Check Railway Plan**: Free tier databases may have sleep policies
2. **Verify Worker is Running**: Check Railway dashboard for worker service status
3. **Check Health Endpoint**: Ensure it's accessible and returning 200
4. **Review Logs**: Check for connection errors in Railway logs

### Connection Errors

If you see connection errors:
1. Verify `DATABASE_URL` is set correctly
2. Check database service status in Railway
3. Ensure connection pooling settings are correct
4. Review PostgreSQL connection limits

## Best Practices

1. **Use Multiple Methods**: Combine middleware + health endpoint + worker for redundancy
2. **Monitor Regularly**: Set up alerts for database connection failures
3. **Adjust Intervals**: Balance between keeping database alive and resource usage
4. **Upgrade Plan**: Consider upgrading Railway plan if database sleep is an issue

## Notes

- The middleware only activates for PostgreSQL databases (not SQLite)
- Connection pooling settings only apply to PostgreSQL
- Health endpoint is public - no authentication required
- Keep-alive worker can be stopped/started without affecting main service


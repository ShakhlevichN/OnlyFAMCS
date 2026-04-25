# Video Chat Roulette Server (Python)

FastAPI-based WebSocket server for video chat roulette with user authentication.

## Features

- **User Registration & Authentication** - JWT-based auth system
- **WebSocket Signaling** - Real-time WebRTC signaling
- **Random Partner Matching** - Roulette-style matching
- **User Profiles** - Age, gender, interests
- **Chat Messages** - Text chat during video calls
- **Database Integration** - PostgreSQL with SQLAlchemy

## Quick Start

### Using Docker (Recommended)

```bash
# Copy environment file
cp .env.example .env

# Start with Docker Compose
docker-compose up -d

# The server will be available at http://localhost:8080
```

### Manual Setup

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Setup PostgreSQL**:
   ```bash
   # Create database
   createdb videochat
   
   # Copy and edit environment
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Run the server**:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8080
   ```

## API Endpoints

### Authentication

#### Register User
```http
POST /api/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "securepassword123",
  "display_name": "John",
  "age": 25,
  "gender": "male",
  "interests": "music, movies, travel"
}
```

#### Login
```http
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

#### Get Profile
```http
GET /api/profile
Authorization: Bearer <token>
```

#### Update Profile
```http
PUT /api/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "display_name": "John Doe",
  "age": 26,
  "gender": "male",
  "interests": "music, movies, coding"
}
```

### WebSocket Connection

Connect to WebSocket with JWT token:
```javascript
const ws = new WebSocket('ws://localhost:8080/ws?token=<your-jwt-token>');
```

#### WebSocket Messages

##### Search for Partner
```json
{
  "type": "search"
}
```

##### WebRTC Offer
```json
{
  "type": "offer",
  "to": "partner-id",
  "sdp": "offer-sdp"
}
```

##### WebRTC Answer
```json
{
  "type": "answer",
  "to": "partner-id",
  "sdp": "answer-sdp"
}
```

##### ICE Candidate
```json
{
  "type": "ice-candidate",
  "to": "partner-id",
  "candidate": "candidate-string",
  "sdpMid": "0",
  "sdpMLineIndex": 0
}
```

##### Next Partner
```json
{
  "type": "next"
}
```

##### Chat Message
```json
{
  "type": "chat-message",
  "message": "Hello there!"
}
```

## Database Schema

### Users Table
- `id` - Primary key
- `username` - Unique username
- `email` - Unique email
- `hashed_password` - Bcrypt hash
- `display_name` - Display name
- `age` - User age
- `gender` - User gender
- `interests` - JSON string of interests
- `is_active` - Account status
- `is_verified` - Email verification status
- `created_at` - Registration timestamp
- `updated_at` - Last update timestamp

## Development

### Running Tests
```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

### Database Migrations
```bash
# Install Alembic if not already installed
pip install alembic

# Initialize migrations (first time only)
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Initial migration"

# Apply migrations
alembic upgrade head
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:password@localhost/videochat` |
| `SECRET_KEY` | JWT signing key | `your-secret-key-here-change-in-production` |
| `HOST` | Server host | `0.0.0.0` |
| `PORT` | Server port | `8080` |

## Security Notes

- **JWT Tokens**: Use strong secret keys in production
- **Password Hashing**: Uses bcrypt with salt
- **CORS**: Configured for development, restrict in production
- **Database**: Use SSL connections in production
- **Rate Limiting**: Consider adding rate limiting for API endpoints

## Deployment

### Docker Deployment
```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f server

# Stop
docker-compose down
```

### Manual Deployment
```bash
# Install production dependencies
pip install gunicorn

# Run with Gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8080
```

## Monitoring

The server includes basic health endpoints:
- `GET /` - Server status
- WebSocket connection monitoring
- User connection tracking

## License

MIT License

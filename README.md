# Stack Overflow Clone

A full-stack application that replicates Stack Overflow's question-answer interface with AI-powered answer reranking capabilities.

## 🚀 Features

- **Intelligent Search Results**: Search displays multiple relevant Stack Overflow questions with their best answers inline
- **AI-Powered Reranking**: LLM automatically reranks both search results AND individual answers for improved relevance and accuracy
- **Dual Sort Modes**: Toggle between "Relevance" (Stack Overflow's ranking) and "Accuracy" (AI-reranked) for search results
- **Best Answer Display**: Each search result shows the accepted answer or highest-voted answer directly inline
- **Smart Caching**: Stores the 5 most recent questions with answers in PostgreSQL database
- **Recently Asked Questions Sidebar**: Quick access to cached questions - click to instantly display from cache
- **Modern UI**: Stack Overflow-inspired UI built with React and Tailwind CSS
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Fully Containerized**: Complete Docker Compose setup for easy deployment

## 📋 Tech Stack

### Backend
- **Elixir 1.15** with **Phoenix Framework 1.7**
- **PostgreSQL 15** for database
- **HTTPoison** for Stack Overflow API integration
- **OpenAI API** (GPT-3.5) or **Ollama** for local LLM
- **CORS Plug** for cross-origin requests

### Frontend
- **React 18** with **Vite** build tool
- **Tailwind CSS** for styling
- **Axios** for API communication
- **React Icons** for UI icons
- **date-fns** for date formatting

### Infrastructure
- **Docker & Docker Compose** for containerization
- **PostgreSQL** for data persistence

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **OpenAI API key** (for AI reranking) OR **Ollama** running locally (optional)

## 🏃 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/your-username/stackoverflow-clone.git
cd stackoverflow-clone
```

### 2. Set up environment variables

Create a `.env` file in the **root directory**:

```env
# Option 1: Use OpenAI API (Recommended for best results)
OPENAI_API_KEY=sk-your_openai_api_key_here

# Option 2: Use local Ollama (For running LLM locally)
# OLLAMA_HOST=http://host.docker.internal:11434
# OLLAMA_MODEL=llama2

# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=stackoverflow_clone_dev

# Phoenix Configuration
SECRET_KEY_BASE=your_generated_secret_key_base_here
PHX_HOST=localhost
PORT=4000
MIX_ENV=dev
```

**Generate a SECRET_KEY_BASE:**
```bash
openssl rand -base64 64
```

### 3. Start the application

```bash
docker-compose up --build
```

This command will:
- Start PostgreSQL database with health checks
- Build and run the Elixir Phoenix backend (port 4000)
- Build and run the React frontend (port 5173)
- Set up database schema automatically

**Wait for all services to start** (usually takes 1-2 minutes on first run).

### 4. Access the application

- **Frontend UI**: http://localhost:5173
- **Backend API**: http://localhost:4000/api

### 5. Try it out!

1. Type a programming question in the search bar (e.g., "How to reverse a string in Python")
2. Browse search results showing multiple relevant questions with their best answers displayed inline
3. Toggle between "Relevance" and "Accuracy (AI)" tabs to see AI-reranked results
4. Click on any question title to view it on Stack Overflow
5. Check the sidebar for recently asked questions - click any to instantly load from cache!

## 🛠️ Development Setup (Without Docker)

If you prefer to run the services locally without Docker:

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
mix deps.get

# Create and migrate database
mix ecto.create
mix ecto.migrate

# Start Phoenix server
mix phx.server
```

The backend will be available at http://localhost:4000

### Frontend Setup

In a new terminal:

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start Vite dev server
npm run dev
```

The frontend will be available at http://localhost:5173

### Environment Variables for Local Development

**Backend** - Set these in your shell or `.env` file:
```bash
export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/stackoverflow_clone_dev
export OPENAI_API_KEY=your_key_here
export SECRET_KEY_BASE=$(openssl rand -base64 64)
```

**Frontend** - Create `frontend/.env`:
```env
VITE_API_URL=http://localhost:4000/api
```

## 🤖 Using Ollama for Local LLM (Alternative to OpenAI)

If you want to use a local LLM instead of OpenAI:

### 1. Install Ollama

```bash
# macOS/Linux
curl -fsSL https://ollama.com/install.sh | sh

# Or download from https://ollama.com
```

### 2. Pull a model

```bash
ollama pull llama2
# or
ollama pull mistral
```

### 3. Update your .env

```env
# Comment out OpenAI
# OPENAI_API_KEY=...

# Enable Ollama
OLLAMA_HOST=http://host.docker.internal:11434
OLLAMA_MODEL=llama2
```

### 4. Restart the services

```bash
docker-compose down
docker-compose up --build
```

## 📡 API Endpoints

### Search Questions (Single Question with All Answers)
```http
POST /api/questions/search
Content-Type: application/json

{
  "question": "How to reverse a string in Python"
}
```

**Response:**
```json
{
  "question": {
    "id": 123456,
    "title": "How to reverse a string in Python?",
    "body": "...",
    "tags": ["python", "string"],
    "score": 150,
    "view_count": 10000,
    "answer_count": 5,
    "link": "https://stackoverflow.com/questions/...",
    "owner": {...}
  },
  "answers": [...],
  "reranked_answers": [...]
}
```

### Search Similar Questions (Multiple Questions with Best Answers)
```http
POST /api/questions/search-similar
Content-Type: application/json

{
  "question": "How to reverse a string in Python"
}
```

**Response:**
```json
{
  "questions": [
    {
      "id": 123456,
      "title": "How to reverse a string in Python?",
      "body": "...",
      "tags": ["python", "string"],
      "score": 150,
      "view_count": 10000,
      "answer_count": 5,
      "link": "https://stackoverflow.com/questions/...",
      "owner": {...},
      "answers": [
        {
          "answer_id": 123457,
          "body": "...",
          "score": 200,
          "is_accepted": true,
          "owner": {...}
        }
      ],
      "is_answered": true,
      "accepted_answer_id": 123457,
      "creation_date": 1234567890
    }
  ],
  "reranked_questions": [...]
}
```

### Get Recent Questions
```http
GET /api/questions/recent
```

Returns the 5 most recently searched questions with full cached data including answers.

**Response:**
```json
{
  "questions": [
    {
      "id": 123456,
      "title": "How to reverse a string in Python?",
      "body": "...",
      "tags": ["python", "string"],
      "score": 150,
      "view_count": 10000,
      "answer_count": 5,
      "link": "https://stackoverflow.com/questions/...",
      "owner": {
        "display_name": "John Doe",
        "reputation": 5000
      },
      "answers": [...],
      "reranked_answers": [...],
      "searched_at": "2024-10-11T10:30:00Z"
    }
  ]
}
```

## 📁 Project Structure

```
stackoverflow-clone/
├── backend/                    # Elixir Phoenix backend
│   ├── config/
│   │   ├── config.exs         # Base configuration
│   │   ├── dev.exs            # Development config
│   │   ├── runtime.exs        # Runtime config
│   │   └── test.exs           # Test config
│   ├── lib/
│   │   ├── stackoverflow_clone/
│   │   │   ├── application.ex         # Application supervisor
│   │   │   ├── llm_client.ex          # LLM integration
│   │   │   ├── stackoverflow_client.ex # Stack Overflow API
│   │   │   ├── questions.ex           # Questions context
│   │   │   ├── questions/
│   │   │   │   └── question.ex        # Question schema
│   │   │   └── repo.ex                # Database repo
│   │   └── stackoverflow_clone_web/
│   │       ├── controllers/
│   │       │   ├── question_controller.ex
│   │       │   └── error_json.ex
│   │       ├── endpoint.ex
│   │       └── router.ex
│   ├── test/                  # Backend tests
│   ├── priv/repo/migrations/  # Database migrations
│   ├── Dockerfile
│   └── mix.exs
│
├── frontend/                   # React frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── Header.jsx
│   │   │   ├── SearchBar.jsx
│   │   │   ├── SearchResults.jsx         # NEW: Search results with inline answers
│   │   │   ├── QuestionDisplay.jsx
│   │   │   ├── AnswersList.jsx
│   │   │   ├── RecentSearchTab.jsx
│   │   │   └── LoadingSpinner.jsx
│   │   ├── services/
│   │   │   └── api.js
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── index.css
│   ├── Dockerfile
│   └── package.json
│
├── docker-compose.yml
└── README.md
```

## 🧪 Testing

### Backend Tests

Run the backend test suite:

```bash
# Using Docker
docker-compose exec backend mix test

# Or locally (without Docker)
cd backend
mix test
```

The backend includes tests for:
- `llm_client_test.exs` - LLM client functionality
- `questions_test.exs` - Questions context and database operations
- `stackoverflow_client_test.exs` - Stack Overflow API client
- `question_controller_test.exs` - API endpoints

### Frontend Development

Run the frontend in development mode with hot reload:

```bash
cd frontend
npm run dev
```

## 🔍 Key Features Explained

### 1. Stack Overflow Integration
- Uses the official Stack Overflow API (v2.3)
- Searches questions by title and content
- Fetches complete question details with answers
- Intelligently selects best answer (accepted or highest-voted) for each search result
- Displays user reputation, votes, and accepted answers
- Direct links to original Stack Overflow questions

### 2. Intelligent Search Results
- **Inline Best Answers**: Each search result displays the question with its best answer shown directly
- **Multiple Results**: View up to 10 relevant questions at once with their answers
- **Dual Ranking System**: 
  - **Relevance Tab**: Stack Overflow's default relevance ranking
  - **Accuracy Tab**: AI-reranked results for improved quality
- **Smart Answer Selection**: Automatically shows accepted answer if available, otherwise highest-voted answer

### 3. AI-Powered Reranking (Automatic)
The LLM automatically reranks both search results and individual answers based on:
- **Relevance**: How well the content addresses the query/question
- **Accuracy**: Correctness of the information provided
- **Clarity**: How clear and well-explained the content is
- **Code Quality**: Quality of code examples (if present)
- **Answer Quality**: For search results, considers the quality of available answers

### 4. Smart Caching System
- Automatically caches the 5 most recently searched questions
- Includes full question data, answers, and both answer orders (original and AI-reranked)
- Updates search timestamp on repeated queries
- Sidebar displays recently asked questions for quick access
- Click any recent question to instantly load from cache (no API call required)
- Old entries automatically removed when limit exceeded

### 5. User Interface
- Clean, modern design matching Stack Overflow aesthetics
- Color scheme inspired by Stack Overflow's branding
- Responsive layout for all screen sizes
- Smooth toggle between "Relevance" and "Accuracy (AI)" tabs for search results
- Visual indicators for accepted answers (green checkmark)
- Best answers highlighted with green border and background
- Vote counts and user reputation display
- Direct links to original Stack Overflow pages

## 🐛 Troubleshooting

### Issue: Ports already in use

**Solution:** Modify the ports in `docker-compose.yml`:
```yaml
services:
  backend:
    ports:
      - "4001:4000"  # Change 4001 to any available port
  frontend:
    ports:
      - "3000:5173"  # Change 3000 to any available port
```

### Issue: Database connection errors

**Symptoms:** Backend crashes with "connection refused" or "database does not exist"

**Solution:**
1. Ensure PostgreSQL container is healthy: `docker-compose ps`
2. Check logs: `docker-compose logs db`
3. Reset database: `docker-compose down -v && docker-compose up --build`

### Issue: Frontend can't connect to backend

**Symptoms:** "Network Error" or CORS errors in browser console

**Solution:**
1. Verify backend is running: `curl http://localhost:4000/api/questions/recent`
2. Check CORS settings in `backend/lib/stackoverflow_clone_web/endpoint.ex`
3. Ensure frontend environment variable is correct

### Issue: LLM reranking not working

**Symptoms:** Only see "Original Order" tab, no AI reranking

**Solution:**
1. **For OpenAI:** Verify your API key is valid and has credits
2. **For Ollama:** 
   - Check Ollama is running: `ollama list`
   - Verify the model is downloaded: `ollama pull llama2`
   - Check host configuration: `http://host.docker.internal:11434`
3. Check backend logs: `docker-compose logs backend`

### Issue: Stack Overflow API rate limiting

**Symptoms:** "API returned status 429" errors

**Solution:**
- Stack Overflow API has rate limits (300 requests per day for unauthenticated)
- Wait for the limit to reset (typically 24 hours)
- For production use, register for an API key at [Stack Apps](https://stackapps.com/)

### Issue: Slow first-time build

**Explanation:** Docker needs to download images and build containers on first run

**This is normal!** Subsequent runs will be much faster due to caching.

## 📊 Performance Considerations

- Backend responds in < 500ms for cached questions
- First-time searches take 2-5 seconds (Stack Overflow API + LLM processing)
- Database queries are optimized with indexes
- Frontend uses React's efficient rendering
- Docker volumes cache dependencies for faster rebuilds

## 🚢 Docker Commands Reference

### Starting the Application
```bash
# Start all services (detached mode)
docker-compose up -d

# Start with logs visible
docker-compose up

# Rebuild and start
docker-compose up --build
```

### Stopping the Application
```bash
# Stop all services (preserves data)
docker-compose down

# Stop and remove all data (fresh start)
docker-compose down -v
```

### Viewing Logs
```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Checking Status
```bash
# View running containers
docker-compose ps

# View resource usage
docker stats
```

### Restarting Services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
docker-compose restart frontend
```

## 🏗️ Architecture Overview

The application follows a clean three-tier architecture:

1. **Presentation Layer (React Frontend)**
   - User interface components
   - State management with React hooks
   - API communication via Axios

2. **Application Layer (Phoenix Backend)**
   - RESTful API endpoints
   - Business logic and data processing
   - Integration with external APIs

3. **Data Layer (PostgreSQL)**
   - Persistent storage for cached questions
   - Optimized queries with indexes
   - JSONB storage for flexible answer data

**Request Flow:**
```
User → React UI → Phoenix API → Stack Overflow API
                              → LLM API (OpenAI/Ollama)
                              → PostgreSQL Database
```

## 🔒 Security Considerations

### Current Implementation
- CORS configured for frontend origin
- Input validation on all endpoints
- SQL injection protection via Ecto parameterization
- Environment variables for secrets management

### Production Recommendations
- Enable HTTPS/SSL/TLS
- Implement rate limiting
- Add user authentication (JWT)
- Sanitize HTML content from Stack Overflow
- Use secret management service (AWS Secrets Manager, HashiCorp Vault)
- Add monitoring and error tracking (Sentry, AppSignal)

## 📚 Design Decisions

### Why Elixir/Phoenix?
- Excellent concurrency and fault tolerance
- Fast API response times
- Built-in support for JSON APIs
- Robust pattern matching for data transformation

### Why React with Vite?
- Fast development with Hot Module Replacement (HMR)
- Modern build tool with excellent performance
- Component-based architecture for maintainability
- Wide ecosystem of libraries

### Why PostgreSQL?
- Reliable and battle-tested
- Excellent support for JSON data (JSONB for storing answers)
- ACID compliance for data integrity
- Great performance for read-heavy workloads

### Why Tailwind CSS?
- Utility-first approach for rapid development
- Consistent design system
- No need for separate CSS files
- Easy to customize and match Stack Overflow's look

## 🚀 Future Enhancements

Potential improvements for this project:

- 🔐 User authentication and session management
- ✍️ Ability to post questions and answers
- ⬆️⬇️ Voting system for answers
- 💬 Comments on questions and answers
- 🔍 Advanced search with filters (tags, date range, votes)
- 📊 Analytics dashboard for search patterns
- 🔔 Real-time updates with Phoenix Channels/LiveView
- 🌐 Internationalization (i18n) support
- 🎯 Personalized recommendations based on search history
- 📱 Native mobile app (React Native)

## 📝 License

MIT License - feel free to use this project for learning and development.

## 🙏 Acknowledgments

- Stack Overflow for their excellent public API
- OpenAI for GPT models
- Ollama for local LLM capabilities
- Phoenix Framework and React communities

---

## 📞 Support

If you encounter any issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review the logs: `docker-compose logs`
3. Ensure all prerequisites are installed correctly
4. Verify environment variables are set properly

---

**Built with ❤️ using Elixir, Phoenix, React, and Docker**

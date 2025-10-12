import { useState, useEffect } from 'react'
import Header from './components/Header'
import SearchBar from './components/SearchBar'
import QuestionDisplay from './components/QuestionDisplay'
import RecentQuestions from './components/RecentQuestions'
import LoadingSpinner from './components/LoadingSpinner'
import { searchQuestion, getRecentQuestions } from './services/api'

function App() {
  const [question, setQuestion] = useState(null)
  const [answers, setAnswers] = useState([])
  const [rerankedAnswers, setRerankedAnswers] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [recentQuestions, setRecentQuestions] = useState([])
  const [showReranked, setShowReranked] = useState(false)
  const [lastSearchTime, setLastSearchTime] = useState(null)

  useEffect(() => {
    loadRecentQuestions()
  }, [])

  const loadRecentQuestions = async () => {
    try {
      const questions = await getRecentQuestions()
      setRecentQuestions(questions)
    } catch (err) {
      console.error('Failed to load recent questions:', err)
    }
  }

  const handleSearch = async (searchQuery) => {
    // Clear previous results immediately to avoid showing stale data
    setQuestion(null)
    setAnswers([])
    setRerankedAnswers([])
    setLoading(true)
    setError(null)
    setShowReranked(false)
    setLastSearchTime(Date.now())

    try {
      const data = await searchQuestion(searchQuery)
      setQuestion(data.question)
      setAnswers(data.answers || [])
      setRerankedAnswers(data.reranked_answers || [])
      
      // Reload recent questions after search with a small delay to ensure DB is updated
      setTimeout(() => {
        loadRecentQuestions()
      }, 500)
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to search question. Please try again.')
      setQuestion(null)
      setAnswers([])
      setRerankedAnswers([])
    } finally {
      setLoading(false)
    }
  }

  const handleRecentQuestionClick = (recentQuestion) => {
    // Search for the recent question again
    handleSearch(recentQuestion.title)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex gap-6">
          {/* Sidebar */}
          <aside className="hidden lg:block w-64 flex-shrink-0">
            <RecentQuestions 
              questions={recentQuestions}
              onQuestionClick={handleRecentQuestionClick}
              key={`recent-${recentQuestions.length}-${recentQuestions[0]?.id || 'empty'}`}
            />
          </aside>

          {/* Main Content */}
          <main className="flex-1">
            <SearchBar onSearch={handleSearch} loading={loading} />
            
            {error && (
              <div className="mt-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
                {error}
              </div>
            )}

            {loading && (
              <div className="mt-8">
                <LoadingSpinner />
              </div>
            )}

            {!loading && question && (
              <QuestionDisplay
                key={`question-${question.id}-${lastSearchTime}`}
                question={question}
                answers={showReranked ? rerankedAnswers : answers}
                showReranked={showReranked}
                onToggleReranked={() => setShowReranked(!showReranked)}
                hasRerankedAnswers={rerankedAnswers.length > 0}
              />
            )}

            {!loading && !question && !error && (
              <div className="mt-12 text-center text-gray-500">
                <svg
                  className="mx-auto h-12 w-12 text-gray-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                  />
                </svg>
                <h3 className="mt-2 text-sm font-medium text-gray-900">Search for a question</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Get started by searching for a Stack Overflow question above.
                </p>
              </div>
            )}
          </main>
        </div>
      </div>
    </div>
  )
}

export default App


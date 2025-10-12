import { FaArrowUp, FaEye, FaCheckCircle, FaRobot, FaArrowLeft } from 'react-icons/fa'
import AnswersList from './AnswersList'

function QuestionDisplay({ question, answers, showReranked, onToggleReranked, hasRerankedAnswers, onBackToSearch, showBackButton = false }) {
  const stripHtml = (html) => {
    const tmp = document.createElement('DIV')
    tmp.innerHTML = html
    return tmp.textContent || tmp.innerText || ''
  }

  return (
    <div className="mt-6 space-y-4">
      {/* Back to Search Results Button */}
      {showBackButton && onBackToSearch && (
        <div className="mb-4">
          <button
            onClick={onBackToSearch}
            className="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <FaArrowLeft />
            Back to Search Results
          </button>
        </div>
      )}

      {/* Question Card */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="p-6">
          <div className="flex gap-4">
            {/* Vote Section */}
            <div className="flex flex-col items-center gap-2 text-gray-600 flex-shrink-0">
              <button className="p-2 hover:bg-gray-100 rounded">
                <FaArrowUp className="text-gray-500" />
              </button>
              <span className="text-2xl font-semibold text-gray-700">
                {question.score || 0}
              </span>
            </div>

            {/* Question Content */}
            <div className="flex-1">
              <h1 className="text-2xl font-semibold text-gray-900 mb-4">
                {question.title}
              </h1>

              <div className="flex gap-4 text-sm text-gray-600 mb-4">
                <div className="flex items-center gap-1">
                  <FaEye />
                  <span>{question.view_count?.toLocaleString() || 0} views</span>
                </div>
              </div>

              {question.body && (
                <div className="prose max-w-none mb-4">
                  <p className="text-gray-700 whitespace-pre-wrap">
                    {stripHtml(question.body).substring(0, 500)}
                    {stripHtml(question.body).length > 500 ? '...' : ''}
                  </p>
                </div>
              )}

              {/* Tags */}
              {question.tags && question.tags.length > 0 && (
                <div className="flex flex-wrap gap-2 mb-4">
                  {question.tags.map((tag, index) => (
                    <span
                      key={index}
                      className="px-3 py-1 bg-blue-100 text-blue-800 text-xs rounded-md"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              )}

              {/* Question Owner */}
              {question.owner && (
                <div className="flex items-center gap-2 text-sm">
                  <div className="bg-so-blue text-white w-8 h-8 rounded flex items-center justify-center font-semibold">
                    {question.owner.display_name?.[0]?.toUpperCase() || 'U'}
                  </div>
                  <div>
                    <div className="text-so-blue font-medium">
                      {question.owner.display_name || 'Unknown User'}
                    </div>
                    {question.owner.reputation && (
                      <div className="text-gray-600 text-xs">
                        {question.owner.reputation.toLocaleString()} reputation
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* View on Stack Overflow */}
              {question.link && (
                <div className="mt-4">
                  <a
                    href={question.link}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-so-blue hover:underline text-sm"
                  >
                    View original on Stack Overflow →
                  </a>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Answers Section */}
      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="p-6">
          {/* Toggle between original and reranked */}
          {hasRerankedAnswers && (
            <div className="mb-6 flex items-center justify-between border-b border-gray-200 pb-4">
              <h2 className="text-xl font-semibold text-gray-900">
                {answers.length} {answers.length === 1 ? 'Answer' : 'Answers'}
              </h2>
              <div className="flex gap-2">
                <button
                  onClick={onToggleReranked}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                    !showReranked
                      ? 'bg-so-blue text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  Original Order
                </button>
                <button
                  onClick={onToggleReranked}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
                    showReranked
                      ? 'bg-so-green text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <FaRobot />
                  AI Reranked
                </button>
              </div>
            </div>
          )}

          {!hasRerankedAnswers && (
            <h2 className="text-xl font-semibold text-gray-900 mb-6 border-b border-gray-200 pb-4">
              {answers.length} {answers.length === 1 ? 'Answer' : 'Answers'}
            </h2>
          )}

          {/* Display notice if showing reranked */}
          {showReranked && hasRerankedAnswers && (
            <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg flex items-start gap-3">
              <FaRobot className="text-so-green flex-shrink-0 mt-1" />
              <div className="text-sm text-gray-700">
                <strong>AI Reranked:</strong> These answers have been reordered by our AI model
                based on relevance, accuracy, clarity, and code quality.
              </div>
            </div>
          )}

          {/* Answers List */}
          {answers.length > 0 ? (
            <AnswersList answers={answers} />
          ) : (
            <div className="text-center py-8 text-gray-500">
              No answers available for this question.
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default QuestionDisplay


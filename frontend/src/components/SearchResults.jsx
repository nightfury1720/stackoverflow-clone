import { useState } from 'react'
import { FaCheckCircle, FaEye, FaComment, FaUser, FaCalendarAlt, FaArrowUp, FaRobot } from 'react-icons/fa'
import { formatDistanceToNow } from 'date-fns'

function SearchResults({ questions, rerankedQuestions, onQuestionClick }) {
  const [sortBy, setSortBy] = useState('relevance') // 'relevance' or 'accuracy'
  
  const displayQuestions = sortBy === 'accuracy' ? rerankedQuestions : questions

  const formatDate = (dateString) => {
    try {
      const date = new Date(dateString * 1000) // Stack Overflow timestamps are in seconds
      return formatDistanceToNow(date, { addSuffix: true })
    } catch {
      return 'recently'
    }
  }

  const formatReputation = (reputation) => {
    if (!reputation) return '0'
    if (reputation >= 1000000) return `${(reputation / 1000000).toFixed(1)}M`
    if (reputation >= 1000) return `${(reputation / 1000).toFixed(1)}k`
    return reputation.toString()
  }

  const stripHtml = (html) => {
    if (!html) return ''
    const tmp = document.createElement('DIV')
    tmp.innerHTML = html
    return tmp.textContent || tmp.innerText || ''
  }

  const getBestAnswer = (question) => {
    if (!question.answers || question.answers.length === 0) return null
    
    // Find accepted answer first
    const acceptedAnswer = question.answers.find(a => a.is_accepted)
    if (acceptedAnswer) return acceptedAnswer
    
    // Otherwise get highest voted answer
    const sortedAnswers = [...question.answers].sort((a, b) => (b.score || 0) - (a.score || 0))
    return sortedAnswers[0]
  }

  if (questions.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-xl font-semibold text-gray-900 mb-4">
          Search Results
        </h3>
        <p className="text-gray-500 text-center py-8">
          No results found. Try refining your search terms.
        </p>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-semibold text-gray-900">
          Search Results ({displayQuestions.length})
        </h3>
        
        {/* Sort Tabs */}
        <div className="flex gap-2">
          <button
            onClick={() => setSortBy('relevance')}
            className={`px-4 py-2 rounded-lg font-medium transition-colors ${
              sortBy === 'relevance'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            Relevance
          </button>
          <button
            onClick={() => setSortBy('accuracy')}
            className={`px-4 py-2 rounded-lg font-medium transition-colors flex items-center gap-2 ${
              sortBy === 'accuracy'
                ? 'bg-green-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            <FaRobot />
            Accuracy (AI)
          </button>
        </div>
      </div>

      {/* AI Reranked Notice */}
      {sortBy === 'accuracy' && (
        <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg flex items-start gap-3">
          <FaRobot className="text-green-600 flex-shrink-0 mt-1" />
          <div className="text-sm text-gray-700">
            <strong>AI Reranked:</strong> These results have been reordered by our AI model
            based on relevance, accuracy, clarity, and answer quality.
          </div>
        </div>
      )}
      
      <div className="space-y-6">
        {displayQuestions.map((question, index) => {
          const bestAnswer = getBestAnswer(question)
          
          return (
            <div
              key={question.id}
              className="border rounded-lg p-5 hover:shadow-md transition-shadow"
            >
              {/* Question Section */}
              <div className="mb-4">
                <div className="flex gap-4">
                  {/* Vote count and status */}
                  <div className="flex-shrink-0 text-center min-w-[60px]">
                    <div className={`text-lg font-semibold ${
                      question.is_answered && question.accepted_answer_id
                        ? 'text-green-600'
                        : 'text-gray-700'
                    }`}>
                      {question.score || 0}
                    </div>
                    <div className="text-xs text-gray-500">votes</div>
                    
                    {/* Accepted answer indicator */}
                    {question.is_answered && question.accepted_answer_id && (
                      <div className="mt-1 flex flex-col items-center justify-center">
                        <FaCheckCircle className="text-green-500 text-sm" />
                        <span className="text-xs text-green-600">Accepted</span>
                      </div>
                    )}
                  </div>

                  {/* Question content */}
                  <div className="flex-1 min-w-0">
                    <a
                      href={question.link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-lg font-medium text-blue-600 hover:text-blue-800 line-clamp-2 mb-2 block"
                    >
                      {question.title}
                    </a>
                    
                    {/* Question excerpt */}
                    {question.body && (
                      <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                        {stripHtml(question.body)}
                      </p>
                    )}

                    {/* Tags */}
                    {question.tags && question.tags.length > 0 && (
                      <div className="flex flex-wrap gap-1 mb-3">
                        {question.tags.slice(0, 5).map((tag, tagIndex) => (
                          <span
                            key={tagIndex}
                            className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded"
                          >
                            {tag}
                          </span>
                        ))}
                        {question.tags.length > 5 && (
                          <span className="px-2 py-1 text-gray-500 text-xs">
                            +{question.tags.length - 5} more
                          </span>
                        )}
                      </div>
                    )}

                    {/* Stats and metadata */}
                    <div className="flex items-center gap-4 text-xs text-gray-500 flex-wrap">
                      <div className="flex items-center gap-1">
                        <FaComment />
                        <span>{question.answer_count || 0} answers</span>
                      </div>
                      <div className="flex items-center gap-1">
                        <FaEye />
                        <span>{question.view_count ? question.view_count.toLocaleString() : 0} views</span>
                      </div>
                      
                      {/* Owner info */}
                      {question.owner && question.owner.display_name && (
                        <div className="flex items-center gap-1">
                          <FaUser />
                          <span>{question.owner.display_name}</span>
                          {question.owner.reputation && (
                            <span className="text-gray-400">
                              ({formatReputation(question.owner.reputation)})
                            </span>
                          )}
                        </div>
                      )}
                      
                      {/* Creation date */}
                      {question.creation_date && (
                        <div className="flex items-center gap-1">
                          <FaCalendarAlt />
                          <span>{formatDate(question.creation_date)}</span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Best Answer Section */}
              {bestAnswer && (
                <div className="ml-0 pl-20 border-l-4 border-green-500">
                  <div className="bg-green-50 rounded-lg p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <FaCheckCircle className="text-green-600" />
                      <h4 className="font-semibold text-gray-900">
                        {bestAnswer.is_accepted ? 'Accepted Answer' : 'Top Answer'}
                      </h4>
                      <div className="flex items-center gap-1 text-sm text-gray-600">
                        <FaArrowUp className="text-green-600" />
                        <span className="font-medium">{bestAnswer.score || 0} votes</span>
                      </div>
                    </div>
                    
                    <div className="text-sm text-gray-700 line-clamp-4">
                      {stripHtml(bestAnswer.body)}
                    </div>

                    {/* Answer owner */}
                    {bestAnswer.owner && bestAnswer.owner.display_name && (
                      <div className="mt-3 flex items-center gap-2 text-xs text-gray-600">
                        <FaUser />
                        <span>{bestAnswer.owner.display_name}</span>
                        {bestAnswer.owner.reputation && (
                          <span className="text-gray-400">
                            ({formatReputation(bestAnswer.owner.reputation)})
                          </span>
                        )}
                      </div>
                    )}

                    <a
                      href={question.link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="mt-3 inline-block text-blue-600 hover:text-blue-800 text-sm font-medium"
                    >
                      View full answer on Stack Overflow →
                    </a>
                  </div>
                </div>
              )}

              {/* No answer message */}
              {!bestAnswer && (
                <div className="ml-0 pl-20">
                  <div className="bg-gray-50 rounded-lg p-4 text-sm text-gray-500">
                    No answers available yet. 
                    <a
                      href={question.link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="ml-1 text-blue-600 hover:text-blue-800 font-medium"
                    >
                      View on Stack Overflow →
                    </a>
                  </div>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}

export default SearchResults


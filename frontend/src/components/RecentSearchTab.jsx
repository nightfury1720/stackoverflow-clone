import { FaHistory, FaSearch } from 'react-icons/fa'
import { formatDistanceToNow } from 'date-fns'

function RecentSearchTab({ recentQuestions, onQuestionClick }) {
  const formatDate = (dateString) => {
    try {
      const date = new Date(dateString)
      return formatDistanceToNow(date, { addSuffix: true })
    } catch {
      return 'recently'
    }
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-4 sticky top-4">
      <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
        <FaHistory className="text-gray-600" />
        Recent Searches
      </h3>
      
      {recentQuestions.length === 0 ? (
        <div className="text-center py-8">
          <FaSearch className="mx-auto h-8 w-8 text-gray-400 mb-2" />
          <p className="text-sm text-gray-500">
            No recent searches yet. Start searching to see your history here!
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {recentQuestions.slice(0, 10).map((question, index) => (
            <button
              key={`${question.id}-${question.searched_at || index}`}
              onClick={() => onQuestionClick(question)}
              className="w-full text-left p-3 rounded-lg hover:bg-gray-50 border border-gray-200 transition-colors group"
            >
              <h4 className="text-sm font-medium text-gray-900 line-clamp-2 group-hover:text-blue-600 mb-2">
                {question.title}
              </h4>
              
              {question.tags && question.tags.length > 0 && (
                <div className="flex flex-wrap gap-1 mb-2">
                  {question.tags.slice(0, 3).map((tag, tagIndex) => (
                    <span
                      key={tagIndex}
                      className="px-2 py-0.5 bg-blue-50 text-blue-700 text-xs rounded"
                    >
                      {tag}
                    </span>
                  ))}
                  {question.tags.length > 3 && (
                    <span className="px-2 py-0.5 text-gray-500 text-xs">
                      +{question.tags.length - 3}
                    </span>
                  )}
                </div>
              )}
              
              <div className="flex items-center justify-between text-xs text-gray-500">
                <div className="flex items-center gap-2">
                  <span>{question.score || 0} votes</span>
                  <span>•</span>
                  <span>{question.answer_count || 0} answers</span>
                </div>
                
                {question.searched_at && (
                  <span className="text-gray-400">
                    {formatDate(question.searched_at)}
                  </span>
                )}
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

export default RecentSearchTab

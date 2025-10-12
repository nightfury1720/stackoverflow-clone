import { FaClock } from 'react-icons/fa'
import { formatDistanceToNow } from 'date-fns'

function RecentQuestions({ questions, onQuestionClick }) {
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
        <FaClock className="text-gray-600" />
        Recently Asked Questions
      </h3>
      
      {questions.length === 0 ? (
        <p className="text-sm text-gray-500">
          No recently asked questions yet. Start by searching for a question!
        </p>
      ) : (
        <div className="space-y-3">
          {questions.map((question, index) => (
            <button
              key={`${question.id}-${question.searched_at || index}`}
              onClick={() => onQuestionClick(question)}
              className="w-full text-left p-3 rounded-lg hover:bg-gray-50 border border-gray-200 transition-colors group"
            >
              <h4 className="text-sm font-medium text-gray-900 line-clamp-2 group-hover:text-so-blue">
                {question.title}
              </h4>
              
              {question.tags && question.tags.length > 0 && (
                <div className="flex flex-wrap gap-1 mt-2">
                  {question.tags.slice(0, 2).map((tag, tagIndex) => (
                    <span
                      key={tagIndex}
                      className="px-2 py-0.5 bg-blue-50 text-blue-700 text-xs rounded"
                    >
                      {tag}
                    </span>
                  ))}
                  {question.tags.length > 2 && (
                    <span className="px-2 py-0.5 text-gray-500 text-xs">
                      +{question.tags.length - 2}
                    </span>
                  )}
                </div>
              )}
              
              <div className="mt-2 flex items-center gap-3 text-xs text-gray-500">
                <span>{question.score || 0} votes</span>
                <span>{question.answer_count || 0} answers</span>
              </div>
              
              {question.searched_at && (
                <div className="mt-1 text-xs text-gray-400">
                  {formatDate(question.searched_at)}
                </div>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

export default RecentQuestions


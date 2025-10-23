import { FaHistory, FaSearch } from 'react-icons/fa'
import { formatDistanceToNow } from 'date-fns'

function RecentSearchTab({ recentQuestions }) {
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
          {recentQuestions.slice(0, 10).map((search, index) => (
            <div
              key={`${search.id}-${search.searched_at || index}`}
              className="border rounded-lg p-3 bg-gray-50"
            >
              <div className="flex items-start gap-3">
                {/* Search icon */}
                <div className="flex-shrink-0 mt-1">
                  <FaSearch className="text-gray-400 text-sm" />
                </div>

                {/* Search query content */}
                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-medium text-gray-700 line-clamp-2 mb-2">
                    {search.search_query}
                  </h4>
                  
                  {/* Search timestamp */}
                  {search.searched_at && (
                    <div className="text-xs text-gray-500">
                      {formatDate(search.searched_at)}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default RecentSearchTab



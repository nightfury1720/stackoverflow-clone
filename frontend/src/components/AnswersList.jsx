import { FaArrowUp, FaCheckCircle } from 'react-icons/fa'

function AnswersList({ answers }) {
  const stripHtml = (html) => {
    const tmp = document.createElement('DIV')
    tmp.innerHTML = html
    return tmp.textContent || tmp.innerText || ''
  }

  return (
    <div className="space-y-6">
      {answers.map((answer, index) => (
        <div
          key={answer.answer_id || index}
          className={`border-l-4 pl-6 py-4 ${
            answer.is_accepted
              ? 'border-so-green bg-green-50'
              : 'border-gray-200'
          }`}
        >
          <div className="flex gap-4">
            {/* Vote Section */}
            <div className="flex flex-col items-center gap-2 text-gray-600 flex-shrink-0">
              <button className="p-2 hover:bg-gray-100 rounded">
                <FaArrowUp className="text-gray-500" />
              </button>
              <span className="text-xl font-semibold text-gray-700">
                {answer.score || 0}
              </span>
              {answer.is_accepted && (
                <FaCheckCircle className="text-so-green text-2xl" title="Accepted Answer" />
              )}
            </div>

            {/* Answer Content */}
            <div className="flex-1">
              {answer.is_accepted && (
                <div className="mb-2 inline-flex items-center gap-2 px-3 py-1 bg-so-green text-white text-xs font-semibold rounded-full">
                  <FaCheckCircle />
                  Accepted Answer
                </div>
              )}

              <div className="prose max-w-none mb-4">
                <p className="text-gray-700 whitespace-pre-wrap">
                  {stripHtml(answer.body || '').substring(0, 600)}
                  {stripHtml(answer.body || '').length > 600 ? '...' : ''}
                </p>
              </div>

              {/* Answer Owner */}
              {answer.owner && (
                <div className="flex items-center gap-2 text-sm">
                  <div className="bg-gray-600 text-white w-8 h-8 rounded flex items-center justify-center font-semibold">
                    {answer.owner.display_name?.[0]?.toUpperCase() || 'U'}
                  </div>
                  <div>
                    <div className="text-gray-900 font-medium">
                      {answer.owner.display_name || 'Unknown User'}
                    </div>
                    {answer.owner.reputation && (
                      <div className="text-gray-600 text-xs">
                        {answer.owner.reputation.toLocaleString()} reputation
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}

export default AnswersList


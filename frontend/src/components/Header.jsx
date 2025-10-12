function Header() {
  return (
    <header className="bg-so-black border-t-4 border-so-orange shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-14">
          <div className="flex items-center">
            <svg
              className="h-8 w-auto text-so-orange"
              viewBox="0 0 120 120"
              fill="currentColor"
            >
              <path d="M84.4 93.8V70.6h7.7v30.9H22.6V70.6h7.7v23.2z" />
              <path d="M38.8 68.4l37.8 7.9 1.6-7.6-37.8-7.9-1.6 7.6zm5-18l35 16.3 3.2-7-35-16.4-3.2 7.1zm9.7-17.2l29.7 24.7 4.9-5.9-29.7-24.7-4.9 5.9zm19.2-18.3l-6.2 4.6 23 31 6.2-4.6-23-31zM38 86h38.6v-7.7H38V86z" />
            </svg>
            <h1 className="ml-3 text-xl font-bold text-white">
              Stack Overflow <span className="text-so-orange font-normal">Clone</span>
            </h1>
          </div>
          <div className="text-sm text-gray-400">
            Powered by AI Reranking
          </div>
        </div>
      </div>
    </header>
  )
}

export default Header


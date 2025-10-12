import { describe, it, expect, vi, beforeEach } from 'vitest'
import axios from 'axios'
import { searchQuestion, getRecentQuestions } from '../api'

vi.mock('axios')

describe('API Service', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('searchQuestion', () => {
    it('posts question to search endpoint', async () => {
      const mockResponse = {
        data: {
          question: { id: 123, title: 'Test Question' },
          answers: [],
          reranked_answers: []
        }
      }
      
      axios.create.mockReturnValue({
        post: vi.fn().mockResolvedValue(mockResponse)
      })

      const result = await searchQuestion('test question')

      expect(result).toEqual(mockResponse.data)
    })

    it('handles search errors', async () => {
      const mockError = new Error('Network error')
      
      axios.create.mockReturnValue({
        post: vi.fn().mockRejectedValue(mockError)
      })

      await expect(searchQuestion('test')).rejects.toThrow('Network error')
    })
  })

  describe('getRecentQuestions', () => {
    it('fetches recent questions from API', async () => {
      const mockQuestions = [
        { id: 123, title: 'Question 1' },
        { id: 456, title: 'Question 2' }
      ]
      
      axios.create.mockReturnValue({
        get: vi.fn().mockResolvedValue({ data: { questions: mockQuestions } })
      })

      const result = await getRecentQuestions()

      expect(result).toEqual(mockQuestions)
    })

    it('handles fetch errors', async () => {
      axios.create.mockReturnValue({
        get: vi.fn().mockRejectedValue(new Error('API error'))
      })

      await expect(getRecentQuestions()).rejects.toThrow('API error')
    })
  })
})



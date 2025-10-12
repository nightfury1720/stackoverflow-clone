import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const searchQuestion = async (question) => {
  try {
    const response = await api.post('/questions/search', { question });
    return response.data;
  } catch (error) {
    console.error('Error searching question:', error);
    throw error;
  }
};

export const searchSimilarQuestions = async (question) => {
  try {
    const response = await api.post('/questions/search-similar', { question });
    return {
      questions: response.data.questions,
      rerankedQuestions: response.data.reranked_questions
    };
  } catch (error) {
    console.error('Error searching similar questions:', error);
    throw error;
  }
};

export const getRecentQuestions = async () => {
  try {
    const response = await api.get('/questions/recent');
    return response.data.questions;
  } catch (error) {
    console.error('Error fetching recent questions:', error);
    throw error;
  }
};

export default api;


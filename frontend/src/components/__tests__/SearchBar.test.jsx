import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import SearchBar from '../SearchBar'

describe('SearchBar', () => {
  it('renders search input and button', () => {
    render(<SearchBar onSearch={vi.fn()} loading={false} />)
    
    expect(screen.getByPlaceholderText(/enter your programming question/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /search/i })).toBeInTheDocument()
  })

  it('calls onSearch when form is submitted with valid query', () => {
    const mockOnSearch = vi.fn()
    render(<SearchBar onSearch={mockOnSearch} loading={false} />)
    
    const input = screen.getByPlaceholderText(/enter your programming question/i)
    const button = screen.getByRole('button', { name: /search/i })
    
    fireEvent.change(input, { target: { value: 'How to reverse a string' } })
    fireEvent.click(button)
    
    expect(mockOnSearch).toHaveBeenCalledWith('How to reverse a string')
  })

  it('does not call onSearch when query is empty', () => {
    const mockOnSearch = vi.fn()
    render(<SearchBar onSearch={mockOnSearch} loading={false} />)
    
    const button = screen.getByRole('button', { name: /search/i })
    fireEvent.click(button)
    
    expect(mockOnSearch).not.toHaveBeenCalled()
  })

  it('trims whitespace from query', () => {
    const mockOnSearch = vi.fn()
    render(<SearchBar onSearch={mockOnSearch} loading={false} />)
    
    const input = screen.getByPlaceholderText(/enter your programming question/i)
    const button = screen.getByRole('button', { name: /search/i })
    
    fireEvent.change(input, { target: { value: '  test query  ' } })
    fireEvent.click(button)
    
    expect(mockOnSearch).toHaveBeenCalledWith('test query')
  })

  it('disables button when loading', () => {
    render(<SearchBar onSearch={vi.fn()} loading={true} />)
    
    const button = screen.getByRole('button', { name: /searching/i })
    expect(button).toBeDisabled()
  })

  it('disables input when loading', () => {
    render(<SearchBar onSearch={vi.fn()} loading={true} />)
    
    const input = screen.getByPlaceholderText(/enter your programming question/i)
    expect(input).toBeDisabled()
  })
})



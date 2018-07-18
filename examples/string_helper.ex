defmodule StringHelper do
  def palindrome?(term) do
     String.reverse(term) == term
  end
end

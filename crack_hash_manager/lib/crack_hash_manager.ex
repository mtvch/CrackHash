defmodule CrackHashManager do
  @moduledoc """
  Менеджер для взлома паролей методом брут форса. Распределяет задачи между воркерами.
  """

  @doc """
  Функция для получения зависимостей приложения. Выкидывает исключение, если зависимость не определена.

  Зависимости определены в конфиге в виде
  ```elixir
  config :crack_hash_manager, :key,
    inner_key: "value1"
  ```
  """
  @spec fetch_env!(any(), any()) :: any()
  def fetch_env!(key, inner_key) do
    Application.fetch_env!(:crack_hash_manager, key)[inner_key]
  end
end

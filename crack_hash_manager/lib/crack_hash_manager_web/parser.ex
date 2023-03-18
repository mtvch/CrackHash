defmodule CrackHashManagerWeb.Parser do
  @moduledoc """
  Модуль содержит логику для парсинга запросов в сервис
  """

  @doc """
  Парсит запрос пользователя на взлом хэша.
  На вход принимает мапу, в которую был распарсен JSON. Валидирует мапу и извлекает данные
  """
  @spec parse_user_crack_request(map()) ::
          %{hash: String.t(), max_length: integer()} | {:error, :bad_params}
  def parse_user_crack_request(body)

  def parse_user_crack_request(%{"hash" => hash, "maxLength" => max_length})
      when is_binary(hash) and is_integer(max_length) do
    %{hash: hash, max_length: max_length}
  end

  def parse_user_crack_request(_), do: {:error, :bad_params}

  @doc """
  Парсит запрос пользователя на получение статуса по запросу.
  На вход принимает мапу. Валидирует мапу и извлекает данные
  """
  @spec parse_user_status_request(map()) :: %{request_id: String.t()} | {:error, :bad_params}
  def parse_user_status_request(query_params)

  def parse_user_status_request(%{"requestId" => request_id}) when is_binary(request_id) do
    %{request_id: request_id}
  end

  def parse_user_status_request(_), do: {:error, :bad_params}

  @doc """
  Парсит ответ воркера по взлому хэша.
  На вход принимает строку. Ее парсит как xml в мапу, валидирует мапу и извлекает данные
  """
  @spec parse_worker_response(String.t()) ::
          %{words_answers: [String.t()], part_number: integer(), request_id: String.t()}
          | {:error, :bad_params}
  def parse_worker_response(xml_body) when is_binary(xml_body) do
    case XmlToMap.naive_map(xml_body) do
      %{
        "CrackHashWorkerResponse" => %{
          "#content" => %{
            "Answers" => %{"words" => words_answers},
            "PartNumber" => part_number,
            "RequestId" => request_id
          }
        }
      } ->
        %{
          words_answers: List.wrap(words_answers),
          part_number: String.to_integer(part_number),
          request_id: request_id
        }

      _e ->
        {:error, :bad_params}
    end
  end
end

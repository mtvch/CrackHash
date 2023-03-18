defmodule CrackHashWorkerWeb.Parser do
  @moduledoc """
  Модуль содержит логику для парсинга запросов в сервис
  """

  alias CrackHashWorker.Worker

  @doc """
  Парсит запрос от менеджера по взлому хэша.
  На вход принимает строку. Ее парсит как xml в мапу, валидирует мапу и извлекает данные
  """
  @spec parse_manager_request(String.t()) :: Worker.DTO.t() | {:error, :bad_params}
  def parse_manager_request(xml_body) when is_binary(xml_body) do
    with %{
           "CrackHashManagerRequest" => %{
             "#content" => %{
               "RequestId" => request_id,
               "PartNumber" => part_number,
               "PartCount" => part_count,
               "Hash" => hash,
               "MaxLength" => max_length,
               "Alphabet" => %{"symbols" => alphabet}
             }
           }
         } <- XmlToMap.naive_map(xml_body),
         {part_number, _} <- Integer.parse(part_number),
         {part_count, _} <- Integer.parse(part_count),
         {max_length, _} <- Integer.parse(max_length) do
      %Worker.DTO{
        request_id: request_id,
        part_number: part_number,
        part_count: part_count,
        hash: hash,
        max_length: max_length,
        alphabet: alphabet
      }
    else
      _error ->
        {:error, :bad_params}
    end
  end
end

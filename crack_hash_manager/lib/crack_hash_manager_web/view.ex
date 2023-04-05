defmodule CrackHashManagerWeb.View do
  @moduledoc """
  Данный модуль собирает тело ответа на запрос из результата работы модели
  """
  @error_codes_to_messages %{
    bad_params: "Bad params",
    not_found: "Not found"
  }

  @dir "lib/crack_hash_manager_web/view"
  @worker_ok_response_template_path "#{@dir}/worker_ok_response_template.xml.eex"
  @worker_ok_response_template File.read!(@worker_ok_response_template_path)
  @external_resource @worker_ok_response_template_path
  @worker_error_response_template_path "#{@dir}/worker_error_response_template.xml.eex"
  @worker_error_response_template File.read!(@worker_error_response_template_path)
  @external_resource @worker_error_response_template_path

  @doc """
  Возвращает закодированный json - успешный ответ пользователю
  """
  @spec ok_user_crack_json_response(String.t()) :: binary()
  def ok_user_crack_json_response(request_id) when is_binary(request_id) do
    ok_json(%{"request_id" => request_id})
  end

  @doc """
  Возвращает закодированный json - ответ пользователю в случае ошибки
  """
  @spec error_user_crack_json_response({:error, atom()}) :: binary()
  def error_user_crack_json_response({:error, error_code}) do
    error_json(%{"error" => error_code_to_message(error_code)})
  end

  @doc """
  Возвращает закодированный json - успешный ответ пользователю
  """
  @spec ok_user_status_json_response([String.t()]) :: binary()
  def ok_user_status_json_response(results) when is_list(results) do
    ok_json(%{"data" => results, "status" => "READY"})
  end

  @doc """
  Возвращает закодированный json - ответ пользователю со статусом IN_PROGRESS
  """
  @spec in_progress_user_status_json_response() :: binary()
  def in_progress_user_status_json_response do
    ok_json(%{"data" => nil, "status" => "IN_PROGRESS"})
  end

  @doc """
  Возвращает закодированный json - ответ пользователю в случае ошибки
  """
  @spec error_user_status_json_response({:error, atom()}) :: binary()
  def error_user_status_json_response({:error, error_code}) do
    error_json(%{"error" => error_code_to_message(error_code)})
  end

  @doc """
  Возвращает закодированный xml - ответ воркеру в случае успеха
  """
  @spec ok_worker_xml_response(String.t()) :: binary()
  def ok_worker_xml_response(request_id) when is_binary(request_id) do
    EEx.eval_string(@worker_ok_response_template, assigns: [request_id: request_id])
  end

  @doc """
  Возвращает закодированный xml - ответ воркеру в случае неудачи
  """
  @spec error_worker_xml_response({:error, atom()}) :: binary()
  def error_worker_xml_response({:error, error_code}) do
    EEx.eval_string(@worker_error_response_template,
      assigns: [
        error: error_code_to_message(error_code)
      ]
    )
  end

  defp ok_json(res) do
    res
    |> Map.put("ok", true)
    |> Poison.encode!()
  end

  defp error_json(res) do
    res
    |> Map.put("ok", false)
    |> Poison.encode!()
  end

  defp error_code_to_message(error_code) do
    @error_codes_to_messages[error_code] || "Unknown error"
  end
end

defmodule CrackHashWorkerWeb.View do
  @moduledoc """
  Данный модуль собирает тело ответа на запрос из результата работы модели
  """
  @error_codes_to_messages %{
    bad_params: "Bad params"
  }

  @dir "lib/crack_hash_worker_web/view"
  @manager_ok_response_template_path "#{@dir}/manager_ok_response_template.xml.eex"
  @manager_ok_response_template File.read!(@manager_ok_response_template_path)
  @external_resource @manager_ok_response_template_path
  @manager_error_response_template_path "#{@dir}/manager_error_response_template.xml.eex"
  @manager_error_response_template File.read!(@manager_error_response_template_path)
  @external_resource @manager_error_response_template_path

  @doc """
  Возвращает закодированный xml - ответ менеджеру в случае успеха
  """
  @spec ok_manager_xml_response(String.t()) :: binary()
  def ok_manager_xml_response(request_id) when is_binary(request_id) do
    EEx.eval_string(@manager_ok_response_template, assigns: [request_id: request_id])
  end

  @doc """
  Возвращает закодированный xml - ответ менеджеру в случае неудачи
  """
  @spec error_manager_xml_response({:error, atom()}) :: binary()
  def error_manager_xml_response({:error, error_code}) do
    EEx.eval_string(@manager_error_response_template,
      assigns: [
        error: error_code_to_message(error_code)
      ]
    )
  end

  defp error_code_to_message(error_code) do
    @error_codes_to_messages[error_code] || "Unknown error"
  end
end

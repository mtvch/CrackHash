defmodule CrackHashWorkerWeb.ViewTest do
  use ExUnit.Case, async: true

  alias CrackHashWorkerWeb.View

  @dir "test/crack_hash_worker_web/view_test"
  @expected_manager_ok_response "#{@dir}/expected_manager_ok_response.xml" |> File.read!()
  @expected_manager_error_response "#{@dir}/expected_manager_error_response.xml"
                                   |> File.read!()

  test "Успешный ответ воркеру" do
    request_id = "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"
    encoded_xml_response = View.ok_manager_xml_response(request_id)

    assert XmlToMap.naive_map(encoded_xml_response) ==
             XmlToMap.naive_map(@expected_manager_ok_response)
  end

  test "Ответ воркеру: ошибка" do
    error = {:error, :bad_params}
    encoded_xml_response = View.error_manager_xml_response(error)

    assert XmlToMap.naive_map(encoded_xml_response) ==
             XmlToMap.naive_map(@expected_manager_error_response)
  end
end

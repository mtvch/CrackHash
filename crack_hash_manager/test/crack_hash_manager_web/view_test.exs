defmodule CrackHashManagerWeb.ViewTest do
  use ExUnit.Case, async: true

  alias CrackHashManagerWeb.View

  @dir "test/crack_hash_manager_web/view_test"
  @expected_user_crack_ok_response "#{@dir}/expected_user_crack_ok_response.json" |> File.read!()
  @expected_user_crack_error_response "#{@dir}/expected_user_crack_error_response.json"
                                      |> File.read!()
  @expected_user_status_ok_response "#{@dir}/expected_user_status_ok_response.json"
                                    |> File.read!()
  @expected_user_status_in_progress_response "#{@dir}/expected_user_status_in_progress_response.json"
                                             |> File.read!()
  @expected_user_status_error_response "#{@dir}/expected_user_status_error_response.json"
                                       |> File.read!()
  @expected_worker_ok_response "#{@dir}/expected_worker_ok_response.xml" |> File.read!()
  @expected_worker_error_response "#{@dir}/expected_worker_error_response.xml" |> File.read!()

  test "Успешный ответ пользователю на заявку на взлом" do
    request_id = "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"
    encoded_json_response = View.ok_user_crack_json_response(request_id)

    assert Poison.decode!(@expected_user_crack_ok_response) ==
             Poison.decode!(encoded_json_response)
  end

  test "Ошибка в ответ пользователю на заявку на взлом" do
    encoded_json_response = View.error_user_crack_json_response({:error, :bad_params})

    assert Poison.decode!(@expected_user_crack_error_response) ==
             Poison.decode!(encoded_json_response)
  end

  test "Успешный ответ пользовател: статус READY" do
    encoded_json_response = View.ok_user_status_json_response(["SOME", "WORD"])

    assert Poison.decode!(@expected_user_status_ok_response) ==
             Poison.decode!(encoded_json_response)
  end

  test "Ответ пользователю: статус IN_PROGRESS" do
    encoded_json_response = View.in_progress_user_status_json_response()

    assert Poison.decode!(@expected_user_status_in_progress_response) ==
             Poison.decode!(encoded_json_response)
  end

  test "Ошибка в ответ пользователю на запрос по статусу" do
    encoded_json_response = View.error_user_status_json_response({:error, :not_found})

    assert Poison.decode!(@expected_user_status_error_response) ==
             Poison.decode!(encoded_json_response)
  end

  test "Успешный ответ воркеру" do
    request_id = "ec8a4d9a-bfc4-11ed-b9a2-acde48001122"
    encoded_xml_response = View.ok_worker_xml_response(request_id)

    assert XmlToMap.naive_map(encoded_xml_response) ==
             XmlToMap.naive_map(@expected_worker_ok_response)
  end

  test "Ответ воркеру: ошибка" do
    error = {:error, :bad_params}
    encoded_xml_response = View.error_worker_xml_response(error)

    assert XmlToMap.naive_map(encoded_xml_response) ==
             XmlToMap.naive_map(@expected_worker_error_response)
  end
end

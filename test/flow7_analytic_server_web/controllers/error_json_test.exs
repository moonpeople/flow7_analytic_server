defmodule Flow7AnalyticServerWeb.ErrorJSONTest do
  use Flow7AnalyticServerWeb.ConnCase, async: true

  test "renders 404" do
    assert Flow7AnalyticServerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Flow7AnalyticServerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

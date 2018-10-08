defmodule Appsignal.Phoenix.ErrorExtracterTest do
  use ExUnit.Case

  alias Appsignal.ErrorHandler

  @template_undefined_error %Phoenix.Template.UndefinedError{
    assigns: %{
      appsignal_transaction: %{},
      conn: %Plug.Conn{
        adapter: {Plug.Adapters.Cowboy.Conn},
        assigns: %{
          appsignal_transaction: %{},
          kind: :error,
          layout: false,
          reason: %ArgumentError{message: "cannot convert nil to param"},
          stack: [
            {Phoenix.Param.Atom, :to_param, 1, [file: 'lib/phoenix/param.ex', line: 67]},
            {WebApp.Router.Helpers, :shop_path, 4, [file: 'web/router.ex', line: 1]},
            {WebApp.CommonView, :"-deal.html/1-fun-0-", 1,
             [file: 'web/templates/common/deal.html.eex', line: 73]},
            {Appsignal.Helpers, :instrument, 6, [file: 'lib/appsignal/helpers.ex', line: 62]},
            {WebApp.ShopView, :"-index.html/1-fun-0-", 3,
             [file: 'web/templates/shop/index.html.eex', line: 41]},
            {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1623]},
            {WebApp.ShopView, :"-index.html/1-fun-1-", 1,
             [file: 'web/templates/shop/index.html.eex', line: 40]},
            {Appsignal.Helpers, :instrument, 6, [file: 'lib/appsignal/helpers.ex', line: 62]}
          ]
        },
        body_params: %{},
        cookies: %{"_ga" => "GA1.2.482501175.1465550805", "_gat" => "1"},
        halted: false,
        host: "dloky.com",
        method: "GET",
        params: %{"slug" => "museedulouvre"},
        path_info: ["museedulouvre"],
        port: 80,
        private: %{
          WebApp.Router => {[], %{}},
          :phoenix_endpoint => WebApp.Endpoint,
          :phoenix_flash => %{},
          :phoenix_format => "html",
          :phoenix_layout => false,
          :phoenix_pipelines => [:browser],
          :phoenix_router => WebApp.Router,
          :phoenix_template => "500.html",
          :phoenix_view => WebApp.ErrorView,
          :plug_session => %{},
          :plug_session_fetch => :done
        },
        query_params: %{},
        query_string: "",
        remote_ip: {83, 161, 244, 147},
        req_cookies: %{"_ga" => "GA1.2.482501175.1465550805", "_gat" => "1"},
        req_headers: [
          {"x-real-ip", "83.161.244.147"},
          {"host", "dloky.com"},
          {"x-forwarded-for", "83.161.244.147"},
          {"connection", "upgrade"},
          {"upgrade-insecure-requests", "1"},
          {"user-agent",
           "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36"},
          {"accept",
           "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"},
          {"referer", "https://dloky.com/"},
          {"accept-encoding", "gzip, deflate, sdch, br"},
          {"accept-language", "nl,en-US;q=0.8,en;q=0.6,de;q=0.4,da;q=0.2,und;q=0.2"},
          {"cookie", "_ga=GA1.2.482501175.1465550805; _gat=1"}
        ],
        request_path: "/museedulouvre",
        resp_body: nil,
        resp_cookies: %{},
        resp_headers: [
          {"cache-control", "no-transform,public,max-age=300,s-maxage=900"},
          {"x-request-id", "ik1ecud4linl98i2feaio3g7slo42om7"},
          {"x-frame-options", "SAMEORIGIN"},
          {"x-xss-protection", "1; mode=block"},
          {"x-content-type-options", "nosniff"}
        ],
        scheme: :http,
        script_name: [],
        secret_key_base: "uZ/hV9YD9lIF6TenwPBsmTKqc0tVJDtZRp28AzpeSfqPsJ9JvCa8CBHwkXVEKE2R",
        state: :unset,
        status: 500
      },
      kind: :error,
      reason: %ArgumentError{message: "cannot convert nil to param"},
      stack: [
        {Phoenix.Param.Atom, :to_param, 1, [file: 'lib/phoenix/param.ex', line: 67]},
        {WebApp.Router.Helpers, :shop_path, 4, [file: 'web/router.ex', line: 1]},
        {WebApp.CommonView, :"-deal.html/1-fun-0-", 1,
         [file: 'web/templates/common/deal.html.eex', line: 73]},
        {Appsignal.Helpers, :instrument, 6, [file: 'lib/appsignal/helpers.ex', line: 62]},
        {WebApp.ShopView, :"-index.html/1-fun-0-", 3,
         [file: 'web/templates/shop/index.html.eex', line: 41]},
        {Enum, :"-reduce/3-lists^foldl/2-0-", 3, [file: 'lib/enum.ex', line: 1623]},
        {WebApp.ShopView, :"-index.html/1-fun-1-", 1,
         [file: 'web/templates/shop/index.html.eex', line: 40]},
        {Appsignal.Helpers, :instrument, 6, [file: 'lib/appsignal/helpers.ex', line: 62]}
      ],
      template_not_found: WebApp.ErrorView,
      view_module: WebApp.ErrorView,
      view_template: "500.html"
    },
    available: ["error.html"],
    module: WebApp.ErrorView,
    pattern: "*",
    root: "web/templates/error",
    template: "500.html"
  }

  test "Phoenix.Template.UndefinedError" do
    {r, m} = ErrorHandler.extract_reason_and_message(@template_undefined_error, "Template error")
    assert "ArgumentError" == r
    assert "Template error: cannot convert nil to param" == m
  end
end

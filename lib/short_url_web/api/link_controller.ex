defmodule ShortUrlWeb.API.LinkController do
  use ShortUrlWeb, :controller
  alias ShortUrl.Link

  def shorten(conn, %{"url" => url} = params) do
    # * 获取一个 url url = http://a.com
    # * 一个数组，如果是数组循环调用 shorten 方法 url = ["http://a.com", "http://b.com"]

    result = do_shorten(url)
    do_handle_result(conn, result)
  end

  def original(conn, %{"url" => url} = params) do
    case Link.lengthen(url) do
      {:ok, original_url} ->
        json(conn, %{
          success: true,
          data: %{url: url, originalUrl: original_url}
        })

      {:error, :url_invalid} ->
        message = "请输入正确的网址"
        fail(conn, message)

      {:error, :keyword_not_exist} ->
        message = "不存在此短连接"
        fail(conn, message)

      {:error, _} ->
        message = "未知异常"
        fail(conn, message)
    end
  end

  defp do_shorten(result) when is_list(result) do
    short_url_domain = Application.get_env(:short_url, :short_url_domain)

    case result
         |> Enum.all?(fn k -> Link.handle_validate_input_value(k, "", short_url_domain) == :ok end) do
      true -> result |> Enum.map(fn k -> do_shorten(k) end)
      false -> {:error, :list_invalid}
    end
  end

  defp do_shorten(base_url) when is_binary(base_url) do
    short_url_domain = Application.get_env(:short_url, :short_url_domain)

    short_url_domain =
      if String.ends_with?(short_url_domain, "/") do
        short_url_domain
      else
        short_url_domain <> "/"
      end

    case Link.shorten(base_url, "", short_url_domain) do
      re when is_binary(re) ->
        result = short_url_domain <> re

        %{
          url: base_url,
          shortUrl: result
        }

      {:error, :input_is_short_url} ->
        {:error, :input_is_short_url}

      {:error, :url_invalid} ->
        {:error, :url_invalid}

      {:error, _} ->
        {:error, :invalid}
    end
  end

  defp do_shorten(_), do: {:error, :invalid}

  defp do_handle_result(conn, {:error, :url_invalid}), do: fail(conn, "请输入正确的网址")
  defp do_handle_result(conn, {:error, :input_is_short_url}), do: fail(conn, "不能输入转化后的短链接！")
  defp do_handle_result(conn, {:error, :list_invalid}), do: fail(conn, "数据内有 URL 不符合规范")
  defp do_handle_result(conn, {:error, :invalid}), do: fail(conn, "未知异常")

  defp do_handle_result(conn, res) do
    json(conn, %{
      success: true,
      data: res
    })
  end

  defp fail(conn, message) do
    json(conn, %{
      success: false,
      errorMessage: message
    })
  end
end

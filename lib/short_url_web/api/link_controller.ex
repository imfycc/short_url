defmodule ShortUrlWeb.API.LinkController do
  use ShortUrlWeb, :controller
  alias ShortUrl.Link

  def shorten(conn, %{"url" => url} = param) do
    url = String.trim(url)
    hostname = ShortUrlWeb.Router.Helpers.url(conn)

    case Link.shorten(url, "", hostname) do
      re when is_binary(re) ->
        result = hostname <> "/" <> re
        json conn, %{
          success: true,
          data: %{url: url, shortUrl: result}
        }
      {:error, :input_is_short_url} ->
        message = "不能输入转化后的短链接！"
        fail(conn, message)
      {:error, :url_invalid} ->
        message = "请输入正确的网址"
        fail(conn, message)
      {:error, _} ->
        message = "未知异常"
        fail(conn, message)
    end
  end

  def shorten(conn, _) do
    message = "参数错误"
    fail(conn, message)
  end

  def lengthen(conn, %{"url" => url} = param) do
    url = String.trim(url)

    case Link.lengthen(url) do
      {:ok, lurl} ->
        result = lurl
        json conn, %{
          success: true,
          data: %{url: url, longUrl: result}
      }
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

  def lengthen(conn, _) do
    message = "参数错误"
    fail(conn, message)
  end

  defp fail(conn, message) do
    json conn, %{
      success: false,
      errorMessage: message
    }
  end
end

defmodule ShortUrlWeb.LinkController do
  use ShortUrlWeb, :controller
  alias ShortUrl.Link

  def index(conn, _) do
    conn
    |> render("index.html", url: "", short_url: "", custom_keyword: "")
  end

  def create(conn, %{"url" => url, "custom_keyword" => custom_keyword}) do
    url = String.trim(url)
    custom_keyword = String.trim(custom_keyword)

    hostname = ShortUrlWeb.Router.Helpers.url(conn)

    case Link.shorten(url, custom_keyword, hostname) do
      re when is_binary(re) ->
        result = hostname <> "/" <> re
        render(conn, "index.html", url: url, short_url: result, custom_keyword: "")

      {:error, :custom_keyword_length_beyond} ->
        message = "短码的长度不能超过6位!"
        render_flash(conn, message, url, "")

      {:error, :custom_keyword_invalid} ->
        message = "请按要求输入短码!"
        render_flash(conn, message, url, "")

      {:error, :keyword_existed} ->
        message = "该短码已经被使用了!"
        render_flash(conn, message, url, "")

      {:error, :input_is_short_url} ->
        message = "不能输入转化后的短链接！"
        render_flash(conn, message, url, "")

      {:error, :url_existed_but_custom, keyword} ->
        result = hostname <> "/" <> keyword
        message = "该链接已经存在，不能自定义短码！"
        render_flash(conn, message, url, result)

      {:error, :url_invalid} ->
        message = "请输入正确的网址"
        render_flash(conn, message, url, "")

      {:error, _} ->
        message = "未知异常"
        render_flash(conn, message, url, "")
    end
  end

  def show(conn, %{"id" => keyword}) do
    case Link.expand(keyword) do
      {:ok, url} ->
        redirect(conn, external: url)

      {:error, :keyword_not_exist} ->
        render(conn, "404.html")
    end
  end

  defp render_flash(conn, message, url, short_url) do
    conn
    |> put_flash(:error, message)
    |> render("index.html", url: url, short_url: short_url, custom_keyword: "")
  end
end

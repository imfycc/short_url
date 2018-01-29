defmodule ShortUrlWeb.LinkControllerTest do
  use ShortUrlWeb.ConnCase
  import Ecto.Query
  alias ShortUrl.{Link, Repo}

  setup do
    Repo.insert!(%Link{url: "https://m.hufangyun.com", keyword: "zRx"})
    :ok
  end

  test "GET / index", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "输入网址"
  end

  describe "create/2" do
    test "POST / create url", %{conn: conn} do
      url = "https://www.hufangyun.com"
      conn = post conn, "/", url: url, custom_keyword: ""
      link = Link.find_url(url)

      assert html_response(conn, 200) =~ link.keyword
      assert html_response(conn, 200) =~ "data-clipboard-target"
    end

    test "POST / create | url is exist in db", %{conn: conn} do
      url = "https://m.hufangyun.com"
      conn = post conn, "/", url: url, custom_keyword: ""
      link = Link.find_url(url)

      assert link.keyword == "zRx"
      assert html_response(conn, 200) =~ "data-clipboard-target"
    end

    test "POST / create | url is invalid", %{conn: conn} do
      conn = post conn, "/", url: "www.hufangyun.com", custom_keyword: ""
      assert html_response(conn, 200) =~ "请输入正确的网址"
    end

    test "POST / create | url is short url", %{conn: conn} do
      hostname = ShortUrlWeb.Endpoint.url
      conn = post conn, "/", url: hostname <> "/ab1", custom_keyword: ""
      assert html_response(conn, 200) =~ "不能输入转化后的短链接"
    end

    test "POST / create | url is exist can`t custom keyword", %{conn: conn} do
      url = "https://m.hufangyun.com"
      conn = post conn, "/", url: url, custom_keyword: "1234"
      link = Link.find_url(url)

      assert link.keyword == "zRx"
      assert html_response(conn, 200) =~ "该链接已经存在，不能自定义短码"
    end

    test "POST / create | custom_keyword", %{conn: conn} do
      url = "https://www.hufangyun.com"
      conn = post conn, "/", url: url, custom_keyword: "1234"
      link = Link.find_url(url)

      assert link.keyword == "1234"
      assert html_response(conn, 200) =~ "data-clipboard-target"
    end

    test "POST / create | custom_keyword is exist", %{conn: conn} do
      url = "https://p.hufangyun.com"
      conn = post conn, "/", url: url, custom_keyword: "zRx"

      assert html_response(conn, 200) =~ "该短码已经被使用了"
    end

    test "POST / create | custom_keyword length beyond", %{conn: conn} do
      conn = post conn, "/", url: "https://www.hufangyun.com", custom_keyword: "1234678"
      assert html_response(conn, 200) =~ "短码的长度不能超过6位"
    end

    test "POST / create | custom_keyword is contains invalid character", %{conn: conn} do
      conn = post conn, "/", url: "https://www.hufangyun.com", custom_keyword: "1234.@"
      assert html_response(conn, 200) =~ "请按要求输入短码"
    end

    test "POST / create | current keyword is occupied before custom_keyword", %{conn: conn} do
      query = from l in Link,
        select: max(l.id)
      max_id = query |> Repo.one
      keyword2 = Base62.encode(max_id + 2)
      keyword = Base62.encode(max_id + 1)

      conn = post conn, "/", url: "https://www.hufangyun.com", custom_keyword: keyword2
      assert html_response(conn, 200) =~ keyword2

      conn = post conn, "/", url: "https://p.hufangyun.com", custom_keyword: ""
      assert html_response(conn, 200) =~ keyword
    end

  end

  describe "show/2" do
    test "GET / show | short_url is not exist", %{conn: conn} do
      conn = get conn, "/ABC"
      assert html_response(conn, 200) =~ "404"
    end
    test "GET / show | short_url", %{conn: conn} do
      conn = get conn, "/zRx"
      assert html_response(conn, 302) =~ "redirected"
    end
  end

end

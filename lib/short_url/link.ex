defmodule ShortUrl.Link do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias ShortUrl.{Link, Repo}

  @timestamps_opts [
    autogenerate: {EctoTimestamps.Local, :autogenerate, [:usec]}
  ]

  schema "links" do
    field :url, :string
    field :keyword, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(%Link{} = link, params \\ %{}) do
    link
    |> cast(params, [:url, :keyword, :type])
    |> validate_required([:url, :type])
    |> validate_url(:url, message: "请输入正确的网址")
    |> validate_length(:keyword, min: 0, max: 6)
    |> unique_constraint(:url)
  end

  def validate_url(changeset, field, options \\ []) do
    validate_change changeset, field, fn _, url ->
      case url |> String.to_charlist |> :http_uri.parse do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || "invalid url: #{inspect msg}"}]
      end
    end
  end

  def shorten(url, custom_keyword, hostname) do
    validate_input_value(url, custom_keyword, hostname)
  end

  def lengthen(url) do
    keyword = get_keyword(url)
    link = Link
    |> where(keyword: ^keyword)
    |> Repo.one

    case link do
      nil ->
        {:error, :keyword_not_exist}
      %Link{} ->
        {:ok, link.url}
    end
  end

  def get_keyword(url) do
    to_string(to_charlist(url) -- 'http://localhost:4000/')
  end
  

  defp validate_input_value(url, custom_keyword, hostname) do
    with :ok <- validate_url(url),
        :ok <- validate_short_url(url, hostname),
        :ok <- validate_custom_keyword(url, custom_keyword) do
      shorten(url, custom_keyword)
    end
  end

  defp validate_url(url) do
    case :http_uri.parse(url) do
      {:ok, _} ->
        :ok
      {:error, _} ->
        {:error, :url_invalid}
    end
  end

  defp validate_short_url(url, hostname) do
    uri = URI.parse(url)
    input_hostname = uri.scheme <> "://" <> uri.authority

    if (input_hostname ===  hostname) do
      {:error, :input_is_short_url}
    else
      :ok
    end
  end

  defp validate_custom_keyword(_, custom_keyword) when byte_size(custom_keyword) == 0 do
      :ok
  end

  defp validate_custom_keyword(_, custom_keyword) when byte_size(custom_keyword) > 6 do
      {:error, :custom_keyword_length_beyond}
  end

  defp validate_custom_keyword(_, custom_keyword) do
    if Regex.match?(~r/^[A-Za-z0-9]+$/, custom_keyword) do
      :ok
    else
      {:error, :custom_keyword_invalid}
    end
  end

  defp shorten(url, custom_keyword) do
    find_or_create_url(url, custom_keyword)
  end

  defp find_or_create_url(url, custom_keyword) do
    url
    |> find_url
    |> create_url(url, custom_keyword)
  end

  def find_url(url) do
    link = Link
    |> where(url: ^url)
    |> Repo.one

    case link do
      nil ->
        {:err, :url_not_exist}
      %Link{} ->
        link
    end
  end

  defp create_url(link = %Link{}, _, custom_keyword) do
    if String.length(custom_keyword) > 0 do
      {:error,:url_existed_but_custom, link.keyword}
    else
      link.keyword
    end
  end

  defp create_url({:err, :url_not_exist}, url, custom_keyword) when byte_size(custom_keyword) > 0 do
    if keyword_exist?(custom_keyword) do
      {:error, :keyword_existed}
    else
      Repo.insert(
        %Link{
          url: url,
          type: "custom",
          keyword: custom_keyword
        }
      )
      custom_keyword
    end
  end

  defp create_url({:err, :url_not_exist}, url, custom_keyword) when byte_size(custom_keyword) == 0 do
    save_url(url)
  end

  defp save_url(url) do
    link = Repo.insert(
      %Link{
        url: url,
        type: "system"
      }
    )

    case link do
      {:ok, l} ->
        calculate_keyword(l)
      {:error, error} -> error
    end
  end

  def keyword_exist?(keyword) do
    link = Link
    |> where(keyword: ^keyword)
    |> Repo.one

    case link do
      nil ->
        false
      %Link{} ->
        true
    end
  end

  defp calculate_keyword(link = %Link{}) do
    keyword = Base62.encode(link.id)

    if keyword_exist?(keyword) do
      get_custom_id()
      |> calculate_keyword
    else
      update_link_keyword(link, keyword)
      keyword
    end
  end

  defp calculate_keyword({:error, :get_custom_id_error}) do
    {:error, :get_custom_id_error}
  end

  defp update_link_keyword(link, keyword) do
    link
    |> changeset(%{
      keyword: keyword
    })
    |> Repo.update
  end

  defp get_custom_id() do
    query = from l in Link,
          where: l.type == "custom",
          order_by: [desc: l.id],
          limit: 1
    link = query |> Repo.one

    case link do
      %Link{} -> link
      _ -> {:error, :get_custom_id_error}
    end
  end

  def expand(keyword) do
    link = Link
    |> where(keyword: ^keyword)
    |> Repo.one

    case link do
      nil ->
        {:error, :keyword_not_exist}
      %Link{} ->
         {:ok, link.url}
    end
  end
end

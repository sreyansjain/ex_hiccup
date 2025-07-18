defmodule ExHiccup do
  @moduledoc """
  Hiccup-inspired HTML rendering for Elixir.

  ## Features

    * Ergonomic tuple forms for HTML nodes
    * Dot/class and hash/id tag syntax (e.g. `"div#main.abc.def"`)
    * Safe, automatic escaping of text and attributes (except `{:raw, ...}`)
    * IO data output by default for high performance
    * Supports custom elements and boolean attributes
    * Explicit string rendering via `render_to_string/1`

  ## Example

      iex> ExHiccup.render_to_string({"div#main.card", %{data_role: "x"}, ["hi"]})
      "<div id=\\"main\\" class=\\"card\\" data_role=\\"x\\">hi</div>"

  """

  @void_tags ~w(area base br col embed hr img input link meta param source track wbr)a

  @doc "Render the Hiccup-like structure to IO data (default)."
  def render(tree), do: render_node(tree)

  @doc "Render the Hiccup-like structure to a binary string."
  def render_to_string(tree), do: tree |> render() |> IO.iodata_to_binary()

  # --- Tag parsing with id and classes ---
  defp parse_tag(tag) when is_binary(tag) do
    case Regex.run(~r/^([a-zA-Z][\w\-]*)(#[\w\-]+)?((\.[\w\-]+)*)$/, tag) do
      [_, tag_name, id, class_str | _] ->
        id_attr = if id, do: String.trim_leading(id, "#"), else: nil
        class_attr =
          (class_str || "")
          |> String.split(".", trim: true)
          |> Enum.join(" ")
        {tag_name, id_attr, class_attr}
      _ ->
        {tag, nil, nil}
    end
  end
  defp parse_tag(tag) when is_atom(tag), do: {Atom.to_string(tag), nil, nil}

  defp merge_id(attrs, nil), do: attrs
  defp merge_id(attrs, ""), do: attrs
  defp merge_id(attrs, id_attr) do
    Map.put_new(attrs, :id, id_attr)
  end

  defp merge_class(attrs, nil), do: attrs
  defp merge_class(attrs, ""), do: attrs
  defp merge_class(attrs, class_attr) do
    Map.update(attrs, :class, class_attr, fn existing ->
      [to_string(existing), class_attr]
      |> Enum.filter(&(&1 != ""))
      |> Enum.join(" ")
    end)
  end

  # --- Main render logic ---
  defp render_node({:raw, html}) when is_binary(html), do: html
  # {:tag}
  defp render_node({tag}) when is_atom(tag) or is_binary(tag) do
    render_node({tag, %{}, []})
  end

  # {:tag, attrs} (where attrs is a map)
  defp render_node({tag, attrs}) when (is_atom(tag) or is_binary(tag)) and is_map(attrs) do
    render_node({tag, attrs, []})
  end

  # {:tag, children} (where children is anything else)
  defp render_node({tag, children}) when (is_atom(tag) or is_binary(tag)) do
    render_node({tag, %{}, children})
  end

  # {:tag, attrs, children}
  defp render_node({tag, attrs, children}) when (is_atom(tag) or is_binary(tag)) and is_map(attrs) do
    {tag_name, id_attr, class_attr} = parse_tag(tag)
    attrs = merge_id(attrs, id_attr)
    attrs = merge_class(attrs, class_attr)

    inner_html =
      cond do
        is_nil(children) -> []
        is_list(children) -> Enum.map(children, &render_node/1)
        true -> [render_node(children)]
      end

    if String.to_atom(tag_name) in @void_tags do
      ["<", tag_name, render_attrs(attrs), " />"]
    else
      ["<", tag_name, render_attrs(attrs), ">", inner_html, "</", tag_name, ">"]
    end
  end

  defp render_node(list) when is_list(list), do: Enum.map(list, &render_node/1)
  defp render_node(text) when is_binary(text), do: html_escape(text)
  defp render_node(nil), do: []

  defp render_attrs(attrs) when map_size(attrs) == 0, do: ""
  defp render_attrs(attrs) do
    Enum.reduce(attrs, "", fn
      {:class, ""}, acc -> acc
      {:class, nil}, acc -> acc
      {:id, ""}, acc -> acc
      {:id, nil}, acc -> acc
      {k, true}, acc when is_atom(k) -> acc <> " " <> Atom.to_string(k)
      {k, false}, acc when is_atom(k) -> acc
      {k, v}, acc when is_atom(k) -> acc <> " " <> Atom.to_string(k) <> "=\"" <> html_escape(to_string(v)) <> "\""
      {k, v}, acc when is_binary(k) -> acc <> " " <> k <> "=\"" <> html_escape(to_string(v)) <> "\""
      _, acc -> acc
    end)
  end

  defp html_escape(str) when is_binary(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end
end

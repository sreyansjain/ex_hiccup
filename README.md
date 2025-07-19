# ex_hiccup

A Hiccup-inspired HTML rendering library for Elixir, supporting dot-class/hash-id syntax, IO data output, safe escaping, and custom elements.

## Features

- Ergonomic Hiccup tuple forms
- Dot/class and hash/id in tag strings: `"div#main.card"`
- Escaping for all text and attribute values (`{:raw, ...}` bypasses)
- IO data default for high throughput web rendering
- Supports custom elements, boolean attributes, void/self-closing tags

## Usage

```elixir
ExHiccup.render_to_string({"div#main.card", %{data_role: "x"}, ["Hello!"]})
# => "<div id=\"main\" class=\"card\" data_role=\"x\">Hello!</div>"

ExHiccup.render({"input#foo.big", %{type: "text"}})
# => ["<input id=\"foo\" class=\"big\" type=\"text\" />"]
#
#Empty div
ExHiccup.render({:div})

#h1
ExHiccup.render({:h1, "This is some heading"})

#tag with class and id
ExHiccup.render({:button,
  %{id: "fetch_button", class: "btn btn-primary", "data-on-click": "@get('/fetch_endpoint')"},
  "Fetch Data"})

#tag with children
ExHiccup.render({:ul, %{class: "list"}, [
  {:li, "Item 1"},
  {:li, "Item 2"},
  {:li, "Item 3"}
]})
```

## License

MIT

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
```

## License

MIT

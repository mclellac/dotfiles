return {
	s("h1", {
		t({ "# " }),
		i(1, "Heading"),
	}),
	s("h2", {
		t({ "## " }),
		i(1, "Heading"),
	}),
	s("h3", {
		t({ "### " }),
		i(1, "Heading"),
	}),
	s("link", {
		t({ "[" }),
		i(1, "text"),
		t({ "](" }),
		i(2, "url"),
		t({ ")" }),
	}),
	s("img", {
		t({ "![" }),
		i(1, "alt text"),
		t({ "](" }),
		i(2, "image_url"),
		t({ ")" }),
	}),
	s("bold", {
		t({ "**" }),
		i(1, "text"),
		t({ "**" }),
	}),
	s("italic", {
		t({ "*" }),
		i(1, "text"),
		t({ "*" }),
	}),
	s("code", {
		t({ "`" }),
		i(1, "code"),
		t({ "`" }),
	}),
	s("codeblock", {
		t({ "```" }),
		i(1, "language"),
		t({ "", "" }),
		i(2, "code"),
		t({ "", "```" }),
	}),
	s("table", {
		t({
			"| Header 1 | Header 2 |",
			"| -------- | -------- |",
			"| ",
		}),
		i(1, "cell"),
		t({ " | " }),
		i(2, "cell"),
		t({ " |" }),
	}),
	s("ul", {
		t({ "- " }),
		i(1, "item"),
	}),
	s("ol", {
		t({ "1. " }),
		i(1, "item"),
	}),
}

ruff:
	ruff check . --preview

ansible-lint:
	cd ansible && ansible-lint

lint: ruff

lint-all: lint ansible-lint
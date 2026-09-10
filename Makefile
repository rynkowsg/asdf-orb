.DEFAULT_GOAL := help

# Lists every target that carries a `## ` description, in the order they appear.
# Targets without one stay out of the listing, which is how the `_` ones hide.
.PHONY: help
help:  ## Print this help
	@awk 'BEGIN{FS=":.*##"} /^[a-zA-Z0-9_\/-]+:.*##/ {printf "  %-30s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: _format-shell/deps
_format-shell/deps:
	sosh fetch @bin/format.bash

.PHONY: _lint-shell/deps
_lint-shell/deps:
	sosh fetch @bin/lint.bash

.PHONY: scripts/deps
scripts/deps:
	sosh fetch src/scripts/cache_gen_key.bash
	sosh fetch src/scripts/install_asdf.bash

.PHONY: scripts/gen
scripts/gen: scripts/deps  ## Pack the scripts into src/scripts/gen
	sosh pack -i src/scripts/cache_gen_key.bash -o src/scripts/gen/cache_gen_key.bash
	sosh pack -i src/scripts/install_asdf.bash -o src/scripts/gen/install_asdf.bash

.PHONY: format/check
format/check: format-shell/check  ## Check formatting

.PHONY: format/fix
format/fix: format-shell/fix  ## Fix formatting

.PHONY: format-shell/check
format-shell/check: _format-shell/deps  ## Check shell formatting
	./@bin/format.bash check

.PHONY: format-shell/fix
format-shell/fix: _format-shell/deps  ## Format shell scripts
	./@bin/format.bash apply

# Since formatting doesn't allow to ignore some parts, I apply patches before and after formatting to overcome this.
# Here are commands to update these patches
.PHONY: format-shell/update-patches
format-shell/update-patches:  ## Rebuild the pre- and post-format patches
	rm -f @bin/res/pre-format.patch @bin/res/post-format.patch
	WITH_PATCHES=0 ./@bin/format.bash apply
	git commit -a --no-gpg-sign -m "patch"
	git revert --no-commit HEAD
	git commit -a --no-gpg-sign -m "patch revert"
	git diff HEAD~2..HEAD~1 > @bin/res/pre-format.patch
	git diff HEAD~1..HEAD > @bin/res/post-format.patch
	git reset HEAD~2
	[ -f @bin/res/pre-format.patch ] && git add @bin/res/pre-format.patch
	[ -f @bin/res/post-format.patch ] && git add @bin/res/post-format.patch
	git commit -m "ci: Update patches"

.PHONY: lint/check
lint/check: lint-shell/check  ## Lint sources

# lint.bash runs shellcheck with --external-sources, so shellcheck follows the
# `# shellcheck source=` directives in the files it lints. Every library they
# point at has to be fetched first, or shellcheck reports SC1091 and the lint
# fails. That covers the @bin helpers and the scripts under src.
.PHONY: lint-shell/check
lint-shell/check: _format-shell/deps _lint-shell/deps scripts/deps  ## Lint shell scripts
	./@bin/lint.bash

.PHONY: check
check: format/check lint/check  ## Run every check

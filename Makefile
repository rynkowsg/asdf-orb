.PHONY: lint format-check format format-update-patches

deps_format: @bin/format.bash
	sosh fetch @bin/format.bash

deps_lint: @bin/lint.bash
	sosh fetch @bin/lint.bash

deps_src:
	sosh fetch src/scripts/cache_gen_key.bash
	sosh fetch src/scripts/install_asdf.bash

format-check: deps_format
	\@bin/format.bash check

format: deps_format
	\@bin/format.bash apply

lint: deps_format deps_lint deps_src
	\@bin/lint.bash

# Since formatting doesn't allow to ignore some parts, I apply patches before and after formatting to overcome this.
# Here are commands to update these patches
format-update-patches:
	rm -f @bin/res/pre-format.patch @bin/res/post-format.patch
	WITH_PATCHES=0 @bin/format.bash apply
	git commit -a --no-gpg-sign -m "patch"
	git revert --no-commit HEAD
	git commit -a --no-gpg-sign -m "patch revert"
	git diff HEAD~2..HEAD~1 > @bin/res/pre-format.patch
	git diff HEAD~1..HEAD > @bin/res/post-format.patch
	git reset HEAD~2
	\[ -f @bin/res/pre-format.patch \] && git add @bin/res/pre-format.patch
	\[ -f @bin/res/post-format.patch \] && git add @bin/res/post-format.patch
	git commit -m "ci: Update patches"

gen: deps_src
	sosh pack -i src/scripts/cache_gen_key.bash -o src/scripts/gen/cache_gen_key.bash
	sosh pack -i src/scripts/install_asdf.bash -o src/scripts/gen/install_asdf.bash

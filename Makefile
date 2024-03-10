.PHONY: lint format-check format-apply format-update-patches

lint:
	bash @bin/lint.bash

format-check:
	bash @bin/format-check.bash

format-apply:
	bash @bin/format-apply.bash

# Since formatting doesn't allow to ignore some parts, I apply patches before and after formatting to overcome this.
# Here are commands to update these patches
format-update-patches:
	APPLY_PATCHES=0 make format-apply
	git commit -a --no-gpg-sign -m "patch"
	git revert --no-commit HEAD
	git commit -a --no-gpg-sign -m "patch revert"
	git diff HEAD~2..HEAD~1 > @bin/res/pre-format.patch
	git diff HEAD~1..HEAD > @bin/res/post-format.patch
	git reset HEAD~2
	git add @bin/res/pre-format.patch @bin/res/post-format.patch
	git commit -m "ci: Update patches"

gen:
	# with shellpack sha:d393d6a - https://github.com/rynkowsg/shellpack/commit/d393d6af64d85d48578136398ca6ee54217b2eb5
	cd src/scripts && shellpack fetch install_asdf.bash && shellpack pack -i install_asdf.bash -o ./gen/install_asdf.bash

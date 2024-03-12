.PHONY: lint format-check format-apply format-update-patches

lint:
	\@bin/lint.bash

format:
	APPLY=0 \@bin/format.bash

format-apply:
	APPLY=1 \@bin/format.bash

# Since formatting doesn't allow to ignore some parts, I apply patches before and after formatting to overcome this.
# Here are commands to update these patches
format-update-patches:
	rm -f @bin/res/pre-format.patch @bin/res/post-format.patch
	APPLY_PATCHES=0 APPLY=1 bash @bin/format.bash
	git commit -a --no-gpg-sign -m "patch"
	git revert --no-commit HEAD
	git commit -a --no-gpg-sign -m "patch revert"
	git diff HEAD~2..HEAD~1 > @bin/res/pre-format.patch
	git diff HEAD~1..HEAD > @bin/res/post-format.patch
	git reset HEAD~2
	git add @bin/res/pre-format.patch @bin/res/post-format.patch
	git commit -m "ci: Update patches"

gen:
	# with shellpack sha:e469eb6 - https://github.com/rynkowsg/shellpack/commit/02965b2cbbe4707c052f26eb90aac9308816c94b
	cd src/scripts && shellpack fetch install_asdf.bash && shellpack pack -i install_asdf.bash -o ./gen/install_asdf.bash

# [`rynkowsg/asdf`][orb-page] orb

[![CircleCI Build Status][ci-build-badge]][ci-build]
[![CircleCI Orb Version][orb-version-badge]][orb-page]
[![License][license-badge]][license]
[![CircleCI Community][orbs-discuss-badge]][orbs-discuss]

Use ASDF in your CircleCI pipelines.

[What are Orbs?](https://circleci.com/orbs/)

## Motivation

**Single Source of Truth**

Leverage your .tool-versions file as the single source of truth.
There's no longer a need to synchronize tooling between your CI environment and your local setup.

**Ease of Integrating Tools into CI**

Utilize the .tool-versions file for straightforward tool integration in your CI pipeline.

**Reduced Time to Action**

The more specialized your Docker image, the longer it might take to fetch.
With asdf-orb, you can start with a widely-used, or even a base image,
and install everything you need using just one command.
Plus, by caching this setup, you can speed up restoration for even quicker starts in the future.

## Status

The orb's got just the `install` command for now. But after you've got ASDF installed,
adding plugins and tool installations can be easily accomplished from a regular `run` step.
For examples, see:
- [sosh's CircleCI configuration](https://github.com/rynkowsg/sosh/blob/main/.circleci/config.yml)
- [clj-gr's CircleCI configuration](https://github.com/rynkowsg/clj-gr/blob/main/.circleci/config.yml)

> [!WARNING]
> This is **early alpha**. Keep this in mind that interface might change[^warning-alpha].

[^warning-alpha]: That said, even if breaking changes are possible, it's probably better to use it and update your repository as needed rather than building your own scripts.

## Quickstart

```yaml
version: '2.1'

orbs:
  asdf: rynkowsg/asdf@0.1.1

jobs:
  test:
    docker: [{image: "cimg/base:stable"}]
    steps:
      - asdf/install

workflows:
  main-workflow:
    jobs:
      - test
```

## Usage

For full usage guidelines, see the [orb registry listing][orb-page].

## `rynkowsg/` orb family

| Name                                                            | Description                                                                                       |
|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| [`rynkowsg/asdf`](https://github.com/rynkowsg/asdf-orb)         | Orb providing support for ASDF                                                                    |
| [`rynkowsg/checkout`](https://github.com/rynkowsg/checkout-orb) | Advanced checkout with support of LFS, submodules, custom SSH identities, shallow clones and more |
| [`rynkowsg/rynkowsg`](https://github.com/rynkowsg/rynkowsg-orb) | Orb with no particular theme, used primarily for prototyping                                      |

## License

Copyright © 2024 Greg Rynkowski

Released under the [MIT license][license].

[ci-build-badge]: https://circleci.com/gh/rynkowsg/asdf-orb.svg?style=shield "CircleCI Build Status"
[ci-build]: https://circleci.com/gh/rynkowsg/asdf-orb
[license-badge]: https://img.shields.io/badge/license-MIT-lightgrey.svg
[license]: https://raw.githubusercontent.com/rynkowsg/asdf-orb/master/LICENSE
[orb-page]: https://circleci.com/developer/orbs/orb/rynkowsg/asdf
[orb-version-badge]: https://badges.circleci.com/orbs/rynkowsg/asdf.svg
[orbs-discuss-badge]: https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg
[orbs-discuss]: https://discuss.circleci.com/c/ecosystem/orbs

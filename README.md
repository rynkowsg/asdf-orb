# [asdf-orb][orb-page]

[![CircleCI Build Status][badge-orb-build-status]][orb-pipeline]
[![CircleCI Orb Version][badge-orb-version]][orb-page]
[![License][badge-license]][orb-license]
[![CircleCI Community][badge-orbs-discuss]][orbs-discuss]

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

## Quickstart

```yaml
version: '2.1'

orbs:
  asdf: rynkowsg/asdf-orb@0.1.0

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

## License

Copyright © 2024 Greg Rynkowski

Released under the [MIT license][orb-license].

[badge-license]: https://img.shields.io/badge/license-MIT-lightgrey.svg
[badge-orb-build-status]: https://circleci.com/gh/rynkowsg/asdf-orb.svg?style=shield "CircleCI Build Status"
[badge-orb-version]: https://badges.circleci.com/orbs/rynkowsg/asdf.svg
[badge-orbs-discuss]: https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg
[orb-license]: https://raw.githubusercontent.com/rynkowsg/asdf-orb/master/LICENSE
[orb-page]: https://circleci.com/developer/orbs/orb/rynkowsg/asdf
[orb-pipeline]: https://circleci.com/gh/rynkowsg/asdf-orb
[orbs-discuss]: https://discuss.circleci.com/c/ecosystem/orbs

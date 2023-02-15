Quality.sh ![ci badge](https://github.com/gwallet/quality.sh/actions/workflows/ci.yml/badge.svg?branch=master)
==========

Because Quality is Key!

Introduction
------------

Just a simple example that testing software is mostly a question of will.

How It Works!
-------------

Uses [GNU Make](https://www.gnu.org/software/make/) to check and package [GNU BASH](https://www.gnu.org/software/bash/) based scripts.

## make lint

Use `make lint` to run [ShellCheck](https://www.shellcheck.net/) on all scripts.

## make test

Use `make test` to run all test suites with basic [Test Anything Protocol](https://testanything.org/tap-version-14-specification.html) support.

Use `VERBOSE=TRUE make test` to always see test outputs

## make ci

Use `make ci` on a continuous integration pipeline to run both `lint` and `test`

## make package

Use `make package` to create a distribution package, including source

## make help

Use `make help` to get info on what can be run for which purpose

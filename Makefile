.PHONY: bootstrap venv deps dirs clean test release mypy pylint flake8 bandit check build

SHELL := /bin/bash
FILES_CHECK_MYPY = user_agent
FILES_CHECK_ALL = $(FILES_CHECK_MYPY) tests

bootstrap: venv deps dirs

venv:
	virtualenv -p python3 .env

deps:
	.env/bin/pip install -r requirements.txt
	.env/bin/pip install -e .

dirs:
	if [ ! -e var/run ]; then mkdir -p var/run; fi
	if [ ! -e var/log ]; then mkdir -p var/log; fi

clean:
	find -name '*.pyc' -delete
	find -name '*.swp' -delete
	find -name '__pycache__' -delete

test:
	tox -e py3-test

#release:
#	git push \
#	&& git push --tags \
#	&& make build \
#	&& twine upload dist/*

mypy:
	mypy --python-version=3.8 --strict $(FILES_CHECK_MYPY)

pylint:
	pylint -j0  $(FILES_CHECK_ALL)

flake8:
	flake8 -j auto --max-cognitive-complexity=17 $(FILES_CHECK_ALL)

bandit:
	bandit -qc pyproject.toml -r $(FILES_CHECK_ALL)

check:
	tox -e py38-check \
	&& tox -e py3-check

build:
	rm -rf *.egg-info
	rm -rf dist/*
	python -m build --sdist

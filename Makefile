BASE_URL := https://lowess.github.io/unraid-docs/

run:
	hugo serve

build:
	rm -rf docs/
	HUGO_BASEURL=$(BASE_URL); hugo

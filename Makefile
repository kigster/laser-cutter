# vim: tabstop=8
# vim: shiftwidth=8
# vim: noexpandtab

# grep '^[a-z\-]*:' Makefile | cut -d: -f 1 | tr '\n' ' '
.PHONY:	coverage

OS	 		 	:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# see: https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile/18137056#18137056
MAKEFILE_PATH 			:= $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR 			:= $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

help:	   			## Prints help message auto-generated from the comments.
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


bundle:				## Install dependencies
				bundle check || bundle install || bundle update

test:				bundle ## Run tests
				bundle exec rspec --format=progress
				

coverage: 			test ## Run tests and upload coverage
				curl -Os https://uploader.codecov.io/latest/macos/codecov
				bash -c " \
					export CODECOV_TOKEN='bcd12d4d-adbd-4768-8250-ac4e17571b20' ; \
					chmod 755 codecov; \
				 	./codecov -t \$(CODECOV_TOKEN) ; \
					rm -f codecov \
				"

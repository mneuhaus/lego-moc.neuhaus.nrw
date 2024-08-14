PATH  := node_modules/.bin:$(PATH)
SHELL := /bin/sh

.PHONY: install run test build test-watch update-data deploy-production remote-test
LOCAL_IP := $(shell ifconfig | grep -o "inet 192.168.[0-9\.]*" | grep -m 1 -o "192.168.*")

all: install run

setup: install build/dev

build/dev: ## build app
	./node_modules/.bin/encore dev

build/production: ## build app in production mode
	./node_modules/.bin/encore production

build/staging: ## build app in staging mode
	ENV=staging ./node_modules/.bin/encore dev

build/integration: ## build app in integration mode
	ENV=integration ./node_modules/.bin/encore dev

build/watch: ## build app
	./node_modules/.bin/encore dev --watch

install:
	composer install
	cd static && composer install
	yarn install --frozen-lockfile

upgrade:
	composer update
#	yarn upgrade
	make build/dev

docker/build: #build/dev
	docker build --platform linux/amd64 -t neuhausnrw/lego-moc .

docker/tag-release:
	@read -p "what kind of release is this? [major|minor|patch]: " SEMVER; \
	gitsem $$SEMVER

docker/push-image: docker/build
	@docker login
	docker push neuhausnrw/lego-moc

update-dependencies:
	yarn upgrade
	composer update brunex/styles

data/update:
	./bin/console data:update

changelog:
	git log --pretty="%h | %ad | %s" --date=format:'%d.%m.%Y %H:%M:%S' > ./static/changelog.txt

translation/push/local:
	./vendor/brunex/styles/bin/brunex translation:update ./src local.my.brunex.ch 45dc2685506120142e8e0a1313ce59fd -v

translation/push/staging:
	./vendor/brunex/styles/bin/brunex translation:update ./src staging.my.brunex.ch 45dc2685506120142e8e0a1313ce59fd -v


# ----------------------------------------------------------------------#
# Tests                                                                 #
# ----------------------------------------------------------------------#
test/acceptance: test/start-selenium test/run test/stop-selenium

test/acceptance/failed: test/start-selenium test/run/failed test/stop-selenium

test/unit:
	./node_modules/.bin/karma start


test/stop-selenium:
	-docker kill selenium
	-docker rm selenium

test/start-selenium: test/stop-selenium
	@docker run -d --name selenium \
		--add-host="local.configurator.brunex.ch:$(LOCAL_IP)" \
		--add-host="local.my.brunex.ch:$(LOCAL_IP)" \
		--add-host="local.my.brunex.ch:$(LOCAL_IP)" \
		-p 4444:4444 \
		-p 5900:5900 \
		-v /dev/shm:/dev/shm \
		selenium/standalone-chrome-debug:3.141
	sleep 5
	# TODO: Replace with? https://gist.github.com/michael-k/00b36c564a40119e55a9742e423e17aa

test/start-chromedriver: ## start chromedriver
	./bin/chromedriver --slient --url-base=/wd/hub --auto-open-devtools-for-tabs &

test/stop-chromedriver: ## stop chromedriver
	pkill chromedriver

test/run:
	./vendor/bin/codecept run --html --env local

test/run/failed:
	./vendor/bin/codecept run -g failed --steps --debug --html

# ----------------------------------------------------------------------#
# Integration environment                                               #
# ----------------------------------------------------------------------#
integration/user = brunex
integration/host = brunex.ch
integration/port = 2222
integration/path = /var/www/int.configurator.brunex.ch/

define integration/shell
	ssh $(integration/user)@$(integration/host) -p$(integration/port) 'cd $(integration/path) &&$1'
endef

integration/deploy: build/integration
	rsync -rz -e 'ssh -p$(integration/port)' './static/' '$(integration/user)@$(integration/host):$(integration/path)'
	$(call integration/shell, COMPOSER_DISCARD_CHANGES=true php7.1 /usr/local/bin/composer install --ignore-platform-reqs)
	./vendor/brunex/styles/bin/brunex translation:update ./src int.my.brunex.ch 45dc2685506120142e8e0a1313ce59fd -v

integration/test/acceptance:
	ssh -f -N -M -S /tmp/ssh-brunex-tunnel-socket brunex@srv.brunex.ch -p2222 -L 3307:127.0.0.1:3306
	./vendor/bin/codecept run --steps --html -vvv acceptance --env int

# ----------------------------------------------------------------------#
# Staging environment                                                   #
# ----------------------------------------------------------------------#
staging/user = brunex
staging/host = brunex.ch
staging/port = 2222
staging/path = /var/www/staging.configurator.brunex.ch/

define staging/shell
	ssh $(staging/user)@$(staging/host) -p$(staging/port) 'cd $(staging/path) &&$1'
endef

staging/deploy: build/staging
	rsync -rz -e 'ssh -p$(staging/port)' './static/' '$(staging/user)@$(staging/host):$(staging/path)'
	$(call staging/shell, COMPOSER_DISCARD_CHANGES=true php7.1 /usr/local/bin/composer install --ignore-platform-reqs)
	./vendor/brunex/styles/bin/brunex translation:update ./src staging.my.brunex.ch 45dc2685506120142e8e0a1313ce59fd -v
	$(call staging/shell, sudo chown -R brunex:www-data /var/www/staging.configurator.brunex.ch/)
	$(call staging/shell, sudo chmod -R 775 /var/www/staging.configurator.brunex.ch/)


# ----------------------------------------------------------------------#
# Production environment                                                #
# ----------------------------------------------------------------------#
production/user = brunex
production/host = brunex.ch
production/port = 2222
production/path = /var/www/configurator.brunex.ch/

define production/shell
	ssh $(production/user)@$(production/host) -p$(production/port) 'cd $(production/path) &&$1'
endef

production/deploy: build/production
	rsync -rz -e 'ssh -p$(production/port)' './static/' '$(production/user)@$(production/host):$(production/path)'
	$(call production/shell, COMPOSER_DISCARD_CHANGES=true php7.1 /usr/local/bin/composer install --ignore-platform-reqs)
	./vendor/brunex/styles/bin/brunex translation:update ./src my.brunex.ch 45dc2685506120142e8e0a1313ce59fd -v
	$(call production/shell, sudo chown -R brunex:www-data /var/www/configurator.brunex.ch/)
	$(call production/shell, sudo chmod -R 775 /var/www/configurator.brunex.ch/)

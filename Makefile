#
# Prepare openapi files and run projects in containers.
#
YAML=$(shell find * -name \*yaml)
YAMLSRC=$(shell find openapi -name \*yaml.src)
YAMLGEN=$(patsubst %.yaml.src,%.yaml,$(YAMLSRC))

yaml: $(YAMLGEN)

.ONESHELL:
%.yaml: %.yaml.src
	tox -e yamllint -- -d relaxed $<
	tox -e yaml 2>/dev/null --  $< $@ 

yamllint: $(YAML)
	tox -e yamllint -- $<

rust-generate: openapi/simple.yaml
	wget -nc -O scripts/openapi-generator-cli.jar https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/4.2.3/openapi-generator-cli-4.2.3.jar
	java -jar scripts/openapi-generator-cli.jar generate -i openapi/simple.yaml -g rust-server -o rust-server

python-flask: python-flask-generate
	(cd python-flask && docker-compose up --build test )

python-flask-quickstart: python-flask-generate
	# Test all
	(cd python-flask && docker-compose up --build test )
	# Build and run the application
	(cd python-flask && docker-compose up simple )


VERSION:="${VERSION}"

latest:
	docker build . -t tortus/ruby-1.8:latest
	@echo "To tag with specific version: docker tag tortus/ruby-1.8:latest tortus/ruby-1.8:TAG

tag:
	docker tag tortus/ruby-1.8:latest tortus/ruby-1.8:${VERSION}

push:
	docker push tortus/ruby-1.8:latest

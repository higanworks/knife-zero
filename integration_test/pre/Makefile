.PHONY: build_push

build_push:
	docker build --platform linux/amd64 -t higanworks/knife-zero-edgebase:latest . --squash --no-cache
	docker push higanworks/knife-zero-edgebase:latest

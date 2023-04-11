build_code:
	cd ./dockerfiles/vscode && docker build -t shipyardrun/docker-devs-vscode:v0.0.2 .

push_code: build_code
	docker push shipyardrun/docker-devs-vscode:v0.0.2
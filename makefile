
.PHONY: push deploy
commit: push deploy

.PHONY: push
push: 
	bash ./push.sh

.PHONY: deploy
deploy:
	bash ./deploy.sh

.PHONY: pull
pull:
	git pull
	cd public && git pull

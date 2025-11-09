install-webui:
	cd webui && npm install

build-webui:
	cd webui && npm run build

test-webui:
	cd webui && npm test

install-flutter:
	flutter pub get

test:
	flutter test

check-build-webui:
	find assets/webui -mindepth 1 -print -quit >/dev/null 2>&1

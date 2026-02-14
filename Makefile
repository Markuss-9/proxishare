.PHONY: install-webui build-webui test-webui install-flutter test check-build-webui apk build-windows 

install-webui:
	cd webui && npm install

build-webui:
	cd webui && npm run build

test-webui:
	cd webui && npm test

test-webui-no-watch:
	cd webui && npm test -- --run

install-flutter:
	flutter pub get

test:
	flutter test

check-build-webui:
	find assets/webui -mindepth 1 -print -quit >/dev/null 2>&1

apk:
	flutter build apk --release 
	flutter install --release

build-windows: install-flutter
	flutter build windows --release
	@powershell -Command "$$version = (Select-String -Path 'pubspec.yaml' -Pattern 'version:\\s+([\\d.]+)' | % {$$_.Matches[0].Groups[1].Value}); iscc /DAppVersion=$$version proxishare.iss"

.PHONY: build-windows-full
build-windows-full: install-webui test-webui-no-watch build-webui install-flutter test build-windows
	@echo Windows installer built successfully at installer/ProxiShare-Setup.exe
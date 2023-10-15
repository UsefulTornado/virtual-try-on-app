# virtual-try-on-app
## Запуск приложения
### Установка `flutter`

Перейдите по [ссылке](https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.7-stable.tar.xz) для установки исходников (под ОС `linux`).
Для другой операционной системы исходники можно найти по [ссылке](https://docs.flutter.dev/get-started/install).

Извлеките загруженный файл в выбранное вами место.
```text
cd ~/development
tar xf ~/Downloads/flutter_linux_3.13.7-stable.tar.xz
```

Добавьте инструмент `flutter` в выбранный путь:
```text
export PATH="$PATH:`pwd`/flutter/bin"
```

Подтвердите установку с помощью flutter doctor
```text
flutter doctor
```
Если возникли вопросы, перейдите на [официальную страницу](https://docs.flutter.dev/get-started/install/linux) `flutter`

### Запуск сервиса для передачи данных нейросети
Для запуска сервиса необходимо, чтобы был установлен компилятор языка программирования [go](https://go.dev/doc/install).

Далее выполните следующие команды:
```text
cd backend/tasks/cmd
go mod tidy
go run main.go
```

### Запуск сервиса для взаимодействия с  нейронной сетью
Для запуска сервиса необходимо, чтобы был установлен компилятор языка программирования [python](https://www.python.org/downloads/).

Далее выполните следующие команды:
```text
cd backend/neural_network
pip install -r requirements.txt
bash run.sh
```

### Запуск мобильного приложения
Для запуска мобильного приложения необходимо выполнить действия для установки flutter.

Далее выполните следующие команды:
```text
cd app/lib
flutter pub get
flutter run main.dart
```
Для запуска приложения необходимо выбрать платформу (приложение под операционную систему, на телефоне).

*Примечание: из-за особенностей языка программирования не рекомендуются запускать приложение в браузере.

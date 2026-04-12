# 📦 Deployment

Проект поддерживает два варианта развертывания:

- `docker`
- `systemd`

---

## 🐳 Docker Deployment

В Docker-режиме запускается один сервис:

- `hybrid-web`

### Требования

- Docker с Compose
- Доступные host bind mounts:
  - `/media`
  - `/srv`
  - `/root/.config/rclone`

### Подготовка

```bash
cd hybrid
cp .env.docker.example .env.docker
```

Проверьте:

- `HYBRID_RCLONE_CONFIG`
- `APP_TIMEZONE`
- `HYBRID_API_TOKEN`

### Запуск

```bash
docker compose --env-file .env.docker up -d --build
```

### Installer Script

```bash
sudo ./scripts/install.sh docker
```

---

## 🖥️ Systemd Deployment

В режиме `systemd` backend, scheduler и watcher работают внутри одного web-сервиса.

## Единый installer

Основной способ установки и обслуживания:

```bash
sudo ./scripts/install.sh
```

Скрипт работает как интерактивное меню и умеет:

- поставить или обновить deployment через `systemd`
- поставить или обновить deployment через `docker`
- подтянуть исходники из Git перед установкой
- проверить зависимости и предложить доустановить недостающие
- выполнить переход с legacy: сделать backup, остановить и удалить старые scripts/unit'ы
- удалить hybrid-установку при повторном запуске

Legacy-cleanup покрывает старые файлы:

```text
/usr/local/bin/rclone-backup.sh
/usr/local/bin/rclone-watch.sh
/usr/local/bin/rclone-backup-status.sh
/usr/local/bin/rclone-backup.sh.bak.*
/etc/systemd/system/rclone-backup.service
/etc/systemd/system/rclone-backup.timer
/etc/systemd/system/rclone-watch.service
```

Для неинтерактивного запуска доступны команды:

```bash
sudo ./scripts/install.sh systemd
sudo ./scripts/install.sh docker
sudo ./scripts/install.sh migrate-legacy
sudo ./scripts/install.sh uninstall
```

### Требования

- `python3`
- `python3-venv`
- `rclone`
- `curl`
- `systemd`

### Подготовка

```bash
cp hybrid/.env.systemd.example hybrid/.env
```

Проверьте:

- `HYBRID_DB_PATH`
- `HYBRID_JOBS_FILE`
- `HYBRID_RCLONE_CONFIG`
- `HYBRID_WATCHER_DEBOUNCE_SECONDS`
- `HYBRID_COPY_STARTUP_DELAY_SECONDS`
- `HYBRID_COPY_MIN_START_INTERVAL_SECONDS`

### Установка

```bash
sudo ./scripts/install.sh systemd
```

### Включение сервисов

```bash
systemctl status rclone-hybrid-web.service --no-pager
```

### Переход со старого external watcher

Если на хосте раньше был legacy pipeline или отдельный `rclone-watch-hybrid.service`, выполните migration через единый installer:

```bash
sudo ./scripts/install.sh migrate-legacy
```

Скрипт делает backup, останавливает и отключает старые unit'ы, удаляет устаревшие scripts/unit'ы и оставляет только встроенный watcher внутри `rclone-hybrid-web.service`.

---

## ✅ Post-Deployment Checklist

Проверьте:

- `GET /api/health`
- `GET /api/state`
- ручной запуск профиля или задачи
- создание SQLite database
- создание `default_jobs.json` при чистом старте

---

## 🆚 Выбор режима

| Режим | Когда подходит лучше |
| --- | --- |
| `docker` | Удобнее контейнерный запуск |
| `systemd` | Нужна прямая интеграция с системой и запуск на хосте |

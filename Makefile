BIN_NAME   := mcp-makeapp
BIN_PATH   := $(BIN_NAME)
SERVICE    := mcp-makeapp
PORT       := 8000

.PHONY: help build kill restart stop start status logs reset clean

help:
	@echo "  make restart   — mata, compila, corrige SELinux, reinicia"
	@echo "  make logs      — segue logs"
	@echo "  make status    — mostra status"

build:
	@echo "🔨 Compilando $(BIN_NAME)..."
	@go build -o $(BIN_PATH) .
	@echo "🔐 Corrigindo contexto SELinux..."
	@sudo restorecon -v $(BIN_PATH) 2>/dev/null || true
	@echo "✅ OK"

kill:
	@sudo systemctl stop $(SERVICE) 2>/dev/null || true
	@pkill -f "$(BIN_NAME)" 2>/dev/null || true
	@sudo fuser -k $(PORT)/tcp 2>/dev/null || true
	@sudo systemctl reset-failed $(SERVICE) 2>/dev/null || true
	@echo "✅ Parado"

stop: kill

start:
	@sudo systemctl start $(SERVICE)
	@sleep 1
	@sudo systemctl status $(SERVICE) --no-pager | head -10

restart: kill build
	@sudo systemctl start $(SERVICE)
	@sleep 1
	@sudo systemctl status $(SERVICE) --no-pager | head -10
	@echo ""
	@echo "✅ Pronto: https://file.etoolstec.com.br"

reset:
	@sudo systemctl reset-failed $(SERVICE)
	@sudo systemctl restart $(SERVICE)
	@sleep 1
	@sudo systemctl status $(SERVICE) --no-pager | head -10

status:
	@sudo systemctl status $(SERVICE) --no-pager
	@-sudo ss -tlnp | grep :$(PORT) || echo "❌ nada na $(PORT)"

logs:
	@sudo journalctl -u $(SERVICE) -f

clean:
	@rm -f $(BIN_PATH)
	@go clean -cache 2>/dev/null || true
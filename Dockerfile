# Imagen base
FROM python:3.11-slim

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY app/ ./app

# Exponer puerto
EXPOSE 5000

# Comando de ejecución
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app.app:app"]

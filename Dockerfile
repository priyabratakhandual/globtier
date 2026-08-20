# ================================
# Stage 1: Builder
# ================================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install packages required to build Python dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv

# Make virtual environment the default
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements first for Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# ================================
# Stage 2: Runtime
# ================================
FROM python:3.11-slim AS runtime

WORKDIR /app

# Python configuration
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy only the Python virtual environment
COPY --from=builder /opt/venv /opt/venv

# Use virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY . .

# Application port
EXPOSE 7000

# Start application
CMD ["python", "app.py"]
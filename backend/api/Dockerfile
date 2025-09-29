# =========================
# Build stage
# =========================
FROM python:3.12-slim AS builder

RUN pip install --no-cache-dir uv

WORKDIR /app

COPY pyproject.toml uv.lock* ./
RUN uv pip install --system --no-cache .

# =========================
# Runtime stage
# =========================
FROM python:3.12-slim

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.4 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /usr/local /usr/local

ENV TZ=Asia/Tokyo

ENV LAMBDA_TASK_ROOT=/var/task

WORKDIR ${LAMBDA_TASK_ROOT}

COPY ./backend/api/ ${LAMBDA_TASK_ROOT}/api/
COPY ./backend/db/ ${LAMBDA_TASK_ROOT}/db/
COPY ./backend/templates/ ${LAMBDA_TASK_ROOT}/templates/

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]

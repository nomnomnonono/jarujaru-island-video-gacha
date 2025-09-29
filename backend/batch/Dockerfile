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

COPY ./backend/batch/ ${LAMBDA_TASK_ROOT}/batch/
COPY ./backend/db/ ${LAMBDA_TASK_ROOT}/db/

CMD ["batch.main.handler"]

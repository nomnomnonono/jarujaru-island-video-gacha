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
FROM public.ecr.aws/lambda/python:3.12

ENV TZ=Asia/Tokyo

ENV LAMBDA_TASK_ROOT=/var/task

COPY --from=builder /usr/local/lib/python3.12/site-packages ${LAMBDA_TASK_ROOT}

WORKDIR ${LAMBDA_TASK_ROOT}

COPY ./backend/batch/ ${LAMBDA_TASK_ROOT}/batch/
COPY ./backend/db/ ${LAMBDA_TASK_ROOT}/db/

CMD ["batch.main.handler"]

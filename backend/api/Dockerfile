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

COPY ./backend/api/ ${LAMBDA_TASK_ROOT}/api/
COPY ./backend/db/ ${LAMBDA_TASK_ROOT}/db/
COPY ./backend/templates/ ${LAMBDA_TASK_ROOT}/templates/

CMD ["api.main.handler"]

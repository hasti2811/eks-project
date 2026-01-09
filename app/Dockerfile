FROM python:3.12-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY . .

USER appuser

EXPOSE 3000

# Start HTTP server
CMD ["python", "-m", "http.server", "3000"]

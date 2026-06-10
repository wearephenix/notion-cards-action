FROM golang:1.23-alpine3.20 AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main main.go

FROM alpine:3.20

LABEL "com.github.actions.name"="Notion Card Updater"
LABEL "com.github.actions.description"="Updates a Notion card based on events and inputs using the Notion API"
LABEL "com.github.actions.icon"="align-justify"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/zant/notion-cards-action/"
LABEL "homepage"="https://github.com/zant/notion-cards-action/README.md"
LABEL "maintainer"="zant <hey@zant.xyz>"

RUN apk --no-cache add ca-certificates && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=builder /app/main .

USER appuser

ENTRYPOINT ["/app/main"]
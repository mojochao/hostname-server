# Build the manager binary in a separate builder stage.
FROM golang:1.20.4 as builder
WORKDIR /workspace
COPY go.mod go.mod
COPY main.go main.go
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o hostname-server main.go

# Use distroless as minimal base image to package the manager binary.
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/hostname-server .
USER 65532:65532

ENTRYPOINT ["/hostname-server"]

# async_grpc
This is a async grpc multithreaded server implementation completely based on https://github.com/cartographer-project/async_grpc.
Some unnecessary pieces of the original project are stripped out

## Build

### Build Server
make server

### Build Client
make client

## Run
The server and client are configured to run on localhost. Change this to different IP address and rebuild if needed.
The client sends input '100' and the server is supposed to return the square of 100, i.e., 10000.
The server is an async grpc implementation and the client is sync grpc client.

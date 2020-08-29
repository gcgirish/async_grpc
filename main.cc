#include <iostream>
#include <chrono>
#include <future>
#include <thread>

#include "server.h"
#include "async_client.h"
#include "execution_context.h"
#include "proto/math_service.pb.h"
#include "rpc_handler.h"
#include "glog/logging.h"
#include "google/protobuf/descriptor.h"
#include "grpc++/grpc++.h"

using namespace async_grpc;

DEFINE_HANDLER_SIGNATURE(
    GetSquareSignature, proto::GetSquareRequest, proto::GetSquareResponse,
    "/async_grpc.proto.Math/GetSquare")

class GetSquareHandler : public RpcHandler<GetSquareSignature> {
 public:
  void OnRequest(const proto::GetSquareRequest& request) override {
    auto response =
        common::make_unique<proto::GetSquareResponse>();
    response->set_output(request.input() * request.input());
    Send(std::move(response));
  }
};

int main() {
    Server::Builder server_builder;
    server_builder.SetServerAddress("localhost:50051");
    server_builder.SetNumGrpcThreads(2);
    server_builder.SetNumEventThreads(2);
    server_builder.RegisterHandler<GetSquareHandler>();
    std::unique_ptr<Server> server = server_builder.Build();
    server->Start();
    server->WaitForShutdown();

}

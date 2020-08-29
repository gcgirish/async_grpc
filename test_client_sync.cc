/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>

#include "proto/math_service.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

class MathClient {
 public:
  MathClient(std::shared_ptr<Channel> channel)
      : stub_(async_grpc::proto::Math::NewStub(channel)) {}

  // Assembles the client's payload, sends it and presents the response back
  // from the server.
  uint32_t SquareRequest(uint32_t num) {
    // Data we are sending to the server.
    ::async_grpc::proto::GetSquareRequest request;
    request.set_input(num);

    // Container for the data we expect from the server.
    async_grpc::proto::GetSquareResponse reply;

    // Context for the client. It could be used to convey extra information to
    // the server and/or tweak certain RPC behaviors.
    ClientContext context;

    // The actual RPC.
    Status status = stub_->GetSquare(&context, request, &reply);

    // Act upon its status.
    if (status.ok()) {
      return reply.output();
    } else {
      std::cout << status.error_code() << ": " << status.error_message()
                << std::endl;
      return 0;
    }
  }

 private:
  std::unique_ptr<async_grpc::proto::Math::Stub> stub_;
};

int main(int argc, char** argv) {
  // Instantiate the client. It requires a channel, out of which the actual RPCs
  // are created. This channel models a connection to an endpoint specified by
  // the argument "--target=" which is the only expected argument.
  // We indicate that the channel isn't authenticated (use of
  // InsecureChannelCredentials()).
  std::string target_str;
  target_str = "localhost:50051";
  MathClient math(grpc::CreateChannel(
      target_str, grpc::InsecureChannelCredentials()));
  std::string user("world");
  int32_t reply = math.SquareRequest(100);
  std::cout << "Math response received: " << reply << std::endl;

  return 0;
}

CXX = g++
CXXFLAGS += -g -O2
CXXFLAGS += `pkg-config --cflags-only-I grpc++`
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CXXFLAGS += -std=c++11 -fpermissive -Wno-literal-suffix -I. -I/usr/include -I-I/usr/local/include
LDFLAGS += -lopenoltapi -lpthread -lm `pkg-config --libs protobuf grpc++ grpc` -ldl -lgpr -lglog

# test
ASYNC_GRPC_OPENOLT_LIB_DIR=./lib
ASYNC_GRPC_SERVER=test_server_async
GRPC_CLIENT=test_client_sync
#The below way of getting source files is not working
ASYNC_GRPC_SRCS = completion_queue_pool.cc completion_queue_thread.cc event_queue_thread.cc rpc.cc server.cc service.cc common/time.cc test_server_async.cc
ASYNC_GRPC_OBJS = $(ASYNC_GRPC_SRCS:.cc=.o)

server: $(ASYNC_GRPC_OBJS)
	$(CXX) $(shell cmock-config --libs) -L$(ASYNC_GRPC_OPENOLT_LIB_DIR) -L/usr/lib/ -I/usr/include -I./ -o $(ASYNC_GRPC_SERVER) $(ASYNC_GRPC_OBJS) $(LDFLAGS)
src/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

TEST_ASYNC_GRPC_SRCS = completion_queue_pool.cc completion_queue_thread.cc event_queue_thread.cc rpc.cc server.cc service.cc common/time.cc test_client_sync.cc
TEST_ASYNC_GRPC_OBJS = $(TEST_ASYNC_GRPC_SRCS:.cc=.o)

client: $(TEST_ASYNC_GRPC_OBJS)
	$(CXX) $(shell cmock-config --libs) -L$(ASYNC_GRPC_OPENOLT_LIB_DIR) -L/usr/lib/ -I/usr/include -I./ -o $(GRPC_CLIENT) $(TEST_ASYNC_GRPC_OBJS) $(LDFLAGS)
src/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm *.o common/*.o $(ASYNC_GRPC_SERVER) $(GRPC_CLIENT) -f

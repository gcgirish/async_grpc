CXX = g++
CXXFLAGS += -g -O2
CXXFLAGS += `pkg-config --cflags-only-I grpc++`
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CXXFLAGS += -std=c++11 -fpermissive -Wno-literal-suffix -I. -I/usr/include -I-I/usr/local/include
LDFLAGS += -lopenoltapi -lpthread -lm `pkg-config --libs protobuf grpc++ grpc` -ldl -lgpr -lglog

LIB_ASYNC_GRPC = libasyncgrpc.a

SRCS = completion_queue_pool.cc completion_queue_thread.cc event_queue_thread.cc rpc.cc server.cc service.cc common/time.cc
OBJS = $(SRCS:.cc=.o)

build: $(OBJS)
	ar cr $(LIB_ASYNC_GRPC) $^
	ranlib $(LIB_ASYNC_GRPC)
src/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

# test
ASYNC_GRPC_OPENOLT_LIB_DIR=./lib
ASYNC_GRPC_SERVER=test_server_async
SYNC_GRPC_CLIENT=test_client_sync
#The below way of getting source files is not working
TEST_SERVER_ASYNC_GRPC_SRCS = completion_queue_pool.cc completion_queue_thread.cc event_queue_thread.cc rpc.cc server.cc service.cc common/time.cc test_server_async.cc
TEST_SERVER_ASYNC_GRPC_OBJS = $(TEST_SERVER_ASYNC_GRPC_SRCS:.cc=.o)

server: $(TEST_SERVER_ASYNC_GRPC_OBJS)
	$(CXX) $(shell cmock-config --libs) -L$(ASYNC_GRPC_OPENOLT_LIB_DIR) -L/usr/lib/ -I/usr/include -I./ -o $(ASYNC_GRPC_SERVER) $(TEST_SERVER_ASYNC_GRPC_OBJS) $(LDFLAGS)
src/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

TEST_CLIENT_SYNC_GRPC_SRCS = completion_queue_pool.cc completion_queue_thread.cc event_queue_thread.cc rpc.cc server.cc service.cc common/time.cc test_client_sync.cc
TEST_CLIENT_SYNC_GRPC_OBJS = $(TEST_CLIENT_SYNC_GRPC_SRCS:.cc=.o)

client: $(TEST_CLIENT_SYNC_GRPC_OBJS)
	$(CXX) $(shell cmock-config --libs) -L$(ASYNC_GRPC_OPENOLT_LIB_DIR) -L/usr/lib/ -I/usr/include -I./ -o $(SYNC_GRPC_CLIENT) $(TEST_CLIENT_SYNC_GRPC_OBJS) $(LDFLAGS)
src/%.o: src/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm *.o common/*.o $(ASYNC_GRPC_SERVER) $(SYNC_GRPC_CLIENT) $(LIB_ASYNC_GRPC) -f

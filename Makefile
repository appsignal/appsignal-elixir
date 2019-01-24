LIB_NAME = libappsignal.a
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS = -g -O3 -pedantic -Wall -Wextra -I"$(ERLANG_PATH)" -I"$(LIB_DIR)"
ifeq ($(shell uname),Linux)
	LDFLAGS = -Wl,--whole-archive "$(LIB_DIR)"/$(LIB_NAME) -Wl,--no-whole-archive -static-libgcc
else
	LDFLAGS = "$(LIB_DIR)"/$(LIB_NAME)
endif

LIB = appsignal_extension
OUTPUT = "$(LIB_DIR)"/$(LIB).so

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

LDFLAGS += -Wl,-fatal_warnings

all:
	@$(CC) $(CFLAGS) $(CFLAGS_ADD) -shared $(LDFLAGS) -o $(OUTPUT) c_src/$(LIB).c

clean:
	@$(RM) -r "$(LIB_DIR)"/$(LIB).so*

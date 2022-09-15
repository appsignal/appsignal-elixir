LIB_NAME = libappsignal.a
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
LIB_DIR ?= ./priv
CFLAGS = -g -O3 -pedantic -Wall -Wextra -I"$(ERLANG_PATH)" -I"$(LIB_DIR)"
LIB = appsignal_extension
OUTPUT = "$(LIB_DIR)"/$(LIB).so

ifeq ($(shell uname),Linux)
	LDFLAGS = -Wl,--whole-archive "$(LIB_DIR)"/$(LIB_NAME) -Wl,--no-whole-archive -static-libgcc -Wl,-fatal_warnings
else ifeq ($(shell uname),FreeBSD)
	LDFLAGS = -Wl,--whole-archive "$(LIB_DIR)"/$(LIB_NAME) -Wl,--no-whole-archive -Wl,-fatal_warnings
else ifeq ($(shell uname),Darwin)
	# Specify symbols used in the appsignal_extension.c file.
	# The symbols are looked up at runtime, when the Elixir Nif library is loaded.
	LDFLAGS = "$(LIB_DIR)"/$(LIB_NAME) -Wl,-fatal_warnings -dynamiclib -Wl, \
		-U,_enif_alloc_resource, \
		-U,_enif_get_double, \
		-U,_enif_get_int, \
		-U,_enif_get_long, \
		-U,_enif_get_resource, \
		-U,_enif_inspect_iolist_as_binary, \
		-U,_enif_make_atom, \
		-U,_enif_make_badarg, \
		-U,_enif_make_resource, \
		-U,_enif_make_string, \
		-U,_enif_make_string_len, \
		-U,_enif_make_tuple, \
		-U,_enif_open_resource_type, \
		-U,_enif_release_resource
endif

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

all:
	@$(CC) $(CFLAGS) $(CFLAGS_ADD) -shared $(LDFLAGS) -o $(OUTPUT) c_src/$(LIB).c

clean:
	@$(RM) -r "$(LIB_DIR)"/*appsignal* "$(LIB_DIR)"/*.report
	@$(RM) -r c_src/libappsignal* c_src/appsignal-agent c_src/appsignal.*

LIB_NAME = libappsignal.a
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
LIB_DIR ?= ./priv
CFLAGS = -g -O3 -pedantic -Wall -Wextra -I"$(ERLANG_PATH)" -I"$(LIB_DIR)"
ifeq ($(shell uname),Linux)
	LDFLAGS = -Wl,--whole-archive "$(LIB_DIR)"/$(LIB_NAME) -Wl,--no-whole-archive -static-libgcc -Wl,-fatal_warnings
	ifeq ($(shell arch),aarch64)
		LDFLAGS += -Wl,--allow-multiple-definition
	endif
else
	ifeq ($(shell uname),FreeBSD)
		LDFLAGS = -Wl,--whole-archive "$(LIB_DIR)"/$(LIB_NAME) -Wl,--no-whole-archive -Wl,--fatal-warnings
	else
		LDFLAGS = "$(LIB_DIR)"/$(LIB_NAME) -Wl,-fatal_warnings
	endif
endif

LIB = appsignal_extension
OUTPUT = "$(LIB_DIR)"/$(LIB).so

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

ifeq ($(shell uname),Darwin)
	# Specify symbols used in the appsignal_extension.c file.
	# The symbols are looked up at runtime, when the Elixir Nif library is loaded.
	LDFLAGS += -dynamiclib -Wl,-fatal_warnings \
		-Wl,-U,_enif_alloc_resource, \
		-Wl,-U,_enif_get_double \
		-Wl,-U,_enif_get_int \
		-Wl,-U,_enif_get_long \
		-Wl,-U,_enif_get_resource \
		-Wl,-U,_enif_inspect_iolist_as_binary \
		-Wl,-U,_enif_make_atom \
		-Wl,-U,_enif_make_badarg \
		-Wl,-U,_enif_make_resource \
		-Wl,-U,_enif_make_string \
		-Wl,-U,_enif_make_string_len \
		-Wl,-U,_enif_make_tuple \
		-Wl,-U,_enif_open_resource_type \
		-Wl,-U,_enif_release_resource
endif

all:
	@$(CC) $(CFLAGS) $(CFLAGS_ADD) -shared $(LDFLAGS) -o $(OUTPUT) c_src/$(LIB).c

clean:
	@$(RM) -r "$(LIB_DIR)"/*appsignal* "$(LIB_DIR)"/*.report
	@$(RM) -r c_src/libappsignal* c_src/appsignal-agent c_src/appsignal.*

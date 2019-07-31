#ifdef __GNUC__
  #define UNUSED(x) UNUSED_ ## x __attribute__((__unused__))
#else
  #define UNUSED(x) UNUSED_ ## x
#endif

#include "erl_nif.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <appsignal.h>

static ErlNifResourceType *appsignal_transaction_type = NULL;
static ErlNifResourceType *appsignal_data_type = NULL;

typedef struct {
  appsignal_transaction_t *transaction;
} transaction_ptr;

typedef struct {
  appsignal_data_t *data;
} data_ptr;

static ERL_NIF_TERM
make_ok_tuple(ErlNifEnv *env, ERL_NIF_TERM value)
{
    return enif_make_tuple2(env, enif_make_atom(env, "ok"), value);
}

static ERL_NIF_TERM
make_error_tuple(ErlNifEnv *env, const char *reason)
{
    return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, reason));
}

static appsignal_string_t make_appsignal_string(ErlNifBinary binary)
{
    appsignal_string_t retval;
    retval.len = binary.size;
    retval.buf = (char *)binary.data;
    return retval;
}

static ERL_NIF_TERM make_elixir_string(ErlNifEnv* env, appsignal_string_t binary) {
  return enif_make_string_len(env, binary.buf, binary.len, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM _env_put(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ErlNifBinary key, value;

  if (argc != 2) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
      return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[1], &value)) {
      return enif_make_badarg(env);
  }

  appsignal_env_put(
    make_appsignal_string(key),
    make_appsignal_string(value)
  );

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _env_get(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  ErlNifBinary key;
  appsignal_string_t value;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
      return enif_make_badarg(env);
  }

  value = appsignal_env_get(
    make_appsignal_string(key)
  );

  return enif_make_string(env, value.buf, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM _env_delete(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary key;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
      return enif_make_badarg(env);
  }

  appsignal_env_delete(
    make_appsignal_string(key)
  );

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _env_clear(ErlNifEnv* env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[]))
{
  appsignal_env_clear();

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _start(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[]))
{
    appsignal_start();
    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _stop(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[]))
{
    appsignal_stop();
    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _diagnose(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[])) {
  return make_elixir_string(env, appsignal_diagnose());
}

static ERL_NIF_TERM _start_transaction(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary transaction_id, namespace;
    transaction_ptr *ptr;
    ERL_NIF_TERM transaction_ref;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[0], &transaction_id)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &namespace)) {
        return enif_make_badarg(env);
    }

    ptr = enif_alloc_resource(appsignal_transaction_type, sizeof(transaction_ptr));
    if(!ptr)
      return make_error_tuple(env, "no_memory");

    ptr->transaction = appsignal_start_transaction(
        make_appsignal_string(transaction_id),
        make_appsignal_string(namespace),
        0
    );

    transaction_ref = enif_make_resource(env, ptr);
    enif_release_resource(ptr);

    return make_ok_tuple(env, transaction_ref);
}

static ERL_NIF_TERM _start_event(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;

    if (argc != 1) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_start_event(ptr->transaction, 0);

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _finish_event(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary name, title, body;
    int bodyFormat;

    if (argc != 5) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &name)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &title)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[3], &body)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_int(env, argv[4], &bodyFormat)) {
        return enif_make_badarg(env);
    }

    appsignal_finish_event(
        ptr->transaction,
        make_appsignal_string(name),
        make_appsignal_string(title),
        make_appsignal_string(body),
        bodyFormat,
        0
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _finish_event_data(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary name, title;
    int bodyFormat;
    data_ptr *body;

    if (argc != 5) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &name)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &title)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[3], appsignal_data_type, (void**) &body)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_int(env, argv[4], &bodyFormat)) {
      return enif_make_badarg(env);
    }

    appsignal_finish_event_data(
        ptr->transaction,
        make_appsignal_string(name),
        make_appsignal_string(title),
        body->data,
        bodyFormat,
        0
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _record_event(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary name, title, body;
    long duration;
    int bodyFormat;

    if (argc != 6) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &name)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &title)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[3], &body)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_int(env, argv[4], &bodyFormat)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_long(env, argv[5], &duration)) {
        return enif_make_badarg(env);
    }

    appsignal_record_event(
        ptr->transaction,
        make_appsignal_string(name),
        make_appsignal_string(title),
        make_appsignal_string(body),
        bodyFormat,
        duration,
        0
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_error(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary error, message;
    data_ptr *data_ptr;

    if (argc != 4) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &error)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &message)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[3], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_set_transaction_error(
        ptr->transaction,
        make_appsignal_string(error),
        make_appsignal_string(message),
        data_ptr->data
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_sample_data(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary key;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_set_transaction_sample_data(
        ptr->transaction,
        make_appsignal_string(key),
        data_ptr->data
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_action(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary action;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &action)) {
        return enif_make_badarg(env);
    }

    appsignal_set_transaction_action(
        ptr->transaction,
        make_appsignal_string(action)
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_namespace(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary namespace;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &namespace)) {
        return enif_make_badarg(env);
    }

    appsignal_set_transaction_namespace(
        ptr->transaction,
        make_appsignal_string(namespace)
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_queue_start(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    long start;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_long(env, argv[1], &start)) {
        return enif_make_badarg(env);
    }

    appsignal_set_transaction_queue_start(
        ptr->transaction,
        start
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _set_meta_data(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    ErlNifBinary key, value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_transaction_metadata(
        ptr->transaction,
        make_appsignal_string(key),
        make_appsignal_string(value)
    );

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _finish(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;
    int sample;

    if (argc != 1) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }

    sample = appsignal_finish_transaction(ptr->transaction, 0);

    if (sample == 1) {
      return enif_make_atom(env, "sample");
    } else {
      return enif_make_atom(env, "no_sample");
    }
}

static ERL_NIF_TERM _complete(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    transaction_ptr *ptr;

    if (argc != 1) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_complete_transaction(ptr->transaction);

    return enif_make_atom(env, "ok");
}

static void destruct_appsignal_transaction(ErlNifEnv *UNUSED(env), void *arg) {
  transaction_ptr *ptr = (transaction_ptr *)arg;
  appsignal_free_transaction(ptr->transaction);
}

static void destruct_appsignal_data(ErlNifEnv *UNUSED(env), void *arg) {
  data_ptr *ptr = (data_ptr *)arg;
  appsignal_free_data(ptr->data);
}

static ERL_NIF_TERM _set_gauge(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary key;
    double value;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_double(env, argv[1], &value)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_set_gauge(make_appsignal_string(key), value, data_ptr->data);

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _increment_counter(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary key;
    double count;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_double(env, argv[1], &count)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_increment_counter(make_appsignal_string(key), count, data_ptr->data);

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _add_distribution_value(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary key;
    double value;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[0], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_double(env, argv[1], &value)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_add_distribution_value(make_appsignal_string(key), value, data_ptr->data);

    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_map_new(ErlNifEnv* env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[])) {
  data_ptr *ptr;
  ERL_NIF_TERM data_ref;

  ptr = enif_alloc_resource(appsignal_data_type, sizeof(data_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->data = appsignal_data_map_new();

  data_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, data_ref);
}

static ERL_NIF_TERM _data_set_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  ErlNifBinary key, value;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 3:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }
      if(!enif_inspect_iolist_as_binary(env, argv[2], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_string(ptr->data, make_appsignal_string(key), make_appsignal_string(value));
      break;

    case 2:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_array_append_string(ptr->data, make_appsignal_string(value));
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_set_integer(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  ErlNifBinary key;
  long value;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 3:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }
      if(!enif_get_int64(env, argv[2], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_integer(ptr->data, make_appsignal_string(key), value);
      break;

    case 2:
      if(!enif_get_int64(env, argv[1], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_array_append_integer(ptr->data, value);
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_set_float(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  ErlNifBinary key;
  double value;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 3:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }
      if(!enif_get_double(env, argv[2], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_float(ptr->data, make_appsignal_string(key), value);
      break;

    case 2:
      if(!enif_get_double(env, argv[1], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_array_append_float(ptr->data, value);
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_set_boolean(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  ErlNifBinary key;
  int value;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 3:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }
      if (!enif_get_int(env, argv[2], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_boolean(ptr->data, make_appsignal_string(key), value);
      break;

    case 2:
      if (!enif_get_int(env, argv[1], &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_array_append_boolean(ptr->data, value);
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_set_nil(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  ErlNifBinary key;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 2:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_null(ptr->data, make_appsignal_string(key));
      break;

    case 1:
      appsignal_data_array_append_null(ptr->data);
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_set_data(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr, *value;
  ErlNifBinary key;

  if(!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  switch(argc) {
    case 3:
      if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
      }
      if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_map_set_data(ptr->data, make_appsignal_string(key), value->data);
      break;

    case 2:
      if(!enif_get_resource(env, argv[1], appsignal_data_type, (void**) &value)) {
        return enif_make_badarg(env);
      }

      appsignal_data_array_append_data(ptr->data, value->data);
      break;

    default:
      return enif_make_badarg(env);
  }

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM _data_list_new(ErlNifEnv* env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[])) {
  data_ptr *ptr;
  ERL_NIF_TERM data_ref;

  ptr = enif_alloc_resource(appsignal_data_type, sizeof(data_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->data = appsignal_data_array_new();

  data_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, data_ref);
}

static ERL_NIF_TERM _running_in_container(ErlNifEnv* env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[])) {
  if(appsignal_running_in_container() == 1) {
    return enif_make_atom(env, "true");
  } else {
    return enif_make_atom(env, "false");
  }
}

#ifdef TEST
static ERL_NIF_TERM _data_to_json(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  data_ptr *ptr;
  appsignal_string_t json;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if (!enif_get_resource(env, argv[0], appsignal_data_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  json = appsignal_data_to_json(ptr->data);
  return make_ok_tuple(env, enif_make_string(env, json.buf, ERL_NIF_LATIN1));
}

static ERL_NIF_TERM _transaction_to_json(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  transaction_ptr *ptr;
  appsignal_string_t json;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if (!enif_get_resource(env, argv[0], appsignal_transaction_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  json = appsignal_transaction_to_json(ptr->transaction);
  return make_ok_tuple(env, make_elixir_string(env, json));
}
#endif

static ERL_NIF_TERM _loaded(ErlNifEnv *env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[])) {
  return enif_make_atom(env, "true");
}

static ERL_NIF_TERM _trace_id(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  return make_ok_tuple(env, enif_make_string(env, "trace321", ERL_NIF_LATIN1));
}

static ERL_NIF_TERM _span_id(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  return make_ok_tuple(env, enif_make_string(env, "span321", ERL_NIF_LATIN1));
}

static int on_load(ErlNifEnv* env, void** UNUSED(priv), ERL_NIF_TERM UNUSED(info))
{
    ErlNifResourceType *transaction_resource_type;
    ErlNifResourceType *data_resource_type;

    transaction_resource_type = enif_open_resource_type(
        env,
        "appsignal_nif",
        "appsignal_transaction_type",
        destruct_appsignal_transaction,
        ERL_NIF_RT_CREATE,
        NULL
    );

    data_resource_type = enif_open_resource_type(
        env,
        "appsignal_nif",
        "appsignal_data_type",
        destruct_appsignal_data,
        ERL_NIF_RT_CREATE,
        NULL
    );

    if (!transaction_resource_type || !data_resource_type) {
      return -1;
    }
    appsignal_transaction_type = transaction_resource_type;
    appsignal_data_type = data_resource_type;

    return 0;
}

static int on_reload(ErlNifEnv* UNUSED(env), void** UNUSED(priv_data), ERL_NIF_TERM UNUSED(load_info))
{
    return 0;
}

static int on_upgrade(ErlNifEnv* UNUSED(env), void** UNUSED(priv), void** UNUSED(old_priv_data), ERL_NIF_TERM UNUSED(load_info))
{
    return 0;
}

static ErlNifFunc nif_funcs[] =
{
    {"_env_put", 2, _env_put, 0},
    {"_env_get", 1, _env_get, 0},
    {"_env_delete", 1, _env_delete, 0},
    {"_env_clear", 0, _env_clear, 0},
    {"_start", 0, _start, 0},
    {"_stop", 0, _stop, 0},
    {"_diagnose", 0, _diagnose, 0},
    {"_start_transaction", 2, _start_transaction, 0},
    {"_start_event", 1, _start_event, 0},
    {"_finish_event", 5, _finish_event, 0},
    {"_finish_event_data", 5, _finish_event_data, 0},
    {"_record_event", 6, _record_event, 0},
    {"_set_error", 4, _set_error, 0},
    {"_set_sample_data", 3, _set_sample_data, 0},
    {"_set_action", 2, _set_action, 0},
    {"_set_namespace", 2, _set_namespace, 0},
    {"_set_queue_start", 2, _set_queue_start, 0},
    {"_set_meta_data", 3, _set_meta_data, 0},
    {"_finish", 1, _finish, 0},
    {"_complete", 1, _complete, 0},
    {"_set_gauge", 3, _set_gauge, 0},
    {"_increment_counter", 3, _increment_counter, 0},
    {"_add_distribution_value", 3, _add_distribution_value, 0},
    {"_data_map_new", 0, _data_map_new, 0},
    {"_data_set_string", 3, _data_set_string, 0},
    {"_data_set_string", 2, _data_set_string, 0},
    {"_data_set_integer", 3, _data_set_integer, 0},
    {"_data_set_integer", 2, _data_set_integer, 0},
    {"_data_set_float", 3, _data_set_float, 0},
    {"_data_set_float", 2, _data_set_float, 0},
    {"_data_set_boolean", 3, _data_set_boolean, 0},
    {"_data_set_boolean", 2, _data_set_boolean, 0},
    {"_data_set_nil", 2, _data_set_nil, 0},
    {"_data_set_nil", 1, _data_set_nil, 0},
    {"_data_set_data", 3, _data_set_data, 0},
    {"_data_set_data", 2, _data_set_data, 0},
    {"_data_list_new", 0, _data_list_new, 0},
    {"_running_in_container", 0, _running_in_container, 0},
#ifdef TEST
    {"_transaction_to_json", 1, _transaction_to_json, 0},
    {"_data_to_json", 1, _data_to_json, 0},
#endif
    {"_loaded", 0, _loaded, 0},
    {"_trace_id", 1, _trace_id, 0}
    {"_span_id", 1, _span_id, 0}
};

ERL_NIF_INIT(Elixir.Appsignal.Nif, nif_funcs, on_load, on_reload, on_upgrade, NULL)

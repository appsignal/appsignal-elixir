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

static ErlNifResourceType *appsignal_data_type = NULL;
static ErlNifResourceType *appsignal_span_type = NULL;

ERL_NIF_TERM ok_atom;
ERL_NIF_TERM error_atom;
ERL_NIF_TERM sample_atom;
ERL_NIF_TERM no_sample_atom;
ERL_NIF_TERM true_atom;
ERL_NIF_TERM false_atom;

typedef struct {
  appsignal_data_t *data;
} data_ptr;

typedef struct {
  appsignal_span_t *span;
} span_ptr;

static ERL_NIF_TERM
make_ok_tuple(ErlNifEnv *env, ERL_NIF_TERM value)
{
    return enif_make_tuple2(env, ok_atom, value);
}

static ERL_NIF_TERM
make_error_tuple(ErlNifEnv *env, const char *reason)
{
    return enif_make_tuple2(env, error_atom, enif_make_atom(env, reason));
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

  return ok_atom;
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

  return ok_atom;
}

static ERL_NIF_TERM _env_clear(ErlNifEnv* env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[]))
{
  appsignal_env_clear();

  return ok_atom;
}

static ERL_NIF_TERM _start(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[]))
{
    appsignal_start();
    return ok_atom;
}

static ERL_NIF_TERM _stop(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[]))
{
    appsignal_stop();
    return ok_atom;
}

static ERL_NIF_TERM _diagnose(ErlNifEnv* env, int UNUSED(arc), const ERL_NIF_TERM UNUSED(argv[])) {
  return make_elixir_string(env, appsignal_diagnose());
}

static void destruct_appsignal_data(ErlNifEnv *UNUSED(env), void *arg) {
  data_ptr *ptr = (data_ptr *)arg;
  appsignal_free_data(ptr->data);
}

static void destruct_appsignal_span(ErlNifEnv *UNUSED(env), void *arg) {
  span_ptr *ptr = (span_ptr *)arg;
  appsignal_free_span(ptr->span);
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

    return ok_atom;
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

    return ok_atom;
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

    return ok_atom;
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

  return ok_atom;
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

  return ok_atom;
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

  return ok_atom;
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

  return ok_atom;
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

  return ok_atom;
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

  return ok_atom;
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
    return true_atom;
  } else {
    return false_atom;
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
#endif

static ERL_NIF_TERM _loaded(ErlNifEnv *env, int UNUSED(argc), const ERL_NIF_TERM UNUSED(argv[])) {
  return true_atom;
}

static ERL_NIF_TERM _create_root_span(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  span_ptr *ptr;
  ErlNifBinary namespace;
  ERL_NIF_TERM span_ref;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &namespace)) {
    return enif_make_badarg(env);
  }

  ptr = enif_alloc_resource(appsignal_span_type, sizeof(span_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->span = appsignal_create_root_span(make_appsignal_string(namespace));

  span_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, span_ref);
}

static ERL_NIF_TERM _create_root_span_with_timestamp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  span_ptr *ptr;
  ErlNifBinary namespace;
  long sec;
  long nsec;
  ERL_NIF_TERM span_ref;

  if (argc != 3) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &namespace)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_long(env, argv[1], &sec)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_long(env, argv[2], &nsec)) {
    return enif_make_badarg(env);
  }

  ptr = enif_alloc_resource(appsignal_span_type, sizeof(span_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->span = appsignal_create_root_span_with_timestamp(make_appsignal_string(namespace), sec, nsec);

  span_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, span_ref);
}

static ERL_NIF_TERM _create_child_span(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  span_ptr *parent;
  span_ptr *ptr;
  ERL_NIF_TERM span_ref;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &parent)) {
    return enif_make_badarg(env);
  }

  ptr = enif_alloc_resource(appsignal_span_type, sizeof(span_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->span = appsignal_create_child_span(parent->span);

  span_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, span_ref);
}

static ERL_NIF_TERM _create_child_span_with_timestamp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  span_ptr *parent;
  span_ptr *ptr;
  long sec;
  long nsec;
  ERL_NIF_TERM span_ref;

  if (argc != 3) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &parent)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_long(env, argv[1], &sec)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_long(env, argv[2], &nsec)) {
    return enif_make_badarg(env);
  }

  ptr = enif_alloc_resource(appsignal_span_type, sizeof(span_ptr));
  if(!ptr)
    return make_error_tuple(env, "no_memory");

  ptr->span = appsignal_create_child_span_with_timestamp(parent->span, sec, nsec);

  span_ref = enif_make_resource(env, ptr);
  enif_release_resource(ptr);

  return make_ok_tuple(env, span_ref);
}

static ERL_NIF_TERM _set_span_name(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary name;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &name)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_name(ptr->span, make_appsignal_string(name));

    return ok_atom;
}

static ERL_NIF_TERM _set_span_name_if_nil(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary name;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &name)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_name_if_nil(ptr->span, make_appsignal_string(name));

    return ok_atom;
}

static ERL_NIF_TERM _set_span_namespace(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary namespace;

    if (argc != 2) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &namespace)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_namespace(ptr->span, make_appsignal_string(namespace));

    return ok_atom;
}

static ERL_NIF_TERM _set_span_attribute_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    ErlNifBinary value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_attribute_string(
        ptr->span,
        make_appsignal_string(key),
        make_appsignal_string(value)
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_attribute_int(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    long value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_long(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_attribute_int(
        ptr->span,
        make_appsignal_string(key),
        value
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_attribute_bool(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    int value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_int(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_attribute_bool(
        ptr->span,
        make_appsignal_string(key),
        value
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_attribute_double(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    double value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_get_double(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_attribute_double(
        ptr->span,
        make_appsignal_string(key),
        value
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_attribute_sql_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    ErlNifBinary value;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
        return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[2], &value)) {
        return enif_make_badarg(env);
    }

    appsignal_set_span_attribute_sql_string(
        ptr->span,
        make_appsignal_string(key),
        make_appsignal_string(value)
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_sample_data(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_set_span_sample_data(
        ptr->span,
        make_appsignal_string(key),
        data_ptr->data
    );

    return ok_atom;
}

static ERL_NIF_TERM _set_span_sample_data_if_nil(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    ErlNifBinary key;
    data_ptr *data_ptr;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_inspect_iolist_as_binary(env, argv[1], &key)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], appsignal_data_type, (void**) &data_ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_set_span_sample_data_if_nil(
        ptr->span,
        make_appsignal_string(key),
        data_ptr->data
    );

    return ok_atom;
}

static ERL_NIF_TERM _add_span_error(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    span_ptr *ptr;
    ErlNifBinary error, message;
    data_ptr *data_ptr;

    if (argc != 4) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
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

    appsignal_add_span_error(
        ptr->span,
        make_appsignal_string(error),
        make_appsignal_string(message),
        data_ptr->data
    );

    return ok_atom;
}

static ERL_NIF_TERM _close_span(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;

    if (argc != 1) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }

    appsignal_close_span(ptr->span);

    return ok_atom;
}

static ERL_NIF_TERM _close_span_with_timestamp(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    span_ptr *ptr;
    long sec;
    long nsec;

    if (argc != 3) {
      return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_long(env, argv[1], &sec)) {
      return enif_make_badarg(env);
    }
    if(!enif_get_long(env, argv[2], &nsec)) {
      return enif_make_badarg(env);
    }

    appsignal_close_span_with_timestamp(ptr->span, sec, nsec);

    return ok_atom;
}

static ERL_NIF_TERM _span_to_json(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  span_ptr *ptr;
  appsignal_string_t json;

  if (argc != 1) {
    return enif_make_badarg(env);
  }
  if (!enif_get_resource(env, argv[0], appsignal_span_type, (void**) &ptr)) {
    return enif_make_badarg(env);
  }

  json = appsignal_span_to_json(ptr->span);
  return make_ok_tuple(env, make_elixir_string(env, json));
}

static ERL_NIF_TERM _log(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary group, message;
  int severity;
  int format;
  data_ptr *data_ptr;

  if (argc != 5) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[0], &group)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env, argv[1], &severity)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env, argv[2], &format)) {
    return enif_make_badarg(env);
  }
  if(!enif_inspect_iolist_as_binary(env, argv[3], &message)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[4], appsignal_data_type, (void**) &data_ptr)) {
    return enif_make_badarg(env);
  }

  appsignal_log(
    make_appsignal_string(group),
    severity,
    format,
    make_appsignal_string(message),
    data_ptr->data
  );

  return ok_atom;
}

static int on_load(ErlNifEnv* env, void** UNUSED(priv), ERL_NIF_TERM UNUSED(info))
{
    ErlNifResourceType *data_resource_type;
    ErlNifResourceType *span_resource_type;

    data_resource_type = enif_open_resource_type(
        env,
        "appsignal_nif",
        "appsignal_data_type",
        destruct_appsignal_data,
        ERL_NIF_RT_CREATE,
        NULL
    );

    span_resource_type = enif_open_resource_type(
        env,
        "appsignal_nif",
        "appsignal_span_type",
        destruct_appsignal_span,
        ERL_NIF_RT_CREATE,
        NULL
    );

    if (!data_resource_type) {
      return -1;
    }
    appsignal_data_type = data_resource_type;
    appsignal_span_type = span_resource_type;

    ok_atom = enif_make_atom(env, "ok");
    error_atom = enif_make_atom(env, "error");
    sample_atom = enif_make_atom(env, "sample");
    no_sample_atom = enif_make_atom(env, "no_sample");
    true_atom = enif_make_atom(env, "true");
    false_atom = enif_make_atom(env, "false");

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
    {"_data_to_json", 1, _data_to_json, 0},
#endif
    {"_loaded", 0, _loaded, 0},
    {"_create_root_span", 1, _create_root_span, 0},
    {"_create_root_span_with_timestamp", 3, _create_root_span_with_timestamp, 0},
    {"_create_child_span", 1, _create_child_span, 0},
    {"_create_child_span_with_timestamp", 3, _create_child_span_with_timestamp, 0},
    {"_set_span_name", 2, _set_span_name, 0},
    {"_set_span_name_if_nil", 2, _set_span_name_if_nil, 0},
    {"_set_span_namespace", 2, _set_span_namespace, 0},
    {"_set_span_attribute_string", 3, _set_span_attribute_string, 0},
    {"_set_span_attribute_int", 3, _set_span_attribute_int, 0},
    {"_set_span_attribute_bool", 3, _set_span_attribute_bool, 0},
    {"_set_span_attribute_double", 3, _set_span_attribute_double, 0},
    {"_set_span_attribute_sql_string", 3, _set_span_attribute_sql_string, 0},
    {"_set_span_sample_data", 3, _set_span_sample_data, 0},
    {"_set_span_sample_data_if_nil", 3, _set_span_sample_data_if_nil, 0},
    {"_add_span_error", 4, _add_span_error, 0},
    {"_close_span", 1, _close_span, 0},
    {"_close_span_with_timestamp", 3, _close_span_with_timestamp, 0},
    {"_span_to_json", 1, _span_to_json, 0},
    {"_log", 5, _log, 0}
};

ERL_NIF_INIT(Elixir.Appsignal.Nif, nif_funcs, on_load, on_reload, on_upgrade, NULL)

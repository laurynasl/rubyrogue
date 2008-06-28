#include "ruby.h"
#include "fov.h"

static VALUE rb_cRubyFov;

/*static VALUE fov_initialize(VALUE self, VALUE map) {*/
/*}*/

static bool opaque(void *map_ptr, int x, int y) {
  VALUE map = (VALUE)map_ptr;
  return rb_funcall(map, rb_intern("opaque_at?"), 2, INT2FIX(x), INT2FIX(y));
}

static void apply(void *map, int x, int y, int dx, int dy, void *src) {
  rb_funcall((VALUE)map, rb_intern("apply_lighting"), 2, INT2FIX(x), INT2FIX(y));
}

static VALUE fov_calculate(VALUE self, VALUE map, VALUE x, VALUE y, VALUE radius) {
  fov_settings_type fov_settings;

  fov_settings_init(&fov_settings);
  fov_settings_set_opacity_test_function(&fov_settings, opaque);
  fov_settings_set_apply_lighting_function(&fov_settings, apply);

  fov_circle(&fov_settings, (void*)map, NULL, FIX2INT(x), FIX2INT(y), FIX2INT(radius));

  fov_settings_free(&fov_settings);
  return Qnil;
}

void Init_ruby_fov() {
  rb_cRubyFov = rb_define_class("RubyFov", rb_cObject);
  /*rb_define_method(rb_cRubyFov, "initialize", fov_initialize, 1);*/
  rb_define_singleton_method(rb_cRubyFov, "calculate", fov_calculate, 4);
}

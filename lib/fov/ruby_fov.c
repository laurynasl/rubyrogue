#include "ruby.h"
#include "fov.h"

static VALUE rb_cRubyFov;

/*static VALUE fov_initialize(VALUE self, VALUE map) {*/
/*}*/

bool opaque(void *map, int x, int y) {
  return true;
}

void apply(void *map, int x, int y, int dx, int dy, void *src) {
}

static VALUE fov_calculate(VALUE self, VALUE map) {
  printf("labas\n");
  fov_settings_type fov_settings;

  fov_settings_init(&fov_settings);
  fov_settings_set_opacity_test_function(&fov_settings, opaque);
  fov_settings_set_apply_lighting_function(&fov_settings, apply);
  fov_settings_free(&fov_settings);
  printf("viso\n");
  return Qnil;
}

void Init_ruby_fov() {
  rb_cRubyFov = rb_define_class("RubyFov", rb_cObject);
  /*rb_define_method(rb_cRubyFov, "initialize", fov_initialize, 1);*/
  rb_define_singleton_method(rb_cRubyFov, "calculate", fov_calculate, 1);
}

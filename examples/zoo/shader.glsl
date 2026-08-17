@vs vs
in vec4 position;
in vec4 color0;

out vec4 color;

void main() {
    gl_Position = position;
    color = color0;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;

#define SHEETMAP_TEXEL_SAMPLER
#define SHEETMAP_BINDING_START 10 
@include ../../src/glsl/linomap.glsl
@include ../../src/glsl/linomap_slug.glsl

void main() {
    frag_color = color;
}
@end

@program triangle vs fs


# linomap 

A text rendering manifesto.

Linomap is a project which defines a novel method for text rendering which replaces textured quads (although I'm sure something like this has been used before, so I'm not saying I've 'invented' it, it's a very simple idea anyway).

- A linomap is a texture-like object which is sampled using uvs, and defines glyphs placed on lines.
- A linomap consists of a SheetCellBuffer, which contains a regular grid of linomap cells which can have multiple glyphs binned into them.
- An optional KernBuffer defines the kerning for each glyph.
- An optional LineBuffer allows for compressing the data such that the "dead zones" (regions of whitespace either side of the content of a line) doesn't get stored.
- An optional set of GlyphDataBuffer's allow you to associate arbitrary data with each glyph (colours, metalness, roughness ect..) for applying material values to the text.
- A LinomapSampler defines the sampling properties for sampling, such as the wrapping modes (repeat, clamp) and the direction of the text (left->right/right->left), the alignment of the lines (left aligned, centred, right aligned), and the foreground and background colours of the SheetMap.

Linomapping allows for a unified representation of text on the gpu, which allows for efficient 2D rendering of text and mapping of text to 3D geometry whilst preserving quality and reducing memory usage. They can also be compressed very easily using glyph palletes.

Because a SheetMap defines both the foreground (the text itself) and the background (the colour that the SheetMapSampler produces for regions of the Linomap that don't contain text), you can render an entire block of text without any blending (As text tends to be rendered on top of a uniform coloured background).

Sheetmaps are completely agnostic to the method of rendering of the glyphs themselves, and any method can be used (atlased bitmaps, sdfs, msdfs and even directly sampling lines and bezier curves if you're so inclined).

Linomaps naturally align well with texture arrays/and or bindless textures, as glyphs are stored using glyph indices, although it's easy to use atlases with Linomaps too.

## Terminology

The term linomap is a portmantau of linotype and texture map. Linotypes were typesetting machines which produced lead matricies for printing. I use this term as linomaps are composed of lines of quadrat cells and so it's a poingiant analogy, and a fitting nod to the history of typography and typsetting.  

## Sampling Backends

### linomap_slug

### linomap_msdf

## Using linomaps 

I provide a glsl interface for using linomaps in shaders and some zig code to build linomaps from utf8 strings.

### In glsl

Fragment shader:

```glsl
//Tells sheetmap.glsl where to start its resource bindings
#define LINOMAP_BINDING_START 10
//Tells sheetmap.glsl that there is an implementation of a texel sampler 
#define LINOMAP_TEXEL_SAMPLER
#include "linomap.glsl"

#if SLUG
//Use the slug sampling backend
#include "linomap_slug.glsl"
#else
//Use the msdf sampling backend
#include "linomap_msdf.glsl"
#endif

uniform uint linomap_index;
//This is just a standard uv ([0, 1] maps to [0, linomap.width] in ems
//(and likewise for [0, 1] -> [0, linomap.height])
in vec2 uv;

out vec4 target_colour;

void main() {
    //This can of course be set on the cpu and put into a buffer
    LinomapSampler linomap_sampler;
    //The typeface index to sample from
    linomap_sampler.typeface = 0;
    //The colour of the background
    linomap_sampler.background_colour = packUnorm4x8(vec4(1, 1, 1, 1));
    //The colour of the text
    linomap_sampler.foreground_colour = packUnorm4x8(vec4(0, 0, 0, 1));

    vec4 texel = linomapSampleTexel(
        CombinedLinomapSampler(linomaps.data[linomap_index], linomap_sampler), 
        uv
    );
    
    target_colour = texel;
}
```

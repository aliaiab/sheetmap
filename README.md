
# sheetmap

A text rendering manifesto.

Sheetmap is a project which defines a novel method for text rendering which replaces textured quads (although I'm sure something like this has been used before, so I'm not saying I've 'invented' it, it's a very simple idea anyway).

- A sheetmap is a texture-like object which is sampled using uvs, and defines glyphs placed on lines.
- A sheetmap consists of a SheetCellBuffer, which contains a regular grid of sheet cells which can have multiple glyphs binned into them.
- An optional KernBuffer defines the kerning for each glyph.
- An optional LineBuffer allows for compressing the data such that the "dead zones" (regions of whitespace either side of the content of a line) doesn't get stored.
- An optional set of GlyphDataBuffer's allow you to associate arbitrary data with each glyph (colours, metalness, roughness ect..) for applying material values to the text.
- A SheetMapSampler defines the sampling properties for sampling, such as the wrapping modes (repeat, clamp) and the direction of the text (left->right/right->left), the alignment of the lines (left aligned, centred, right aligned), and the foreground and background colours of the SheetMap.

Sheet mapping allows for a unified representation of text on the gpu, which allows for efficient 2D rendering of text and mapping of text to 3D geometry whilst preserving quality and reducing memory usage. They can also be compressed very easily using glyph palletes.

Because a SheetMap defines both the foreground (the text itself) and the background (the colour that the SheetMapSampler produces for regions of the SheetMap that don't contain text), you can render an entire block of text without any blending (As text tends to be rendered on top of a uniform coloured background).

Sheetmaps are completely agnostic to the method of rendering of the glyphs themselves, and any method can be used (atlased bitmaps, sdfs, msdfs and even directly sampling lines and bezier curves if you're so inclined).

Sheetmaps naturally align well with texture arrays/and or bindless textures, as glyphs are stored using glyph indices, although it's easy to use atlases too with sheetmaps too.

## Terminology

Some people may not like the term sheetmap, or may wonder why I call them this. It comes from the idea of a block of rendered text on a "sheet", or the background. A sheet may sound like an overly physical word to use for this, but we call textures 'textures' (referring to the physical texture of objects) and don't bat an eye. I think a sheetmap makes sense, it's a sheet of text.

## Using sheetmaps

I provide a glsl interface for using sheetmaps in shaders and some zig code to build sheetmaps from utf8 strings.
